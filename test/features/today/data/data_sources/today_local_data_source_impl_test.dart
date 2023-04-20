import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source_impl.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart';
import 'today_local_data_source_impl_test.mocks.dart';

late TodayLocalDataSourceImpl todayLocalDataSource;
late MockDatabaseManager dbManager;
late MockTodayLocalAdapter adapter;

@GenerateMocks([
  DatabaseManager,
  TodayLocalAdapter
])
void main(){
  setUp((){
    adapter = MockTodayLocalAdapter();
    dbManager = MockDatabaseManager();
    todayLocalDataSource = TodayLocalDataSourceImpl(
      dbManager: dbManager,
      adapter: adapter
    );
  });

  group('get day from date', _testGetDayFromDate);
  group('set activity to day', _testSetActivityToDay);
}

void _testGetDayFromDate(){
  late CustomDate tDate;
  late String tStringJsonDate;
  setUp((){
    tDate = const CustomDate(
      year: 2000,
      month: 10,
      day: 15,
      weekDay: 2
    );
    tStringJsonDate = """
      {
        'year': 2000,
        'month': 10,
        'day': 15,
        'week_day': 2
      }
    """;
    when(adapter.getStringMapFromDate(any))
          .thenReturn(tStringJsonDate);
  });
  
  group('Cuando todo sale bien', (){
    late Map<String, dynamic> tJsonDay;
    late Day tDay;
    setUp((){
      tDay = Day(
        id: 0,
        date: tDate,
        activities: [],
        work: 10
      );
      tJsonDay = {
        idKey: 0,
        daysDateKey: tStringJsonDate,
        daysWorkKey: 10
      };
      when(dbManager.queryWhere(any, any, any))
          .thenAnswer((_) async => [tJsonDay]);
      when(adapter.getEmptyDayFromMap(any))
          .thenReturn(tDay);
    });

    test('Debe llamar a los métodos esperados', ()async{
      await todayLocalDataSource.getDayFromDate(tDate);
      verify(adapter.getStringMapFromDate(tDate));
      verify(dbManager.queryWhere(
        daysTableName,
        TodayLocalDataSourceImpl.dayByDateQuery,
        [tStringJsonDate]
      ));
      verify(adapter.getEmptyDayFromMap(tJsonDay));
    });

    test('Debe retornar el resultado esperado', ()async{
      final result = await todayLocalDataSource.getDayFromDate(tDate);
      expect(result, tDay);
    });
  });

  test('Debe lanzar el error esperado cuando la base de datos no retorna elementos', ()async{
    when(dbManager.queryWhere(any, any, any))
        .thenAnswer((_) async => []);
    try{
      await todayLocalDataSource.getDayFromDate(tDate);
      fail('Debería lanzarse una exceción');
    }on AppException catch(exception){
      if(exception is DBException){
        expect(exception.type, DBExceptionType.empty);
      }else{
        fail('La exce´ción debería ser DBException');
      }
    }
  });
}

void _testSetActivityToDay(){
  late Day tDay;
  late HabitActivityCreation tActivity;
  late Map<String, dynamic> tJsonActivity;
  late int tNewActivityId;
  late Map<String, dynamic> tJsonDayActivity;
  setUp((){
    tDay = const Day(
      id: 0,
      date: CustomDate(
        year: 2000,
        month: 10,
        day: 15,
        weekDay: 2
      ),
      activities: [],
      work: 10
    );
    tActivity = const HabitActivityCreation(
      name: 'act_x',
      initialTime: CustomTime(
        hour: 10,
        minute: 20
      ),
      minutesDuration: 30,
      work: 10
    );
    tJsonActivity = {
      'name': 'act_x',
      'initial_time': '{...initial_time...}',
      'duration': 30,
      'work': 10
    };
    tNewActivityId = 1000;
    tJsonDayActivity = {
      'day_id': 0,
      'activity_id': tNewActivityId
    };
    when(adapter.getMapFromActivity(any))
        .thenReturn(tJsonActivity);
    final ids = [tNewActivityId, -1];
    when(dbManager.insert(any, any))
        .thenAnswer((_) async => ids.removeAt(0));
    when(adapter.getMapFromDayIdAndActivityId(any, any))
        .thenReturn(tJsonDayActivity);
  });

  test('Debe llamar los métodos esperados cuando todo sale bien', ()async{
    await todayLocalDataSource.setActivityToDay(tActivity, tDay);
    verify(adapter.getMapFromActivity(tActivity));
    verify(dbManager.insert(activitiesTableName, tJsonActivity));
    verify(dbManager.insert(daysActivitiesTableName, tJsonDayActivity));
  });
}