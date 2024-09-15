import 'school_info.dart';

class PrimarySchoolBallotData {
  final int year;
  final int schoolId;
  final int slotPhase1;
  final int applicationPhase1;
  final int slotPhase2a1;
  final int applicationPhase2a1;
  final int slotPhase2a2;
  final int applicationPhase2a2;
  final int slotPhase2b;
  final int applicationPhase2b;
  final int slotPhase2c;
  final int applicationPhase2c;
  final int slotPhase2cs;
  final int applicationPhase2cs;
  final int slotPhase3;
  final int applicationPhase3;

  int get slotTotal =>
      slotPhase1 +
      slotPhase2a1 +
      slotPhase2a2 +
      slotPhase2b +
      slotPhase2c +
      slotPhase2cs +
      slotPhase3;
  int get applicationTotal =>
      applicationPhase1 +
      applicationPhase2a1 +
      applicationPhase2a2 +
      applicationPhase2b +
      applicationPhase2c +
      applicationPhase2cs +
      applicationPhase3;

  const PrimarySchoolBallotData({
    required this.year,
    required this.schoolId,
    this.slotPhase1 = 0,
    this.applicationPhase1 = 0,
    this.slotPhase2a1 = 0,
    this.applicationPhase2a1 = 0,
    this.slotPhase2a2 = 0,
    this.applicationPhase2a2 = 0,
    this.slotPhase2b = 0,
    this.applicationPhase2b = 0,
    this.slotPhase2c = 0,
    this.applicationPhase2c = 0,
    this.slotPhase2cs = 0,
    this.applicationPhase2cs = 0,
    this.slotPhase3 = 0,
    this.applicationPhase3 = 0,
  });

  PrimarySchoolBallotData.fromMap(Map<String, dynamic> ballotDataMap)
      : year = ballotDataMap['year'] as int,
        schoolId = ballotDataMap['schoolId'] as int,
        slotPhase1 = ballotDataMap['slotPhase1'] as int,
        applicationPhase1 = ballotDataMap['applicationPhase1'] as int,
        slotPhase2a1 = ballotDataMap['slotPhase2a1'] as int,
        applicationPhase2a1 = ballotDataMap['applicationPhase2a1'] as int,
        slotPhase2a2 = ballotDataMap['slotPhase2a2'] as int,
        applicationPhase2a2 = ballotDataMap['applicationPhase2a2'] as int,
        slotPhase2b = ballotDataMap['slotPhase2b'] as int,
        applicationPhase2b = ballotDataMap['applicationPhase2b'] as int,
        slotPhase2c = ballotDataMap['slotPhase2c'] as int,
        applicationPhase2c = ballotDataMap['applicationPhase2c'] as int,
        slotPhase2cs = ballotDataMap['slotPhase2cs'] as int,
        applicationPhase2cs = ballotDataMap['applicationPhase2cs'] as int,
        slotPhase3 = ballotDataMap['slotPhase3'] as int,
        applicationPhase3 = ballotDataMap['applicationPhase3'] as int;

  String chanceStrByPhase(String phase) {
    int slot = 0, appl = 0;
    if (phase.toLowerCase() == 'phase 2b') {
      slot = slotPhase2b;
      appl = applicationPhase2b;
    } else if (phase.toLowerCase() == 'phase 2c') {
      slot = slotPhase2c;
      appl = applicationPhase2c;
    } else if (phase.toLowerCase() == 'phase 2c(s)') {
      slot = slotPhase2cs;
      appl = applicationPhase2cs;
    } else if (phase.toLowerCase() == 'phase 3') {
      slot = slotPhase3;
      appl = applicationPhase3;
    } else {
      return '-';
    }

    if (slot == 0) {
      return '-';
    } else if (appl <= slot) {
      return '100%';
    } else {
      return '${((slot / appl) * 100).round()}%';
    }
  }
}

class PrimarySchoolBallotDataSql {
  static const String tableName = 'PrimarySchoolBallot';
  static const String createTable = '''
    CREATE TABLE $tableName (
        year INTEGER NOT NULL,
        schoolId INTEGER NOT NULL,
        slotPhase1 INTEGER NOT NULL,
        applicationPhase1 INTEGER NOT NULL,
        slotPhase2a1 INTEGER NOT NULL,
        applicationPhase2a1 INTEGER NOT NULL,
        slotPhase2a2 INTEGER NOT NULL,
        applicationPhase2a2 INTEGER NOT NULL,
        slotPhase2b INTEGER NOT NULL,
        applicationPhase2b INTEGER NOT NULL,
        slotPhase2c INTEGER NOT NULL,
        applicationPhase2c INTEGER NOT NULL,
        slotPhase2cs INTEGER NOT NULL,
        applicationPhase2cs INTEGER NOT NULL,
        slotPhase3 INTEGER NOT NULL,
        applicationPhase3 INTEGER NOT NULL,
        PRIMARY KEY (year, schoolId),
        FOREIGN KEY (schoolId) REFERENCES
            ${PrimarySchoolInfoSql.tableName}(id)
    );''';
}
