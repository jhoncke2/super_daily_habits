import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';

class TodayLocalDataSourceImpl implements TodayLocalDataSource{
  static const dayByDateQuery = '$daysDateKey = ?';
  static const dayByIdInnerJoinQuery = '$daysActivitiesTableName.$daysActivitiesDayIdKey = ?';
  final DatabaseManager dbManager;
  final TodayLocalAdapter adapter;
  TodayLocalDataSourceImpl({
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
      return adapter.getEmptyDayFromMap(jsonDays[0]);
    }else{
      throw const DBException(
        type: DBExceptionType.empty
      );
    }
  }

  @override
  Future<void> setActivityToDay(HabitActivityCreation activity, Day day)async{
    final jsonActivity = adapter.getMapFromActivity(activity);
    final activityId = await dbManager.insert(activitiesTableName, jsonActivity);
    final jsonDayActivity = adapter.getMapFromDayIdAndActivityId(day.id, activityId);
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
}