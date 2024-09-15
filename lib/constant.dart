class Constants {
  static const int currentYear = 2024;
  // For database.
  static const String dbName = 'school_database.db';
  static const int dbVersion = 3;

  // For global settings.
  static const String targetPhaseSetting = 'target_phase';
  static const List<String> targetPhaseSettingList = <String>[
    'Phase 2B',
    'Phase 2C',
    'Phase 2C(S)',
    'Phase 3'
  ];
  static const String preferredAreasSetting = 'preferred_areas';
  static const List<String> preferredAreasSettingList = <String>[
    "Ang Mo Kio",
    "Bedok",
    "Bishan",
    "Bukit Batok",
    "Bukit Merah",
    "Bukit Panjang",
    "Bukit Timah",
    "Central",
    "Chua Chu Kang",
    "Clementi",
    "Dover",
    "Geylang",
    "Hougang",
    "Jurong East",
    "Jurong West",
    "Kallang",
    "Katong",
    "Marine Parade",
    "Novena",
    "Pasir Ris",
    "Potong Pasir",
    "Punggol",
    "Queenstown",
    "Rochor",
    "Sembawang",
    "Sengkang",
    "Serangoon",
    "Tampines",
    "Toa Payoh",
    "Woodlands",
    "Yishun"
  ];
  static const String preferredSchoolTypesSetting = 'preferred_school_types';
  static const List<String> preferredSchoolTypesSettingList = <String>[
    "mixed",
    "girls",
    "boys",
  ];
  static String get preferredSchoolTypesSettingValueAll =>
      preferredSchoolTypesSettingList.join(',');

  static const String minBallotChanceSetting = 'min_ballot_chance';
  static const List<String> minBallotChanceSettingList = <String>[
    "0",
    "10",
    "20",
    "30",
    "40",
    "50",
    "60",
    "70",
    "80",
    "90",
    "100",
  ];
}
