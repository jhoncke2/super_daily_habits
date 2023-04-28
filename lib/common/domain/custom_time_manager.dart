import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

abstract class CustomTimeManager{
  CustomTime getTimeWithMinutesAdded(CustomTime time, int minutes);
}

class CustomTimeManagerImpl implements CustomTimeManager{
  @override
  CustomTime getTimeWithMinutesAdded(CustomTime time, int minutes) {
    final hoursSum = time.hour + (minutes ~/ 60);
    final minutesSum = time.minute + (minutes % 60);
    bool minutesAdvance1Hour = false;
    if(minutesSum > 59){
      minutesAdvance1Hour = true;
    }
    return CustomTime(
      hour: (hoursSum + (minutesAdvance1Hour? 1 : 0)) % 24,
      minute: minutesSum % 60
    );
  }
}