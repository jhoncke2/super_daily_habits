import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/today_repository.dart';

class TodayRepositoryImpl implements TodayRepository{
  final TodayLocalDataSource localDataSource;
  TodayRepositoryImpl({
    required this.localDataSource
  });

  @override
  Future<Day> getDayByDate(CustomDate date) async => 
    await localDataSource.getDayFromDate(date);

  @override
  Future<HabitActivity> setActivityToDay(HabitActivityCreation activity, Day day)async{
    await localDataSource.setActivityToDay(activity, day);
    throw UnimplementedError();
  }

}