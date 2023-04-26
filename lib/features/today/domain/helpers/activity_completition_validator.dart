import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';

abstract class ActivityCompletitionValidator{
  bool isCompleted(HabitActivityCreation activity);
}

class ActivityCompletitionValidatorImpl implements ActivityCompletitionValidator{
  @override
  bool isCompleted(HabitActivityCreation activity) =>
      activity.name.isNotEmpty
    && activity.initialTime != null
    && activity.minutesDuration > 0
    && activity.work > 0;
}