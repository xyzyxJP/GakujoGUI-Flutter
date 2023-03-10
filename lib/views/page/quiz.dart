import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  bool _searchStatus = false;
  bool _filterStatus = false;
  List<Quiz> _quizzes = [];
  List<Quiz> _suggestQuizzes = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: context.watch<QuizRepository>().getAll(),
      builder: (context, AsyncSnapshot<List<Quiz>> snapshot) {
        if (snapshot.hasData) {
          _quizzes = snapshot.data!;
          _quizzes.sort(((a, b) => b.compareTo(a)));
          var filteredQuizzes = _quizzes
              .where((e) => _filterStatus
                  ? !(e.isArchived ||
                      !(!e.isSubmitted &&
                          e.endDateTime.isAfter(DateTime.now())))
                  : true)
              .toList();
          return Scaffold(
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxScrolled) =>
                  [_buildAppBar(context)],
              body: RefreshIndicator(
                onRefresh: () async =>
                    context.read<ApiRepository>().fetchQuizzes(),
                child: filteredQuizzes.isEmpty
                    ? LayoutBuilder(
                        builder: (context, constraints) =>
                            SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                minHeight: constraints.maxHeight),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Icon(
                                      Icons.checklist_rounded,
                                      size: 48.0,
                                    ),
                                  ),
                                  Text(
                                    '小テストはありません',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8),
                        itemCount: _searchStatus
                            ? _suggestQuizzes.length
                            : filteredQuizzes.length,
                        itemBuilder: (context, index) => _searchStatus
                            ? _buildCard(context, _suggestQuizzes[index])
                            : _buildCard(context, filteredQuizzes[index]),
                      ),
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      centerTitle: true,
      floating: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      title: _searchStatus
          ? TextField(
              onChanged: (value) => setState(() => _suggestQuizzes =
                  _quizzes.where((e) => e.contains(value)).toList()),
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('小テスト'),
      actions: _searchStatus
          ? [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() => _searchStatus = false)),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ]
          : [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() =>
                      setState(() => _filterStatus = !_filterStatus)),
                  icon: Icon(_filterStatus
                      ? Icons.filter_alt_rounded
                      : Icons.filter_alt_off_rounded),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: (() => setState(() {
                        _searchStatus = true;
                        _suggestQuizzes = [];
                      })),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
      bottom: buildAppBarBottom(context),
    );
  }

  Widget _buildCard(BuildContext context, Quiz quiz) {
    return Slidable(
      key: Key(quiz.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) => context
                .read<QuizRepository>()
                .setArchive(quiz.id, !quiz.isArchived)
                .then((value) => setState(() {})),
            backgroundColor: const Color(0xFF7BC043),
            foregroundColor: Colors.white,
            icon: quiz.isArchived
                ? Icons.unarchive_rounded
                : Icons.archive_rounded,
            label: quiz.isArchived ? 'アーカイブ解除' : 'アーカイブ',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (context) async =>
                context.read<ApiRepository>().fetchDetailQuiz(quiz),
            backgroundColor: const Color(0xFF0392CF),
            foregroundColor: Colors.white,
            icon: Icons.sync_rounded,
            label: '更新',
          ),
        ],
      ),
      child: ListTile(
        onTap: () async {
          if (quiz.isAcquired) {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(16.0))),
              context: context,
              builder: (context) => DraggableScrollableSheet(
                expand: false,
                builder: (context, controller) {
                  return buildQuizModal(context, quiz, controller);
                },
              ),
            );
          } else {
            await showOkCancelAlertDialog(
                      context: context,
                      title: '未取得の小テストです。',
                      message: '取得しますか？',
                      okLabel: '取得',
                      cancelLabel: 'キャンセル',
                    ) ==
                    OkCancelResult.ok
                ? context.read<ApiRepository>().fetchDetailQuiz(quiz)
                : null;
          }
        },
        leading: Icon(
          (() {
            if (quiz.isSubmitted) {
              if (quiz.endDateTime.isAfter(DateTime.now())) {
                return Icons.check_box_outlined;
              } else {
                return Icons.check_box_rounded;
              }
            } else {
              if (quiz.endDateTime.isAfter(DateTime.now())) {
                return Icons.crop_square_outlined;
              } else {
                return Icons.square_rounded;
              }
            }
          })(),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                quiz.subject,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(quiz.endDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                quiz.title,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Visibility(
              visible: quiz.fileNames?.isNotEmpty ?? false,
              child: Text(
                '${quiz.fileNames?.length ?? ''}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Visibility(
              visible: quiz.fileNames?.isNotEmpty ?? false,
              child: const Icon(Icons.file_present_rounded),
            ),
            Visibility(
              visible: quiz.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
    );
  }
}

Widget buildQuizModal(
    BuildContext context, Quiz quiz, ScrollController controller) {
  return ListView(
    controller: controller,
    padding: const EdgeInsets.all(16.0),
    children: [
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            quiz.title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(quiz.startDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const Icon(Icons.arrow_right_alt_rounded),
            Text(
              DateFormat('yyyy/MM/dd HH:mm', 'ja')
                  .format(quiz.endDateTime.toLocal()),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 4.0,
              ),
              child: Text(
                quiz.status,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary,
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                vertical: 2.0,
                horizontal: 4.0,
              ),
              child: Text(
                quiz.isSubmitted ? '提出済' : '未提出',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            Visibility(
              visible: quiz.isArchived,
              child: const Icon(Icons.archive_rounded),
            )
          ],
        ),
      ),
      const SizedBox(height: 8.0),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          quiz.isAcquired ? quiz.description : '未取得',
        ),
      ),
      const Padding(
        padding: EdgeInsets.all(4.0),
        child: Divider(thickness: 2.0),
      ),
      Padding(
        padding: const EdgeInsets.all(4.0),
        child: buildAutoLinkText(
          context,
          quiz.isAcquired ? quiz.message : '未取得',
        ),
      ),
      Visibility(
        visible: quiz.fileNames?.isNotEmpty ?? false,
        child: const Padding(
          padding: EdgeInsets.all(4.0),
          child: Divider(thickness: 2.0),
        ),
      ),
      Visibility(
        visible: quiz.fileNames?.isNotEmpty ?? false,
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: buildFileList(quiz.fileNames),
        ),
      ),
      const SizedBox(height: 8.0),
      Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<QuizRepository>()
                      .setArchive(quiz.id, !quiz.isArchived);
                  Navigator.of(context).pop();
                },
                child: Icon(quiz.isArchived
                    ? Icons.unarchive_rounded
                    : Icons.archive_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () async =>
                    context.read<ApiRepository>().fetchDetailQuiz(quiz),
                child: const Icon(Icons.sync_rounded),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4.0),
              child: ElevatedButton(
                onPressed: () => Share.share(
                    '${quiz.description}\n\n${quiz.message}',
                    subject: quiz.title),
                child: const Icon(Icons.share_rounded),
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8.0),
    ],
  );
}
