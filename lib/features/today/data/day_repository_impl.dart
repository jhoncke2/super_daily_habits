import 'package:super_daily_habits/features/today/data/data_sources/day_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
import 'package:super_daily_habits/features/today/domain/day_repository.dart';

class DayRepositoryImpl implements DayRepository{
  final DayLocalDataSource localDataSource;
  DayRepositoryImpl({
    required this.localDataSource
  });

  @override
  Future<Day> getDayByDate(CustomDate date) async => 
    await localDataSource.getDayFromDate(date);

  @override
  Future<Day> setActivityToDay(HabitActivityCreation activity, Day day, int newRestantWork)async{
    await localDataSource.setActivityToDay(activity, day);
    await localDataSource.updateRestantWork(newRestantWork, day);
    return await localDataSource.getDayById(day.id);
  }

  @override
  Future<Day> createDay(DayBase day)async{
    await localDataSource.setDay(day);
    return await localDataSource.getDayFromDate(day.date);
  }
  
  @override
  Future<Day> updateActivityRestantWork(int restantWork, Day day)async{
    await localDataSource.updateRestantWork(restantWork, day);
    return await localDataSource.getDayById(day.id);
  }

  @override
  Future<Day> deleteHabitFromDay(HabitActivity habit, Day day)async{
    // TODO: implement deleteHabitFromDay
    throw UnimplementedError();
  }
}