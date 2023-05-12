import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';

class DataBaseInjecter{
  final DatabaseManager databaseManager;
  final TodayLocalAdapter adapter;
  DataBaseInjecter({
    required this.databaseManager,
    required this.adapter
  });
  Future<void> injectFakeData()async{
    final date = DateTime.now();
    final day = DayBase(
      date: CustomDate.fromDateTime(date),
      totalWork: 100,
      restantWork: 100
    );
    final jsonDay = adapter.getMapFromDay(day);
    await databaseManager.insert(
      daysTableName,
      jsonDay
    );
  }
}