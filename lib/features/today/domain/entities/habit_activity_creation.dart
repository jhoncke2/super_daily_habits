import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

class HabitActivityCreation extends Equatable{
  final String name;
  final CustomTime initialTime;
  final int minutesDuration;
  final int work;
  const HabitActivityCreation({
    required this.name,
    required this.initialTime,
    required this.minutesDuration,
    required this.work
  });
  @override
  List<Object?> get props => [
    name,
    initialTime,
    minutesDuration,
    work
  ];
}