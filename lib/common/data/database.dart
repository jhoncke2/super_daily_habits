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
const weekDaysNameConstraintName = 'week_day_name_constraint';
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
const daysWeekDayIdKey = 'week_day';
const dayWorkKey = 'work';
// ************ activities relation
const activitiesTableName = 'activities';
const activitiesNameKey = 'name';
const activitiesInitHourKey = 'init_hour';
const activitiesDurationKey = 'duration';
const activitiesWorkKey = 'work';
// ************ daysActivities relation
const daysActivitiesTableName = 'days_activities';
const daysActivitiesActivityIdKey = 'activity_id';
const daysActivitiesDayIdKey = 'day_id';



abstract class DatabaseManager{
  Future<List<Map<String, dynamic>>> queryAll(String tableName);
  Future<Map<String, dynamic>> querySingleOne(String tableName, int id);
  Future<List<Map<String, dynamic>>> queryWhere(String tableName, String whereStatement, List<dynamic> whereVariables);
  Future<int> insert(String tableName, Map<String, dynamic> data);
  Future<void> update(String tableName, Map<String, dynamic> updatedData, int id);
  Future<void> remove(String tableName, int id);
  Future<void> removeAll(String tableName);
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
}

class CustomDataBaseFactory{
  static const String DB_NAME = 'super_daily_habits.db';
  static const int DB_VERSION = 1;

  static Future<Database> get dataBase async => await initDataBase();

  static Future<Database> initDataBase()async{
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, DB_NAME);
    //await deleteDatabase(path);
    return await openDatabase(path, version: DB_VERSION, onCreate: _onCreate);
  }

  static Future _onCreate(Database db, int version)async{
    db.execute('''
      CREATE TABLE $weekDaysTableName (
        $idKey INTEGER PRIMARY KEY,
        $weekDaysNameKey TEXT NOT NULL,
        CONSTRAINT $weekDaysNameConstraintName check ($weekDaysNameKey in ($weekDaysMondayValue, $weekDaysThursdayValue, $weekDaysWednesdayValue, $weekDaysTwesdayValue, $weekDaysFridayValue, $weekDaysSaturdayValue, $weekDaysSundayValue, $weekDaysHollyDayValue))
      )
    '''
    );
    db.execute('''
      CREATE TABLE $daysTableName (
        $idKey INTEGER PRIMARY KEY,
        $daysDateKey TEXT NOT NULL,
        $daysWeekDayIdKey INTEGER,
        $dayWorkKey INTEGER,
        $daysWeekDayIdKey INTEGER REFERENCES $weekDaysTableName($daysWeekDayIdKey)
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
          $activitiesWorkKey INTEGER NOT NULL
        )
      '''
    );
    db.execute(
      '''
        CREATE TABLE $daysActivitiesTableName (
          $idKey INTEGER PRIMARY KEY,
          $daysActivitiesActivityIdKey INTEGER REFERENCES $activitiesTableName($daysActivitiesActivityIdKey),
          $daysActivitiesDayIdKey INTEGER REFERENCES $daysTableName($daysActivitiesDayIdKey)
        )
      '''
    );
  }
}