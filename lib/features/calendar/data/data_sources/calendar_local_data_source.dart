import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';

abstract class CalendarLocalDataSource{
  Future<List<Day>> getDaysByMonth(DateTime month);
}