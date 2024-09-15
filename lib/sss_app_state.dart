import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constant.dart';

class SssAppState extends ChangeNotifier {
  var savedSchool = <String>[];

  // Global state to control the explore page.
  int openedPageNum = 0;
  bool showAllAreas = true;
  bool closeAllSchoolBar = false;

  bool settingReloadRequired = true;
  Map<String, String> _localUserSettings = {};

  void reloadLocalUserSettings() async {
    var prefs = await SharedPreferences.getInstance();
    final settings = [
      Constants.targetPhaseSetting,
      Constants.preferredAreasSetting,
      Constants.preferredSchoolTypesSetting,
      Constants.minBallotChanceSetting,
    ];
    final settingDefaultValuess = [
      Constants.targetPhaseSettingList[0],
      '',
      Constants.preferredSchoolTypesSettingValueAll,
      Constants.minBallotChanceSettingList[0],
    ];
    for (var (index, setting) in settings.indexed) {
      if (prefs.getString(setting) == null) {
        _localUserSettings[setting] = settingDefaultValuess[index];
        prefs.setString(setting, settingDefaultValuess[index]);
      } else {
        _localUserSettings[setting] = prefs.getString(setting) ?? '';
      }
    }
    settingReloadRequired = false;
    print('Loaded setting map $_localUserSettings');
  }

  void updateLocalUserSetting(String key, String value) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
    print('Updating setting $key to $value');
    openedPageNum = 0;
    settingReloadRequired = true;
    notifyListeners();
  }

  void updateLocalUserSettingWithList(String key, List<String> values) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, values.join(','));
    print('Updating setting $key to $values');
    openedPageNum = 0;
    settingReloadRequired = true;
    notifyListeners();
  }

  String? getLocalUserSetting(String key) {
    return _localUserSettings[key];
  }

  List<String>? getLocalListUserSetting(String key) {
    return _localUserSettings[key]?.split(',');
  }

  String getLocalUserSettingSafe(String key) {
    return _localUserSettings[key] ?? '';
  }

  List<String> getLocalListUserSettingSafe(String key) {
    return _localUserSettings[key]
            ?.split(',')
            .where((e) => e.isNotEmpty)
            .toList() ??
        [];
  }

  bool isSchoolSaved(String name) {
    return savedSchool.contains(name);
  }

  void toggleSaveSchool(String name) {
    if (isSchoolSaved(name)) {
      savedSchool.remove(name);
    } else {
      savedSchool.add(name);
    }
    notifyListeners();
  }
}
