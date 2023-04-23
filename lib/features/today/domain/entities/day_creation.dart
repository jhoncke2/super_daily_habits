import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';

enum WeekDay{
  monday,
  thursday,
  wednesday,
  twesday,
  friday,
  saturday,
  sunday,
  hollyday
}

class DayCreation extends Equatable{
  final CustomDate date;
  final List<HabitActivity> activities;
  final int work;
  const DayCreation({
    required this.date,
    required this.activities,
    required this.work
  });
  @override
  List<Object?> get props => [
    date,
    activities,
    work
  ];
}