import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';

abstract class DayRepository{
  Future<Day> getDayByDate(CustomDate date);
  Future<Day> setActivityToDay(HabitActivityCreation activity, Day day, int newRestantWork);
  Future<Day> createDay(DayBase day);
  Future<Day> updateActivityRestantWork(int restantWork, Day day);
  Future<Day> deleteHabitFromDay(HabitActivity habit, Day day);
}