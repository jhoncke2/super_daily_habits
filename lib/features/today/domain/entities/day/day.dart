import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';

class Day extends DayBase{
  final int id;
  final List<HabitActivity> activities;
  const Day({
    required this.id,
    required this.activities,
    required super.date,
    required super.work
  });
  @override
  List<Object?> get props => [
    ...super.props,
    id,
    activities
  ];
}