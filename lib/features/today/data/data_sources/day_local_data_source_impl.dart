import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';

class DayLocalDataSourceImpl implements DayLocalDataSource{
  static const dayByDateQuery = '$daysDateKey = ?';
  static const dayByIdInnerJoinQuery = '$daysActivitiesTableName.$daysActivitiesDayIdKey = ?';
  static const activityByIdOnDaysActivitiesQuery = '$daysActivitiesActivityIdKey = ?';
  static const activitiesByRepeatablesQuery = '$activitiesIsRepeatableKey = ?';
  final DatabaseManager dbManager;
  final DayLocalAdapter adapter;
  DayLocalDataSourceImpl({
    required this.dbManager,
    required this.adapter
  });
  
  @override
  Future<Day> getDayFromDate(CustomDate date)async{
    final stringJsonDate = adapter.getStringMapFromDate(date);
    final jsonDays = await dbManager.queryWhere(
      daysTableName,
      dayByDateQuery,
      [stringJsonDate]
    );
    if(jsonDays.isNotEmpty){
      final jsonDay = jsonDays[0];
      final jsonActivities = await dbManager.queryInnerJoin(
        daysActivitiesTableName,
        daysActivitiesActivityIdKey,
        activitiesTableName,
        idKey,
        dayByIdInnerJoinQuery,
        [jsonDay[idKey]]
      );
      return adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities);
    }else{
      throw const DBException(
        type: DBExceptionType.empty
      );
    }
  }

  @override
  Future<void> setActivityToDay(HabitActivityCreation activity, Day day)async{
    late int activityId;
    if(activity.repeatability == ActivityRepeatability.repeated){
      activityId = activity.repeatedActivity!.id;
    }else{
      final jsonActivityToCreate = adapter.getMapFromActivity(activity);
      activityId = await dbManager.insert(activitiesTableName, jsonActivityToCreate);
    }
    final createdActivity = HabitActivity(
      id: activityId,
      name: activity.name,
      minutesDuration: activity.minutesDuration,
      work: activity.work,
      initialTime: activity.initialTime!
    );
    final jsonDayActivity = adapter.getMapFromDayIdAndActivityId(day.id, createdActivity);
    await dbManager.insert(daysActivitiesTableName, jsonDayActivity);
  }
  
  @override
  Future<Day> getDayById(int id)async{
    final jsonDay = await dbManager.querySingleOne(daysTableName, id);
    final jsonActivities = await dbManager.queryInnerJoin(
      daysActivitiesTableName,
      daysActivitiesActivityIdKey,
      activitiesTableName,
      idKey,
      dayByIdInnerJoinQuery,
      [id]
    );
    return adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities);
  }

  @override
  Future<void> setDay(DayBase day)async{
    final jsonDay = adapter.getMapFromDay(day);
    await dbManager.insert(
      daysTableName,
      jsonDay
    );
  }
  
  @override
  Future<void> updateRestantWork(int restantWork, Day day)async{
    final updatedDay = DayBase(
      date: day.date,
      totalWork: day.totalWork,
      restantWork: restantWork
    );
    final jsonDay = adapter.getMapFromDay(updatedDay);
    await dbManager.update(
      daysTableName,
      jsonDay,
      day.id
    );
  }

  @override
  Future<void> deleteActivityFromDay(HabitActivity habit, Day day)async{
    await dbManager.removeWhere(
      daysActivitiesTableName,
      activityByIdOnDaysActivitiesQuery,
      [habit.id]
    );
    await dbManager.queryCount(
      daysActivitiesTableName,
      activityByIdOnDaysActivitiesQuery,
      [habit.id]
    );
  }
  
  @override
  Future<List<HabitActivity>> getAllRepeatableActivities()async{
    final dbActivities = await dbManager.queryWhere(
      activitiesTableName,
      activitiesByRepeatablesQuery,
      [1]
    );
    return adapter.getActivitiesFromJson(dbActivities);
  }
}