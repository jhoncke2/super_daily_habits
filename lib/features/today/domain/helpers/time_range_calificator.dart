import 'package:super_daily_habits/common/domain/custom_time_manager.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

abstract class TimeRangeCalificator{
  bool timeIsBetweenTimeRange(CustomTime time, CustomTime rangeInit, int minutesDuration);
  bool timeRangesCollide(CustomTime initialTime1, int duration1, CustomTime initialTime2, int duration2);
}

class TimeRangeCalificatorImpl implements TimeRangeCalificator{
  final CustomTimeManager customTimeManager;
  TimeRangeCalificatorImpl({
    required this.customTimeManager
  });
  @override
  bool timeIsBetweenTimeRange(CustomTime time, CustomTime rangeInit, int minutesDuration) {
    final rangeEnd = customTimeManager.getTimeWithMinutesAdded(rangeInit, minutesDuration);
    return
    (
      rangeInit.hour != rangeEnd.hour
      && (
            (time.hour > rangeInit.hour && time.hour < rangeEnd.hour)
         || (time.minute >= rangeInit.minute && time.hour == rangeInit.hour)
         || (time.minute <= rangeEnd.minute && time.hour == rangeEnd.hour)
        )
    )
    || (
      time.hour == rangeInit.hour && rangeInit.minute <= time.minute && time.minute < rangeEnd.minute
    )
    ;
  }
    
  
  @override
  bool timeRangesCollide(CustomTime initialTime1, int duration1, CustomTime initialTime2, int duration2) {
    final endTime1 = customTimeManager.getTimeWithMinutesAdded(
      initialTime1,
      duration1
    );
    return (
      timeIsBetweenTimeRange(
        initialTime1,
        initialTime2,
        duration2
      )
      || 
      timeIsBetweenTimeRange(
        endTime1,
        initialTime2,
        duration2
      )
      ||
      timeIsBetweenTimeRange(
        initialTime2,
        initialTime1,
        duration1
      )
    );
  }
}