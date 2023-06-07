import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';

abstract class CalendarRepository{
  Future<List<Day>> getDaysFromMonth(DateTime month);
}