import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/api.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/app.dart';
import 'package:gakujo_task/models/class_link.dart';
import 'package:gakujo_task/models/contact.dart';
import 'package:gakujo_task/models/grade.dart';
import 'package:gakujo_task/models/quiz.dart';
import 'package:gakujo_task/models/report.dart';
import 'package:gakujo_task/models/settings.dart';
import 'package:gakujo_task/models/shared_file.dart';
import 'package:gakujo_task/models/subject.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class SettingsWidget extends StatefulWidget {
  const SettingsWidget({Key? key}) : super(key: key);

  @override
  State<SettingsWidget> createState() => _SettingsWidgetState();
}

class _SettingsWidgetState extends State<SettingsWidget> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  var _isObscure = true;

  @override
  void initState() {
    super.initState();
    initValue();
  }

  void initValue() {
    navigatorKey.currentContext?.watch<SettingsRepository>().load().then(
      (value) {
        setState(
          () {
            _usernameController =
                TextEditingController(text: value.username ?? '');
            _passwordController =
                TextEditingController(text: value.password ?? '');
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: FutureBuilder(
        future: context.watch<SettingsRepository>().load(),
        builder: (context, AsyncSnapshot<Settings> snapshot) {
          return snapshot.hasData
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.account_circle_rounded),
                            const SizedBox(width: 8.0),
                            Text(
                              'アカウント',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      content: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '静大ID',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                      controller: _usernameController),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    'パスワード',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 3,
                                  child: TextField(
                                    controller: _passwordController,
                                    obscureText: _isObscure,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(_isObscure
                                            ? Icons.visibility_off_rounded
                                            : Icons.visibility_rounded),
                                        onPressed: () => setState(
                                            () => _isObscure = !_isObscure),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: () async {
                                  context
                                      .read<SettingsRepository>()
                                      .setUsername(_usernameController.text);
                                  context
                                      .read<SettingsRepository>()
                                      .setPassword(_passwordController.text);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.save_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '保存',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Divider(thickness: 2.0),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '取得年度',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    snapshot.data!.year?.toString() ?? '-',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("取得年度"),
                                              content: SizedBox(
                                                width: 360,
                                                height: 360,
                                                child: YearPicker(
                                                  firstDate: DateTime(
                                                      DateTime.now().year - 5,
                                                      1),
                                                  lastDate: DateTime(
                                                      DateTime.now().year + 5,
                                                      1),
                                                  initialDate: snapshot
                                                              .data!.year ==
                                                          null
                                                      ? DateTime.now()
                                                      : DateTime(
                                                          snapshot.data!.year!),
                                                  selectedDate: snapshot
                                                              .data!.year ==
                                                          null
                                                      ? DateTime.now()
                                                      : DateTime(
                                                          snapshot.data!.year!),
                                                  onChanged:
                                                      (DateTime dateTime) {
                                                    context
                                                        .read<
                                                            SettingsRepository>()
                                                        .setYear(dateTime.year);
                                                    Navigator.pop(context);
                                                  },
                                                ),
                                              ),
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '選択',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    '取得学期',
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Text(
                                    (() {
                                      switch (snapshot.data!.semester) {
                                        case 0:
                                          return '前期前半';
                                        case 1:
                                          return '前期後半';
                                        case 2:
                                          return '後期前半';
                                        case 3:
                                          return '後期後半';
                                        default:
                                          return '-';
                                      }
                                    })(),
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                        foregroundColor: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                      ),
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return SimpleDialog(
                                              title: const Text('取得学期'),
                                              children: [
                                                SimpleDialogOption(
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                            SettingsRepository>()
                                                        .setSemester(0);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('前期前半'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                            SettingsRepository>()
                                                        .setSemester(1);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('前期後半'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                            SettingsRepository>()
                                                        .setSemester(2);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('後期前半'),
                                                ),
                                                SimpleDialogOption(
                                                  onPressed: () async {
                                                    context
                                                        .read<
                                                            SettingsRepository>()
                                                        .setSemester(3);
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('後期後半'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          '選択',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyLarge!
                                              .copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Divider(thickness: 2.0),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                                onPressed: () async {
                                  await showOkCancelAlertDialog(
                                            context: context,
                                            message: '実行しますか？',
                                            okLabel: '実行',
                                            cancelLabel: 'キャンセル',
                                          ) ==
                                          OkCancelResult.ok
                                      ? context
                                          .read<ApiRepository>()
                                          .fetchLogin()
                                      : null;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.login_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'ログイン',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onPrimary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () async {
                                  var result = await showOkCancelAlertDialog(
                                    isDestructiveAction: true,
                                    context: context,
                                    title: '初期化するとすべてのデータが削除されます。',
                                    message: '初期化しますか？',
                                    okLabel: '初期化',
                                    cancelLabel: 'キャンセル',
                                  );
                                  if (result == OkCancelResult.ok) {
                                    {
                                      navigatorKey.currentContext
                                          ?.read<ContactRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<SubjectRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<SettingsRepository>()
                                          .delete();
                                      navigatorKey.currentContext
                                          ?.read<ReportRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<QuizRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<GradeRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<SharedFileRepository>()
                                          .deleteAll();
                                      navigatorKey.currentContext
                                          ?.read<ClassLinkRepository>()
                                          .deleteAll();
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.delete_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        '初期化',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    StickyHeader(
                      header: Container(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          children: [
                            const Icon(Icons.developer_mode_rounded),
                            const SizedBox(width: 8.0),
                            Text(
                              '開発者向け',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      content: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.error,
                                  foregroundColor:
                                      Theme.of(context).colorScheme.onError,
                                ),
                                onPressed: () async {
                                  await showOkCancelAlertDialog(
                                            context: context,
                                            message: '取得しますか？',
                                            okLabel: '取得',
                                            cancelLabel: 'キャンセル',
                                          ) ==
                                          OkCancelResult.ok
                                      ? context
                                          .read<ApiRepository>()
                                          .fetchTimetables()
                                      : null;
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.developer_board_rounded),
                                      const SizedBox(width: 8.0),
                                      Text(
                                        'テスト',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .onError),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Align(
                                alignment: Alignment.topLeft,
                                child: FutureBuilder(
                                  future: PackageInfo.fromPlatform(),
                                  builder: (context,
                                      AsyncSnapshot<PackageInfo> snapshot) {
                                    return Text(
                                      snapshot.hasData
                                          ? 'Client Version: ${snapshot.data!.version}\nAPI Version: ${Api.version}'
                                          : 'Client Version: \nAPI Version: ',
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                )
              : const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
      ),
      title: const Text('設定'),
      bottom: buildAppBarBottom(context),
    );
  }
}
