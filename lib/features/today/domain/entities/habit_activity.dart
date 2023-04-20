import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart';

class HabitActivity extends HabitActivityCreation{
  final int id;
  const HabitActivity({
    required super.name,
    required super.initialTime,
    required super.minutesDuration,
    required super.work,
    required this.id,
  });
  @override
  List<Object?> get props => [
    id
  ];
}