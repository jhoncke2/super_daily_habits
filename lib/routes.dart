import 'package:super_daily_habits/features/calendar/presentation/calendar_page.dart';
import 'package:super_daily_habits/features/today/presentation/day_page.dart';

class NavRoutes{
  static const specificDay = 'specific_day';
  static const calendar = 'calendar';
}

final routes = {
  NavRoutes.specificDay: (_) => DayPage(),
  NavRoutes.calendar: (_) => CalendarPage()
};