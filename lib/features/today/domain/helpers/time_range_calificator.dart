// ignore_for_file: prefer_const_constructors, sdk_version_since

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
    final evaluatedDate = DateTime.now().copyWith(
      hour: time.hour,
      minute: time.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0
    );
    final dateInit = DateTime.now().copyWith(
      hour: rangeInit.hour,
      minute: rangeInit.minute,
      second: 0,
      millisecond: 0,
      microsecond: 0
    );
    final dateEnd = dateInit.add(Duration(
      minutes: minutesDuration
    ));
    return (
      (evaluatedDate.isAfter(dateInit) || evaluatedDate.isAtSameMomentAs(dateInit)) && evaluatedDate.isBefore(dateEnd)
    );
  }
    
  
  @override
  bool timeRangesCollide(CustomTime initialTime1, int duration1, CustomTime initialTime2, int duration2) {
    final endTime1 = customTimeManager.getTimeWithMinutesAdded(
      initialTime1,
      duration1
    );
    final quest1 = timeIsBetweenTimeRange(
      initialTime1,
      initialTime2,
      duration2
    );
    return (
      quest1
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