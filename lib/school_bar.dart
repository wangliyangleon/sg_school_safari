import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sg_school_safari/constant.dart';

import 'data_model/school_info.dart';
import 'data_model/ballot_data.dart';
import 'sss_app_state.dart';

class SchoolBar extends StatefulWidget {
  const SchoolBar({
    super.key,
    required this.schoolInfo,
    required this.schoolBallotInfoYearly,
  });

  final PrimarySchoolInfo schoolInfo;
  final Map<int, PrimarySchoolBallotData> schoolBallotInfoYearly;

  @override
  State<SchoolBar> createState() => _SchoolBarState();
}

class _SchoolBarState extends State<SchoolBar> {
  bool _isExpanded = false;

  PrimarySchoolBallotData getBallotDataPerYear(int year) {
    return widget.schoolBallotInfoYearly[year] ??
        PrimarySchoolBallotData(
          schoolId: widget.schoolInfo.id,
          year: year,
        );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    if (appState.closeAllSchoolBar) {
      _isExpanded = false;
    }

    IconData saveIcon;
    if (appState.isSchoolSaved(widget.schoolInfo.name)) {
      saveIcon = Icons.favorite;
    } else {
      saveIcon = Icons.favorite_border;
    }

    final theme = Theme.of(context);
    final styleMain = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onPrimary,
    );
    final styleExpandPanelHeader = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
      fontWeight: FontWeight.bold,
    );
    final styleExpandPanelBody = theme.textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSecondaryContainer,
    );
    final cardShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(7),
    );

    String targetPhase =
        appState.getLocalUserSettingSafe(Constants.targetPhaseSetting);
    var ballotThisYear = getBallotDataPerYear(Constants.currentYear);
    return Card(
      color: theme.colorScheme.primary,
      shape: cardShape,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 1.0,
          bottom: 1.0,
          left: 15.0,
          right: 15.0,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  flex: 90,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                        print('School tapped: $_isExpanded.');
                      });
                    },
                    child: SchoolBarMainRow(
                      cellText1: widget.schoolInfo.name
                          .replaceAll(' Primary School', '')
                          .replaceAll(' School', '')
                          .trim(),
                      cellText2: widget.schoolInfo.area,
                      cellText3: widget.schoolInfo.type.name,
                      cellText4: ballotThisYear.chanceStrByPhase(targetPhase),
                      textStyle: styleMain,
                    ),
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: IconButton(
                    onPressed: () {
                      print('Like button pressed!');
                      appState.toggleSaveSchool(widget.schoolInfo.name);
                    },
                    color: theme.colorScheme.onPrimary,
                    icon: Icon(saveIcon),
                  ),
                ),
              ],
            ),
            if (_isExpanded)
              Column(
                children: [
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    shape: cardShape,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 3.0,
                      ),
                      child: Column(
                        children: [
                          ExpandPanelRow(
                            textList: [
                              'Phase',
                              '1',
                              '2A(1)',
                              '2A(2)',
                              '2B',
                              '2C',
                              '2C(S)',
                              '3',
                              'Total',
                            ],
                            styleExpandPanelCell: styleExpandPanelHeader,
                          ),
                          ExpandPanelRow(
                            textList: [
                              'Slot',
                              '${ballotThisYear.slotPhase1}',
                              '${ballotThisYear.slotPhase2a1}',
                              '${ballotThisYear.slotPhase2a2}',
                              '${ballotThisYear.slotPhase2b}',
                              '${ballotThisYear.slotPhase2c}',
                              '${ballotThisYear.slotPhase2cs}',
                              '${ballotThisYear.slotPhase3}',
                              '${ballotThisYear.slotTotal}',
                            ],
                            styleExpandPanelCell: styleExpandPanelBody,
                          ),
                          ExpandPanelRow(
                            textList: [
                              'Appl',
                              '${ballotThisYear.applicationPhase1}',
                              '${ballotThisYear.applicationPhase2a1}',
                              '${ballotThisYear.applicationPhase2a2}',
                              '${ballotThisYear.applicationPhase2b}',
                              '${ballotThisYear.applicationPhase2c}',
                              '${ballotThisYear.applicationPhase2cs}',
                              '${ballotThisYear.applicationPhase3}',
                              '${ballotThisYear.applicationTotal}',
                            ],
                            styleExpandPanelCell: styleExpandPanelBody,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    color: theme.colorScheme.secondaryContainer,
                    shape: cardShape,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        top: 3.0,
                      ),
                      child: Column(
                        children: [
                          ExpandPanelRow(
                            textList: [
                              targetPhase,
                              '2020',
                              '2021',
                              '2022',
                              '2023'
                            ],
                            styleExpandPanelCell: styleExpandPanelHeader,
                          ),
                          ExpandPanelRow(
                            textList: [
                              'Ballot%',
                              getBallotDataPerYear(2020)
                                  .chanceStrByPhase(targetPhase),
                              getBallotDataPerYear(2021)
                                  .chanceStrByPhase(targetPhase),
                              getBallotDataPerYear(2022)
                                  .chanceStrByPhase(targetPhase),
                              getBallotDataPerYear(2023)
                                  .chanceStrByPhase(targetPhase),
                            ],
                            styleExpandPanelCell: styleExpandPanelBody,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: () {
                          print('Link button pressed.');
                        },
                        iconSize: 15,
                        color: theme.colorScheme.onPrimary,
                        icon: Icon(Icons.link),
                      ),
                      // SizedBox(width: 10),
                      IconButton(
                        onPressed: () {
                          print('Share button pressed.');
                        },
                        iconSize: 15,
                        color: theme.colorScheme.onPrimary,
                        icon: Icon(Icons.share),
                      ),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class SchoolBarMainRow extends StatelessWidget {
  const SchoolBarMainRow({
    super.key,
    required this.cellText1,
    required this.cellText2,
    required this.cellText3,
    required this.cellText4,
    required this.textStyle,
  });

  final TextStyle textStyle;
  final String cellText1;
  final String cellText2;
  final String cellText3;
  final String cellText4;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 40,
          child: Text(
            cellText1,
            style: textStyle,
          ),
        ),
        Expanded(
          flex: 25,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              cellText2,
              style: textStyle,
            ),
          ),
        ),
        Expanded(
          flex: 12,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              cellText3,
              style: textStyle,
            ),
          ),
        ),
        Expanded(
          flex: 23,
          child: Padding(
            padding: const EdgeInsets.only(left: 5),
            child: Text(
              cellText4,
              style: textStyle,
            ),
          ),
        ),
      ],
    );
  }
}

class ExpandPanelRow extends StatelessWidget {
  const ExpandPanelRow({
    super.key,
    required this.textList,
    required this.styleExpandPanelCell,
  });

  final List<String> textList;
  final TextStyle styleExpandPanelCell;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var text in textList)
          Expanded(
            child: ExpandPanelCell(
              styleExpandPanel: styleExpandPanelCell,
              text: text,
            ),
          ),
      ],
    );
  }
}

class ExpandPanelCell extends StatelessWidget {
  const ExpandPanelCell({
    super.key,
    required this.styleExpandPanel,
    required this.text,
  });

  final TextStyle styleExpandPanel;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 3.0,
      ),
      child: Text(
        text,
        style: styleExpandPanel,
      ),
    );
  }
}
