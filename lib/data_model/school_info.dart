enum SchoolType { boys, girls, mixed }

class PrimarySchoolInfo {
  final int id;
  final String name;
  final String area;
  final SchoolType type;
  final String funding;
  final String website;
  final String emblemUrl;
  final double googleMapScore;

  // Constructor with named parameters
  const PrimarySchoolInfo({
    required this.id,
    required this.name,
    required this.area,
    required this.type,
    required this.funding,
    this.website = '',
    this.emblemUrl = '',
    this.googleMapScore = 0.0,
  });

  PrimarySchoolInfo.fromMap(Map<String, dynamic> schoolInfoMap)
      : id = schoolInfoMap['id'] as int,
        name = schoolInfoMap['name'] as String,
        area = schoolInfoMap['area'] as String,
        type = SchoolType.values
            .byName(schoolInfoMap['type'].toString().toLowerCase()),
        funding = schoolInfoMap['funding'] as String,
        website = schoolInfoMap['website'] as String,
        emblemUrl = schoolInfoMap['emblemUrl'] as String,
        googleMapScore = schoolInfoMap['googleMapScore'] as double;
}

class PrimarySchoolInfoSql {
  static const String tableName = 'PrimarySchools';
  static const String createTable = '''
    CREATE TABLE $tableName (
        code INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        area TEXT NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('boys', 'girls', 'mixed')),
        website TEXT,
    );''';
}
