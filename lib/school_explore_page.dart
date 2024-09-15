import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_school_safari/constant.dart';
import 'package:sqflite/sqflite.dart';

import 'school_bar.dart';
import 'sss_app_state.dart';
import 'sss_data_store.dart';
import 'data_model/school_info.dart';
import 'data_model/ballot_data.dart';

class PrimarySchoolInfoWithYearlyBallotData {
  final PrimarySchoolInfo schoolInfo;
  final Map<int, PrimarySchoolBallotData> schoolBallotInfoYearly;

  PrimarySchoolInfoWithYearlyBallotData({
    required this.schoolInfo,
    required this.schoolBallotInfoYearly,
  });
}

class SchoolExplorePage extends StatefulWidget {
  @override
  State<SchoolExplorePage> createState() => _SchoolExplorePageState();
}

class _SchoolExplorePageState extends State<SchoolExplorePage> {
  bool _hasNextPage = false;
  bool _showAllSchools = true;
  bool _showConfigCard = true;
  static const _pageSize = 7;

  // Main function to load the schools with ballot data for the current page.
  Future<List<PrimarySchoolInfoWithYearlyBallotData>>
      _loadCurrentPageSchoolsInfoWithBallotData(
    int pageNum, {
    List<String> preferedAreas = const [],
    List<String> preferredSchoolTypes =
        Constants.preferredSchoolTypesSettingList,
    String filterPhase = '',
    int filterBallotChance = 0,
  }) async {
    final db = await SssDataStore.database;
    final String areaFilter =
        _showAllSchools ? '' : ' AND area in ("${preferedAreas.join('","')}")';
    final String typeFilter = preferredSchoolTypes.isEmpty
        ? ''
        : ' AND type in ("${preferredSchoolTypes.join('","')}")';
    final String ballotChanceFilter =
        _getBallotFilterSql(filterPhase, filterBallotChance);

    const String schoolTb = PrimarySchoolInfoSql.tableName;
    const String ballotTb = PrimarySchoolBallotDataSql.tableName;
    final String tableName = ballotChanceFilter.isEmpty
        ? schoolTb
        : '$schoolTb INNER JOIN $ballotTb ON '
            '    $schoolTb.id = $ballotTb.schoolId AND '
            '    $ballotTb.year = ${Constants.currentYear}';

    final schools = await db.query(
      tableName,
      limit: _pageSize + 1,
      offset: pageNum * _pageSize,
      orderBy: 'area ASC, type DESC, name ASC',
      where: ['TRUE', typeFilter, areaFilter, ballotChanceFilter].join(),
    );

    _hasNextPage = schools.length > _pageSize;
    final countToShow = min(schools.length, _pageSize);
    print('[DB] get $countToShow schools for page $pageNum.'
        ' Has next page: $_hasNextPage');
    return [
      for (final school in schools.sublist(0, countToShow))
        await _getPrimarySchoolInfoWithYearlyBallotData(school, db)
    ];
  }

  String _getBallotFilterSql(String filterPhase, int filterBallotChance) {
    if (filterBallotChance <= 0) {
      return '';
    }
    final String slotField;
    final String applField;
    switch (filterPhase.toLowerCase()) {
      case 'phase 2b':
        slotField = 'slotPhase2b';
        applField = 'applicationPhase2b';
      case 'phase 2c':
        slotField = 'slotPhase2c';
        applField = 'applicationPhase2c';
      case 'phase 2c(s)':
        slotField = 'slotPhase2cs';
        applField = 'applicationPhase2cs';
      case 'phase 3':
        slotField = 'slotPhase3';
        applField = 'applicationPhase3';
      default:
        return '';
    }
    if (filterBallotChance >= 100) {
      return ' AND ($slotField > 0 AND $slotField >= $applField)';
    } else {
      return ' AND ($slotField > 0 AND $slotField * 1.0 / $applField >= 0.$filterBallotChance)';
    }
  }

  Future<PrimarySchoolInfoWithYearlyBallotData>
      _getPrimarySchoolInfoWithYearlyBallotData(
    Map<String, Object?> schoolInfoMap,
    Database db,
  ) async {
    var schoolInfo = PrimarySchoolInfo.fromMap(schoolInfoMap);

    Map<int, PrimarySchoolBallotData> schoolBallotInfoYearly = {};
    final List<Map<String, Object?>> yearlyBallotData = await db.query(
      PrimarySchoolBallotDataSql.tableName,
      where: "schoolId = ?",
      whereArgs: [schoolInfo.id],
    );
    print(
        '[DB] get ${yearlyBallotData.length} years data for ${schoolInfo.name}');

    for (var ballotData in yearlyBallotData) {
      schoolBallotInfoYearly[ballotData['year'] as int] =
          PrimarySchoolBallotData.fromMap(ballotData);
    }
    return PrimarySchoolInfoWithYearlyBallotData(
      schoolInfo: schoolInfo,
      schoolBallotInfoYearly: schoolBallotInfoYearly,
    );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      appState.closeAllSchoolBar = false;
    });

    _showAllSchools = appState.showAllAreas;

    return FutureBuilder<List<PrimarySchoolInfoWithYearlyBallotData>>(
      future: _loadCurrentPageSchoolsInfoWithBallotData(
        appState.openedPageNum,
        preferedAreas: appState
            .getLocalListUserSettingSafe(Constants.preferredAreasSetting),
        preferredSchoolTypes: appState
            .getLocalListUserSettingSafe(Constants.preferredSchoolTypesSetting),
        filterPhase:
            appState.getLocalUserSettingSafe(Constants.targetPhaseSetting),
        filterBallotChance: int.tryParse(appState
                .getLocalUserSettingSafe(Constants.minBallotChanceSetting)) ??
            0,
      ),
      builder: (BuildContext context,
          AsyncSnapshot<List<PrimarySchoolInfoWithYearlyBallotData>> snapshot) {
        if (snapshot.hasData) {
          var theme = Theme.of(context);
          final cardShape = RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(7),
          );

          return Scaffold(
            appBar: AppBar(
              title: const Text('SG School Safari'),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    color: theme.colorScheme.primaryFixed,
                    shape: cardShape,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 1.0,
                        bottom: 1.0,
                        left: 15.0,
                        right: 15.0,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 90,
                            child: SchoolBarMainRow(
                                cellText1: 'Name',
                                cellText2: 'Area',
                                cellText3: 'Type',
                                cellText4:
                                    '${appState.getLocalUserSettingSafe(Constants.targetPhaseSetting)}\n'
                                    ' >= ${appState.getLocalUserSettingSafe(Constants.minBallotChanceSetting)} %',
                                textStyle: theme.textTheme.bodySmall!.copyWith(
                                  color: theme.colorScheme.onPrimaryFixed,
                                  fontWeight: FontWeight.bold,
                                )),
                          ),
                          Expanded(
                            flex: 10,
                            child: IconButton(
                              color: theme.colorScheme.onPrimaryFixed,
                              icon: Icon(Icons.favorite_border),
                              onPressed: null,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  for (var school in snapshot.data!)
                    SchoolBar(
                      schoolInfo: school.schoolInfo,
                      schoolBallotInfoYearly: school.schoolBallotInfoYearly,
                    ),
                ],
              ),
            ),
            floatingActionButton: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_showConfigCard)
                  SizedBox(
                    width: 320,
                    child: Card(
                      color:
                          theme.colorScheme.primaryContainer.withOpacity(0.7),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    print('Prev page button pressed!');
                                    if (appState.openedPageNum > 0) {
                                      setState(() {
                                        appState.closeAllSchoolBar = true;
                                        appState.openedPageNum--;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.skip_previous),
                                  label: Text('Prev'),
                                ),
                                SizedBox(
                                    width: 30,
                                    child: Center(
                                      child: Text(
                                        '${appState.openedPageNum + 1}'
                                            .padLeft(2, " "),
                                      ),
                                    )),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    print('Next page button pressed!');
                                    if (_hasNextPage) {
                                      setState(() {
                                        appState.closeAllSchoolBar = true;
                                        appState.openedPageNum++;
                                      });
                                    }
                                  },
                                  icon: Icon(Icons.skip_next),
                                  label: Text('Next'),
                                ),
                              ],
                            ),
                            SizedBox(height: 3),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  icon: _showAllSchools
                                      ? Icon(Icons.house_outlined)
                                      : Icon(Icons.house),
                                  onPressed: () {
                                    setState(() {
                                      appState.closeAllSchoolBar = true;
                                      appState.showAllAreas =
                                          !appState.showAllAreas;
                                      appState.openedPageNum = 0;
                                    });
                                  },
                                  label: Text(_showAllSchools
                                      ? 'Show Preferred Area'
                                      : 'Show All Area'),
                                ),
                                SizedBox(width: 10),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showConfigCard = false;
                                    });
                                  },
                                  color: theme.colorScheme.secondary,
                                  icon: Icon(Icons.remove_red_eye_outlined),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (!_showConfigCard)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showConfigCard = true;
                      });
                    },
                    // iconSize: 20,
                    color: theme.colorScheme.onPrimaryContainer,
                    icon: Icon(Icons.remove_red_eye),
                  ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('School info loading error... ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }
}
