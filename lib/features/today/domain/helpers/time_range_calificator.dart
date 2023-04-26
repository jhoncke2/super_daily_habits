import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

abstract class TimeRangeCalificator{
  bool timeIsBetweenTimeRange(CustomTime time, CustomTime rangeInit, int minutesDuration);
}

class TimeRangeCalificatorImpl implements TimeRangeCalificator{
  @override
  bool timeIsBetweenTimeRange(CustomTime time, CustomTime rangeInit, int minutesDuration) {
    final rangeEnd = CustomTime(
      hour: rangeInit.hour + (minutesDuration ~/ 60),
      minute: rangeInit.minute + (minutesDuration % 60)
    );
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
      time.hour == rangeInit.hour && rangeInit.minute <= time.minute && time.minute <= rangeEnd.minute
    )
    ;
  }

}