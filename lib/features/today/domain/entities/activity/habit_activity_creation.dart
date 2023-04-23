import 'package:super_daily_habits/features/today/domain/entities/activity/activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

class HabitActivityCreation extends Activity{
  final CustomTime? initialTime;
  const HabitActivityCreation({
    required super.name,
    required super.minutesDuration,
    required super.work,
    required this.initialTime
  });
  @override
  List<Object?> get props => [
    ...super.props,
    initialTime
  ];
}