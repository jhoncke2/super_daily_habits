import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart';

abstract class TodayRepository{
  Future<Day> getDayByDate(CustomDate date);
  Future<HabitActivity> setActivityToDay(HabitActivityCreation activity, Day day);
}