import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constant.dart';
import 'sss_app_state.dart';

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  DropdownSettingMenu(
                    settingName: Constants.targetPhaseSetting,
                    settingLabel: "Target Phase",
                    initialSelection: appState.getLocalUserSetting(
                            Constants.targetPhaseSetting) ??
                        Constants.targetPhaseSettingList[0],
                    textList: Constants.targetPhaseSettingList,
                  ),
                  SizedBox(width: 10),
                  // TextFormField()
                  DropdownSettingMenu(
                    settingName: Constants.minBallotChanceSetting,
                    settingLabel: "Min Ballot Chance",
                    initialSelection: appState.getLocalUserSetting(
                            Constants.minBallotChanceSetting) ??
                        Constants.minBallotChanceSettingList[0],
                    textList: Constants.minBallotChanceSettingList,
                  ),
                ],
              ),
              const Divider(),
              Row(
                children: [
                  Text('Preferred Area: '),
                ],
              ),
              RepeatedButtonSetting(
                settingName: Constants.preferredAreasSetting,
                activeIcon: Icons.home,
                inactiveIcon: Icons.home_outlined,
                settingValueList: Constants.preferredAreasSettingList,
                forceShowPreferredAreaWhenAdd: true,
              ),
              const Divider(),
              Row(
                children: [
                  Text('Preferred School Type: '),
                ],
              ),
              RepeatedButtonSetting(
                settingName: Constants.preferredSchoolTypesSetting,
                activeIcon: Icons.school,
                inactiveIcon: Icons.school_outlined,
                settingValueList: Constants.preferredSchoolTypesSettingList,
                emptyToAll: true,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class RepeatedButtonSetting extends StatefulWidget {
  const RepeatedButtonSetting({
    super.key,
    required this.settingName,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.settingValueList,
    this.emptyToAll = false,
    this.forceShowPreferredAreaWhenAdd = false,
  });

  final String settingName;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final List<String> settingValueList;
  final bool emptyToAll;
  final bool forceShowPreferredAreaWhenAdd;

  @override
  State<RepeatedButtonSetting> createState() => _RepeatedButtonSettingState();
}

class _RepeatedButtonSettingState extends State<RepeatedButtonSetting> {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    final List<String> activeSettingValueList =
        appState.getLocalListUserSettingSafe(widget.settingName);

    return Row(
      children: [
        Expanded(
          child: Wrap(
            alignment: WrapAlignment.start,
            children: [
              for (final settingValue in widget.settingValueList)
                (_) {
                  bool isSettingActive =
                      activeSettingValueList.contains(settingValue);
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: ElevatedButton.icon(
                      icon: Icon(isSettingActive
                          ? widget.activeIcon
                          : widget.inactiveIcon),
                      label: Text(
                        settingValue,
                        style: TextStyle(
                          fontWeight: isSettingActive
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      onPressed: () {
                        if (isSettingActive) {
                          activeSettingValueList.remove(settingValue);
                          if (widget.emptyToAll &&
                              activeSettingValueList.isEmpty) {
                            activeSettingValueList
                                .addAll(widget.settingValueList);
                          }
                        } else {
                          appState.showAllAreas =
                              !widget.forceShowPreferredAreaWhenAdd;
                          activeSettingValueList.add(settingValue);
                        }
                        appState.updateLocalUserSettingWithList(
                            widget.settingName, activeSettingValueList);
                      },
                    ),
                  );
                }(context)
            ],
          ),
        ),
      ],
    );
  }
}

class DropdownSettingMenu extends StatefulWidget {
  const DropdownSettingMenu({
    super.key,
    required this.settingName,
    required this.settingLabel,
    required this.initialSelection,
    required this.textList,
  });

  final String settingName;
  final String settingLabel;
  final String initialSelection;
  final List<String> textList;

  @override
  State<DropdownSettingMenu> createState() => _DropdownSettingMenuState();
}

class _DropdownSettingMenuState extends State<DropdownSettingMenu> {
  String dropdownValue = "";

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<SssAppState>();
    return DropdownMenu<String>(
      label: Text(widget.settingLabel),
      initialSelection: widget.initialSelection,
      onSelected: (String? value) {
        print('Setting ${widget.settingName} to ${value!}');
        appState.updateLocalUserSetting(widget.settingName, value);
        setState(() {
          dropdownValue = value;
        });
      },
      dropdownMenuEntries:
          widget.textList.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry<String>(value: value, label: value);
      }).toList(),
    );
  }
}
