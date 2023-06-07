import 'package:super_daily_habits/features/calendar/domain/repository/calendar_repository.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';

class CalendarRepositoryImpl implements CalendarRepository{
  @override
  Future<List<Day>> getDaysFromMonth(DateTime month)async{
    // TODO: implement getDaysFromMonth
    throw UnimplementedError();
  }

}