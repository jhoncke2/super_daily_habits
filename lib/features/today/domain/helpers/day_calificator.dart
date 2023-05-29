import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';

abstract class DayCalificator{
  bool canBeModified(Day day, CustomDate currentDate);
  bool hasEnoughRestantWork(Day day, int workToAdd);
}

class DayCalificatorImpl implements DayCalificator{
  @override
  bool canBeModified(Day day, CustomDate currentDate) {
    final currentDateTime = _getDateTimeFromDate(currentDate);
    final dayDateTime = _getDateTimeFromDate(day.date);
    return dayDateTime.compareTo(currentDateTime) >= 0;
  }

  DateTime _getDateTimeFromDate(CustomDate date) =>
    DateTime(
      date.year,
      date.month,
      date.day
    );
    
  @override
  bool hasEnoughRestantWork(Day day, int addedWork) =>
    day.restantWork - addedWork >= 0;
}