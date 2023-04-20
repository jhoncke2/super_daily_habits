import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

class HabitActivity extends Equatable{
  final int id;
  final String name;
  final CustomTime initialHour;
  final int minutesDuration;
  final int work;
  const HabitActivity({
    required this.id,
    required this.name,
    required this.initialHour,
    required this.minutesDuration,
    required this.work
  });
  @override
  List<Object?> get props => [
    id,
    name,
    initialHour,
    minutesDuration,
    work
  ];
}