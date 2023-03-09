import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gakujo_task/api/provide.dart';
import 'package:gakujo_task/models/gpa.dart';
import 'package:gakujo_task/models/grade.dart';
import 'package:gakujo_task/views/common/widget.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sticky_headers/sticky_headers.dart';

class GradePage extends StatefulWidget {
  const GradePage({Key? key}) : super(key: key);

  @override
  State<GradePage> createState() => _GradePageState();
}

class _GradePageState extends State<GradePage> {
  bool _searchStatus = false;
  List<Grade> _grades = [];
  List<Grade> _suggestGrades = [];
  Gpa _gpa = Gpa(
      {},
      '',
      0.0,
      {},
      DateTime.fromMicrosecondsSinceEpoch(0),
      null,
      '',
      0.0,
      {},
      DateTime.fromMicrosecondsSinceEpoch(0),
      0,
      0,
      0,
      0,
      null,
      {});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.wait([
        context.watch<GradeRepository>().getAll(),
        context.watch<GpaRepository>().load()
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.hasData) {
          _grades = snapshot.data![0];
          _grades.sort(((a, b) => b.compareTo(a)));
          _gpa = snapshot.data![1];
          return Scaffold(
            body: DefaultTabController(
              length: 2,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxScrolled) =>
                    [_buildAppBar(context)],
                body: TabBarView(
                  children: [_buildGrade(context), _buildGpas(context)],
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

  Widget _buildGrade(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ApiRepository>().fetchGrades(),
      child: _grades.isEmpty
          ? LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(
                            Icons.school_rounded,
                            size: 48.0,
                          ),
                        ),
                        Text(
                          '成績情報はありません',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8),
              itemCount: _searchStatus ? _suggestGrades.length : _grades.length,
              itemBuilder: (context, index) => _searchStatus
                  ? _buildCard(context, _suggestGrades[index])
                  : _buildCard(context, _grades[index]),
            ),
    );
  }

  Widget _buildGpas(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<ApiRepository>().fetchGrades(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_rounded),
                  const SizedBox(width: 8.0),
                  Text(
                    '評価別単位',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
            content: Container(),
          ),
          StickyHeader(
            header: Container(
              color: Theme.of(context).scaffoldBackgroundColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Row(
                children: [
                  const Icon(Icons.account_circle_rounded),
                  const SizedBox(width: 8.0),
                  Text(
                    '学部学科内GPA',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
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
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '算出日',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 8.0),
                      Text(DateFormat('yyyy/MM/dd', 'ja')
                          .format(_gpa.facultyCalculationDate.toLocal())),
                    ],
                  ),
                  _buildGpaChart(_gpa.departmentGpas),
                  const SizedBox(height: 16.0),
                  const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Divider(thickness: 2.0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text(
                            '学年',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(_gpa.facultyGrade),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '累積GPA',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(_gpa.facultyGpa.toString()),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            '学科内順位',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                              '${_gpa.departmentRankNumber} / ${_gpa.departmentRankDenom}'),
                        ],
                      ),
                      Column(
                        children: [
                          Text(
                            'コース内順位',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                              '${_gpa.courseRankNumber} / ${_gpa.courseRankDenom}'),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildGpaChart(Map<String, double> gpas) {
    return gpas.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              height: 320,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: LineChart(
                  LineChartData(
                    maxY: 4.5,
                    minY: 0,
                    lineBarsData: [
                      LineChartBarData(
                          spots: gpas.entries
                              .mapIndexed((index, element) =>
                                  FlSpot(index.toDouble(), element.value))
                              .toList())
                    ],
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          getTitlesWidget: (value, meta) => Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                gpas.keys
                                    .elementAt(value.toInt())
                                    .replaceAll('GPA値', '')
                                    .replaceAll('　', '\n'),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.visible),
                          ),
                        ),
                      ),
                      rightTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles:
                          AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                  ),
                  swapAnimationDuration: const Duration(milliseconds: 150),
                  swapAnimationCurve: Curves.linear,
                ),
              ),
            ),
          )
        : const SizedBox();
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
              onChanged: (value) => setState(() => _suggestGrades = _grades
                  .where((e) =>
                      e.subject.toLowerCase().contains(value.toLowerCase()))
                  .toList()),
              autofocus: true,
              textInputAction: TextInputAction.search,
            )
          : const Text('成績情報'),
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
                  onPressed: (() => setState(() {
                        _searchStatus = true;
                        _suggestGrades = [];
                      })),
                  icon: const Icon(Icons.search_rounded),
                ),
              ),
            ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48.0),
        child: Column(
          children: [
            const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.view_list_rounded)),
                Tab(icon: Icon(Icons.bar_chart_rounded)),
              ],
            ),
            buildAppBarBottom(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, Grade grade) {
    return ListTile(
      title: Row(
        children: [
          Expanded(
            child: Text(
              grade.subject,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            grade.evaluation,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Visibility(
            visible: grade.score != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                grade.score.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          Visibility(
            visible: grade.gp != null,
            child: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Text(
                grade.gp.toString(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
        ],
      ),
      subtitle: Row(
        children: [
          Text(
            grade.teacher.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              grade.selectionSection.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const Expanded(child: SizedBox()),
          Text(
            DateFormat('yyyy/MM/dd', 'ja')
                .format(grade.reportDateTime.toLocal()),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
