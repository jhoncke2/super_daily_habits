import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/features/calendar/data/data_sources/calendar_local_data_source.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';

class CalendarLocalDataSourceImpl implements CalendarLocalDataSource{
  final DatabaseManager dbManager;
  CalendarLocalDataSourceImpl({
    required this.dbManager
  });
  @override
  Future<List<Day>> getDaysByMonth(DateTime month)async{
    // TODO: implement getDaysByMonth
    throw UnimplementedError();
  }

}