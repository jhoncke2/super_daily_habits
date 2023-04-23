import 'package:super_daily_habits/features/today/domain/entities/activity/activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

class HabitActivity extends Activity{
  final int id;
  final CustomTime initialTime;
  const HabitActivity({
    required super.name,
    required super.minutesDuration,
    required super.work,
    required this.id,
    required this.initialTime
  });
  @override
  List<Object?> get props => [
    ...super.props,
    id,
    initialTime
  ];
}