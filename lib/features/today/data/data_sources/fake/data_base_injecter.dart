import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/domain/entities/day_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

class DataBaseInjecter{
  final DatabaseManager databaseManager;
  final TodayLocalAdapter adapter;
  DataBaseInjecter({
    required this.databaseManager,
    required this.adapter
  });
  Future<void> injectFakeData()async{
    final date = DateTime.now();
    final day = DayCreation(
      date: CustomDate.fromDateTime(date),
      activities: [],
      work: 100
    );
    final jsonDay = adapter.getMapFromDay(day);
    await databaseManager.insert(
      daysTableName,
      jsonDay
    );
  }
}