import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source_impl.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
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

  group('get day by date', _testGetDayByDate);
  group('get day by id', _testGetDayById);
  group('set activity to day', _testSetActivityToDay);
  group('update restant work', _testUpdateRestantWork);
}

void _testGetDayByDate(){
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
    late int dayId;
    late Map<String, dynamic> jsonDay;
    late Day day;
    late List<Map<String, dynamic>> jsonActivities;
    late List<HabitActivity> tActivities;
    setUp((){
      dayId = 1005;
      jsonDay = {
        idKey: dayId,
        daysDateKey: tStringJsonDate,
        daysWorkKey: 10
      };
      jsonActivities = [
        {
          'id': 100,
          'name': 'ac_100',
          'initial_time': '{...time...}',
          'duration': 10,
          'work': 10
        },
        {
          'id': 101,
          'name': 'ac_101',
          'initial_time': '{...time...}',
          'duration': 10,
          'work': 11
        }
      ];
      tActivities = const [
        HabitActivity(
          id: 100,
          name: 'ac_100',
          initialTime: CustomTime(
            hour: 10,
            minute: 10
          ),
          minutesDuration: 10,
          work: 10
        ),
        HabitActivity(
          id: 101,
          name: 'ac_101',
          initialTime: CustomTime(
            hour: 11,
            minute: 11
          ),
          minutesDuration: 10,
          work: 11
        )
      ];
      day = Day(
        id: dayId,
        date: tDate,
        activities: tActivities,
        totalWork: 10,
        restantWork: 5
      );
      when(dbManager.queryWhere(any, any, any))
          .thenAnswer((_) async => [jsonDay]);
      when(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        any,
        activitiesTableName,
        any,
        any,
        any
      )).thenAnswer((_) async => jsonActivities);
      when(adapter.getFilledDayWithActivitiesFromMap(any, any))
          .thenReturn(day);
    });

    test('Debe llamar a los métodos esperados', ()async{
      await todayLocalDataSource.getDayFromDate(tDate);
      verify(adapter.getStringMapFromDate(tDate));
      verify(dbManager.queryWhere(
        daysTableName,
        TodayLocalDataSourceImpl.dayByDateQuery,
        [tStringJsonDate]
      ));
      verify(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        daysActivitiesActivityIdKey,
        activitiesTableName,
        idKey,
        TodayLocalDataSourceImpl.dayByIdInnerJoinQuery,
        [dayId]
      ));
      verify(adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities));
    });

    test('Debe retornar el resultado esperado', ()async{
      final result = await todayLocalDataSource.getDayFromDate(tDate);
      expect(result, day);
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

void _testGetDayById(){
  late int tDayId;
  setUp((){
    tDayId = 0;
  });
  group('Cuando todo sale bien', (){
    late Map<String, dynamic> jsonDay;
    late Day updatedDay;
    late List<Map<String, dynamic>> jsonActivities;
    late List<HabitActivity> tActivities;
    setUp((){
      jsonDay = {
        'id': tDayId,
        'date': '{...date...}',
        'work': 100
      };
      final dayDate = CustomDate.fromDateTime(DateTime.now());
      jsonActivities = [
        {
          'id': 100,
          'name': 'ac_100',
          'initial_time': '{...time...}',
          'duration': 10,
          'work': 10
        },
        {
          'id': 101,
          'name': 'ac_101',
          'initial_time': '{...time...}',
          'duration': 10,
          'work': 11
        }
      ];
      tActivities = const [
        HabitActivity(
          id: 100,
          name: 'ac_100',
          initialTime: CustomTime(
            hour: 10,
            minute: 10
          ),
          minutesDuration: 10,
          work: 10
        ),
        HabitActivity(
          id: 101,
          name: 'ac_101',
          initialTime: CustomTime(
            hour: 11,
            minute: 11
          ),
          minutesDuration: 10,
          work: 11
        )
      ];
      updatedDay = Day(
        id: tDayId,
        date: dayDate,
        activities: tActivities,
        totalWork: 100,
        restantWork: 50
      );
      when(dbManager.querySingleOne(daysTableName, any))
          .thenAnswer((_) async => jsonDay);
      when(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        any,
        activitiesTableName,
        any,
        any,
        any
      )).thenAnswer((_) async => jsonActivities);
      when(adapter.getFilledDayWithActivitiesFromMap(any, any))
          .thenReturn(updatedDay);
    });

    test('Se debe llamar a los métodos esperados', ()async{
      await todayLocalDataSource.getDayById(tDayId);
      verify(dbManager.querySingleOne(daysTableName, tDayId));
      verify(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        daysActivitiesActivityIdKey,
        activitiesTableName,
        idKey,
        TodayLocalDataSourceImpl.dayByIdInnerJoinQuery,
        [tDayId]
      ));
      verify(adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities));
    });

    test('Debe retornar el resultado esperado', ()async{
      final result = await todayLocalDataSource.getDayById(tDayId);
      expect(result, updatedDay);
    });
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
      totalWork: 10,
      restantWork: 5
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

void _testUpdateRestantWork(){
  late int restantWork;
  late int dayId;
  late Day initDay;
  late DayBase updatedDay;
  late Map<String, dynamic> jsonDay;
  setUp((){
    restantWork = 20;
    const activities = [
      HabitActivity(
        id: 100,
        name: 'h_a_100',
        minutesDuration: 50,
        work: 10,
        initialTime: CustomTime(hour: 1, minute: 1)
      ),
      HabitActivity(
        id: 101,
        name: 'h_a_101',
        minutesDuration: 30,
        work: 15,
        initialTime: CustomTime(hour: 2, minute: 21)
      )
    ];
    const date = CustomDate(
      year: 2023,
      month: 1,
      day: 2,
      weekDay: 3
    );
    dayId = 10;
    initDay = Day(
      id: dayId,
      activities: activities,
      date: date,
      totalWork: 15,
      restantWork: 10
    );
    updatedDay = DayBase(
      date: date,
      totalWork: 15,
      restantWork: restantWork
    );
    jsonDay = {
      'date': '{...the_date...}',
      'total_work': 15,
      'restant_work': restantWork
    };
    when(adapter.getMapFromDay(any))
        .thenReturn(jsonDay);
  });

  test('Debe llamar a los métodos esperados', ()async{
    await todayLocalDataSource.updateRestantWork(restantWork, initDay);
    verify(adapter.getMapFromDay(updatedDay));
    verify(dbManager.update(
      daysTableName,
      jsonDay,
      dayId
    ));
  });
}