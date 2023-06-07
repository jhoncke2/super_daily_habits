import 'dart:io';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';

const idKey = 'id';

// ************ weekDays relation
const weekDaysTableName = 'week_days';
const weekDaysNameKey = 'name';
const weekDaysNameConstraint = 'week_day_name_constraint';
const weekDaysMondayValue = 'monday';
const weekDaysThursdayValue = 'thursday';
const weekDaysWednesdayValue = 'wednesday';
const weekDaysTwesdayValue = 'twesday';
const weekDaysFridayValue = 'friday';
const weekDaysSaturdayValue = 'saturday';
const weekDaysSundayValue = 'sunday';
const weekDaysHollyDayValue = 'hollyday';
// ************ days relation
const daysTableName = 'days';
const daysDateKey = 'date';
const daysDateYearKey = 'year';
const daysDateMonthKey = 'month';
const daysDateDayKey = 'day';
const daysDateWeekDayKey = 'week_day';
const daysWorkKey = 'work';
const daysRestantWorkKey = 'restant_work';
// ************ activities relation
const activitiesTableName = 'activities';
const activitiesNameKey = 'name';
const activitiesInitHourKey = 'init_hour';
const activitiesDurationKey = 'duration';
const activitiesWorkKey = 'work';
const activitiesIsRepeatableKey = 'is_repeatable';
const activitiesIsRepeatableDefaultValueConstraint = 'is_repeatable_default_value';
// ************ daysActivities relation
const daysActivitiesTableName = 'days_activities';
const daysActivitiesDayIdKey = 'day_id';
const daysActivitiesActivityIdKey = 'activity_id';
const daysActivitiesInitHourKey = 'init_hour';
const daysActivitiesDurationKey = 'duration';

abstract class DatabaseManager{
  Future<List<Map<String, dynamic>>> queryAll(String tableName);
  Future<Map<String, dynamic>> querySingleOne(String tableName, int id);
  Future<List<Map<String, dynamic>>> queryWhere(String tableName, String whereStatement, List<dynamic> whereVariables);
  Future<int> insert(String tableName, Map<String, dynamic> data);
  Future<void> update(String tableName, Map<String, dynamic> updatedData, int id);
  Future<void> remove(String tableName, int id);
  Future<void> removeAll(String tableName);
  Future<List<Map<String, dynamic>>> queryInnerJoin(String tableName1, String table1JoinedColumn, String tableName2, String table2JoinedColumn, String whereStatement, List<dynamic> whereVariables);
  Future<int> queryCount(String tableName, String whereStatement, List<dynamic> whereVariables);
  Future<void> removeWhere(String tableName, String whereStatement, List whereVariables);
}

class DataBaseManagerImpl implements DatabaseManager{
  final Database db;

  DataBaseManagerImpl({
    required this.db
  });

  @override
  Future<List<Map<String, dynamic>>> queryAll(String tableName)async{
    return await _executeOperation(()async =>
      await db.query(tableName)
    );
  }

  @override
  Future<Map<String, dynamic>> querySingleOne(String tableName, int id)async{
    return await _executeOperation(()async =>
      (await db.query(tableName, where: '$idKey = ?', whereArgs: [id]) )[0]
    );
  }

  @override
  Future<List<Map<String, dynamic>>> queryWhere(String tableName, String whereStatement, List whereArgs)async{
    return await _executeOperation(()async =>
      await db.query(tableName, where: whereStatement, whereArgs: whereArgs)
    );
  }

  @override
  Future<int> insert(String tableName, Map<String, dynamic> data)async{
    return await _executeOperation(()async =>
      await db.insert(tableName, data)
    );
  }

  @override
  Future<void> update(String tableName, Map<String, dynamic> updatedData, int id)async{
    await _executeOperation(()async =>
      await db.update(tableName, updatedData, where: '$idKey = ?', whereArgs: [id])
    );
  }

  @override
  Future<void> remove(String tableName, int id)async{
    await _executeOperation(()async =>
      await db.delete(tableName, where: '$idKey = ?', whereArgs: [id])
    );
  }

  @override
  Future<void> removeAll(String tableName)async{
    await _executeOperation(()async => 
      await db.delete(tableName)
    );
  }

  Future<dynamic> _executeOperation(Function function)async{
    try{
      return await function();
    }on PlatformException{
      throw const DBException(
        type: DBExceptionType.platform
      );
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> queryInnerJoin(String tableName1, String table1JoinedColumn, String tableName2, String table2JoinedColumn, String whereStatement, List whereVariables)async{
    final query = _formatQuery(
      '''
        SELECT * FROM $tableName1
          INNER JOIN $tableName2
          ON $tableName1.$table1JoinedColumn = $tableName2.$table2JoinedColumn
          WHERE $whereStatement
      '''
    );
    return await _executeOperation(()async =>
      await db.rawQuery(
        query,
        whereVariables
      )
    );
  }

  String _formatQuery(String query){
    final lines = query.split('\n');
    return (
      lines.map<String>(
        (line) => line.trim()
      ).toList()
    ).join('\n');
  }
  
  @override
  Future<int> queryCount(String tableName, String whereStatement, List whereVariables)async{
    final query = _formatQuery(
      '''
        SELECT COUNT($idKey)
          FROM $tableName
          WHERE $whereStatement
      '''
    );
    final response = await db.rawQuery(
      query,
      whereVariables
    );
    return Sqflite.firstIntValue(response)??0;
  }
  
  @override
  Future<void> removeWhere(String tableName, String whereStatement, List whereVariables)async{
    await _executeOperation(()async => 
      await db.delete(
        tableName,
        where: whereStatement,
        whereArgs: whereVariables
      )
    );
  }
}

class CustomDataBaseFactory{
  static const String dbName = 'super_daily_habits.db';
  static const int dbVersion = 4;

  static Future<Database> get dataBase async => await initDataBase();

  static Future<Database> initDataBase()async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, dbName);
    //await deleteDatabase(path);
    return await openDatabase(path, version: dbVersion, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version)async{
    db.execute('''
      CREATE TABLE $weekDaysTableName (
        $idKey INTEGER PRIMARY KEY,
        $weekDaysNameKey TEXT NOT NULL,
        CONSTRAINT $weekDaysNameConstraint check ($weekDaysNameKey in ("$weekDaysMondayValue", "$weekDaysThursdayValue", "$weekDaysWednesdayValue", "$weekDaysTwesdayValue", "$weekDaysFridayValue", "$weekDaysSaturdayValue", "$weekDaysSundayValue", "$weekDaysHollyDayValue"))
      )
    '''
    );
    db.execute('''
      CREATE TABLE $daysTableName (
        $idKey INTEGER PRIMARY KEY,
        $daysDateYearKey INTEGER NOT NULL,
        $daysDateMonthKey INTEGER NOT NULL,
        $daysDateDayKey INTEGER NOT NULL,
        $daysDateWeekDayKey INTEGER NOT NULL,
        $daysWorkKey INTEGER NOT NULL,
        $daysRestantWorkKey INTEGER NOT NULL
      )
    '''
    );
    db.execute(
      '''
        CREATE TABLE $activitiesTableName (
          $idKey INTEGER PRIMARY KEY,
          $activitiesNameKey TEXT NOT NULL,
          $activitiesInitHourKey TEXT NOT NULL,
          $activitiesDurationKey INTEGER NOT NULL,
          $activitiesWorkKey INTEGER NOT NULL,
          $activitiesIsRepeatableKey BIT NOT NULL
          CONSTRAINT $activitiesIsRepeatableDefaultValueConstraint DEFAULT (0)
        )
      '''
    );
    db.execute(
      '''
        CREATE TABLE $daysActivitiesTableName (
          $idKey INTEGER PRIMARY KEY,
          $daysActivitiesActivityIdKey INTEGER REFERENCES $activitiesTableName($daysActivitiesActivityIdKey),
          $daysActivitiesDayIdKey INTEGER REFERENCES $daysTableName($daysActivitiesDayIdKey),
          $daysActivitiesInitHourKey TEXT NOT NULL,
          $daysActivitiesDurationKey INTEGER NOT NULL
        )
      '''
    );
  }
}