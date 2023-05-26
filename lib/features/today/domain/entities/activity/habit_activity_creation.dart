import 'package:super_daily_habits/features/today/domain/entities/activity/activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

enum ActivityRepeatability{
  repeatable,
  repeated,
  none
}

class HabitActivityCreation extends Activity{
  final CustomTime? initialTime;
  final ActivityRepeatability repeatability;
  const HabitActivityCreation({
    required super.name,
    required super.minutesDuration,
    required super.work,
    required this.initialTime,
    required this.repeatability
  });
  @override
  List<Object?> get props => [
    ...super.props,
    initialTime,
    repeatability
  ];
}