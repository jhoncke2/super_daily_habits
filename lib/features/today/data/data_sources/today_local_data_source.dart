import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart';

abstract class TodayLocalDataSource{
  Future<Day> getDayFromDate(CustomDate date);
  Future<void> setActivityToDay(HabitActivityCreation activity, Day day);
}