import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity.dart';

class Day extends Equatable{
  final int id;
  final String weekDay;
  final List<HabitActivity> activities;
  final int work;
  Day({
    required this.id,
    required this.weekDay,
    required this.activities,
    required this.work
  });
  @override
  List<Object?> get props => [
    id,
    weekDay,
    activities,
    work
  ];
}