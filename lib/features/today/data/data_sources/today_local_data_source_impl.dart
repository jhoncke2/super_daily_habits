import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

class TodayLocalDataSourceImpl implements TodayLocalDataSource{
  final DatabaseManager dbManager;
  TodayLocalDataSourceImpl({
    required this.dbManager
  });
  
  @override
  Future<Day> getDayFromDate(CustomDate date)async{
    // TODO: implement getDayFromDate
    throw UnimplementedError();
  }

  @override
  Future<void> setActivityToDay(HabitActivity activity, Day day)async{
    // TODO: implement setActivityToDay
    throw UnimplementedError();
  }
}