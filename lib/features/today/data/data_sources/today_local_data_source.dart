import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';

abstract class TodayLocalDataSource{
  Future<void> setDay(DayBase day);
  Future<Day> getDayFromDate(CustomDate date);
  Future<Day> getDayById(int id);
  Future<void> setActivityToDay(HabitActivityCreation activity, Day day);
  Future<void> updateRestantWork(int restantWork, Day day);
}