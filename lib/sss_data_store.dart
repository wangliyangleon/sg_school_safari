import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'constant.dart';
import 'data_model/school_info.dart';
import 'data_model/ballot_data.dart';

class SssDataStore {
  static Future<void> _rebuildSssDatabase(Database db,
      {bool dropExistingTables = false}) async {
    if (dropExistingTables) {
      print('[DB] drop existing tables first.');
      await db
          .execute('DROP TABLE IF EXISTS ${PrimarySchoolInfoSql.tableName}');
      await db.execute(
          'DROP TABLE IF EXISTS ${PrimarySchoolBallotDataSql.tableName}');
    }
    print('[DB] start building database.');
    await db.execute(PrimarySchoolInfoSql.createTable);
    await db.execute(PrimarySchoolBallotDataSql.createTable);

    {
      // Insert the primary school info records.
      List<Map<String, dynamic>> data =
          await db.query(PrimarySchoolInfoSql.tableName);
      if (data.isEmpty) {
        print('[DB] inserting table ${PrimarySchoolInfoSql.tableName}.');

        var schoolDataInput =
            await rootBundle.loadString("assets/data/schools.json");
        List allSchoolsData = jsonDecode(schoolDataInput)['schools'];
        for (var school in allSchoolsData) {
          // Insert initial data
          await db.insert(PrimarySchoolInfoSql.tableName, school);
        }

        int count = Sqflite.firstIntValue(await db.query(
                PrimarySchoolInfoSql.tableName,
                columns: ['COUNT(*)'])) ??
            0;
        print(
            '[DB] loaded $count records for table ${PrimarySchoolInfoSql.tableName}.');
      }
    }

    {
      // Insert the primary school ballot data records.
      List<Map<String, dynamic>> data =
          await db.query(PrimarySchoolBallotDataSql.tableName);
      if (data.isEmpty) {
        print('[DB] inserting table ${PrimarySchoolBallotDataSql.tableName}.');

        var ballotDataInput =
            await rootBundle.loadString("assets/data/ballot_data.json");
        Map<String, dynamic> allYearsBallotData = jsonDecode(ballotDataInput);
        for (var yearStr in allYearsBallotData.keys) {
          int year = int.tryParse(yearStr) ?? -1;
          if (year < 0) {
            print('Bad year string in the json file $yearStr.');
            continue;
          }
          for (var ballotData in allYearsBallotData[yearStr] ?? []) {
            ballotData['year'] = year;
            await db.insert(PrimarySchoolBallotDataSql.tableName, ballotData);
          }
          int count = Sqflite.firstIntValue(await db.query(
                  PrimarySchoolBallotDataSql.tableName,
                  columns: ['COUNT(*)'])) ??
              0;
          print('[DB] loaded year $year, now have $count records '
              'in table ${PrimarySchoolBallotDataSql.tableName}.');
        }
      }
    }
  }

  static Future<Database> get database async {
    final database = openDatabase(
      join(await getDatabasesPath(), Constants.dbName),
      version: Constants.dbVersion,
      onCreate: (db, version) async {
        await _rebuildSssDatabase(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        await _rebuildSssDatabase(db, dropExistingTables: true);
      },
    );

    return database;
  }
}
