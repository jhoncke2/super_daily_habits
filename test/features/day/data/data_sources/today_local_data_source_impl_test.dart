import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_data_source_impl.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
import 'today_local_data_source_impl_test.mocks.dart';

late DayLocalDataSourceImpl dayLocalDataSource;
late MockDatabaseManager dbManager;
late MockDayLocalAdapter adapter;

@GenerateMocks([
  DatabaseManager,
  DayLocalAdapter
])
void main(){
  setUp((){
    adapter = MockDayLocalAdapter();
    dbManager = MockDatabaseManager();
    dayLocalDataSource = DayLocalDataSourceImpl(
      dbManager: dbManager,
      adapter: adapter
    );
  });

  group('get day by date', _testGetDayByDate);
  group('get day by id', _testGetDayById);
  group('set activity to day', _testSetActivityToDay);
  group('update restant work', _testUpdateRestantWork);
  //TODO: Activar en su implementación
  //group('delete activity from day', _testDeleteActivityFromDay);
  group('get all repeatables activities', _testGetAllRepeatableActivities);
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
      await dayLocalDataSource.getDayFromDate(tDate);
      verify(adapter.getStringMapFromDate(tDate));
      verify(dbManager.queryWhere(
        daysTableName,
        DayLocalDataSourceImpl.dayByDateQuery,
        [tStringJsonDate]
      ));
      verify(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        daysActivitiesActivityIdKey,
        activitiesTableName,
        idKey,
        DayLocalDataSourceImpl.dayByIdInnerJoinQuery,
        [dayId]
      ));
      verify(adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities));
    });

    test('Debe retornar el resultado esperado', ()async{
      final result = await dayLocalDataSource.getDayFromDate(tDate);
      expect(result, day);
    });
  });

  test('Debe lanzar el error esperado cuando la base de datos no retorna elementos', ()async{
    when(dbManager.queryWhere(any, any, any))
        .thenAnswer((_) async => []);
    try{
      await dayLocalDataSource.getDayFromDate(tDate);
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
      await dayLocalDataSource.getDayById(tDayId);
      verify(dbManager.querySingleOne(daysTableName, tDayId));
      verify(dbManager.queryInnerJoin(
        daysActivitiesTableName,
        daysActivitiesActivityIdKey,
        activitiesTableName,
        idKey,
        DayLocalDataSourceImpl.dayByIdInnerJoinQuery,
        [tDayId]
      ));
      verify(adapter.getFilledDayWithActivitiesFromMap(jsonDay, jsonActivities));
    });

    test('Debe retornar el resultado esperado', ()async{
      final result = await dayLocalDataSource.getDayById(tDayId);
      expect(result, updatedDay);
    });
  });
}

void _testSetActivityToDay(){
  late Day tDay;
  late HabitActivityCreation tActivity;
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
    tNewActivityId = 1000;
    tJsonDayActivity = {
      'day_id': 0,
      'activity_id': tNewActivityId,
      'init_hour': '{x}',
      'duration': 30
    };
    when(adapter.getMapFromDayIdAndActivityId(any, any))
        .thenReturn(tJsonDayActivity);
  });

  test('Debe llamar los métodos esperados cuando no es repeated', ()async{
    tActivity = const HabitActivityCreation(
      name: 'act_x',
      initialTime: CustomTime(
        hour: 10,
        minute: 20
      ),
      minutesDuration: 30,
      work: 10,
      repeatability: ActivityRepeatability.none
    );
    final tJsonActivityToCreate = {
      'name': 'act_x',
      'initial_time': '{...initial_time...}',
      'duration': 30,
      'work': 10
    };
    final tCreatedActivity = HabitActivity(
      id: tNewActivityId,
      name: 'act_x',
      minutesDuration: 30,
      work: 10,
      initialTime: const CustomTime(
        hour: 10,
        minute: 20
      ),
    );
    when(adapter.getMapFromActivity(any))
        .thenReturn(tJsonActivityToCreate);
    final ids = [tNewActivityId, -1];
    when(dbManager.insert(any, any))
        .thenAnswer((_) async => ids.removeAt(0));
    
    await dayLocalDataSource.setActivityToDay(tActivity, tDay);
    verify(adapter.getMapFromActivity(tActivity));
    verify(dbManager.insert(activitiesTableName, tJsonActivityToCreate));
    verify(adapter.getMapFromDayIdAndActivityId(tDay.id, tCreatedActivity));
    verify(dbManager.insert(daysActivitiesTableName, tJsonDayActivity));
  });

  test('Debe llamar a los métodos esperados cuando es repeated', ()async{
    final tRepeatedActivity = HabitActivity(
      id: tNewActivityId,
      name: 'act_x',
      minutesDuration: 40,
      work: 10,
      initialTime: const CustomTime(
        hour: 5,
        minute: 10
      )
    );
    final updatedActivity = HabitActivity(
      id: tNewActivityId,
      name: 'act_x',
      minutesDuration: 30,
      work: 10,
      initialTime: const CustomTime(
        hour: 10,
        minute: 20
      ),
    );
    tActivity = HabitActivityCreation(
      name: 'act_x',
      initialTime: const CustomTime(
        hour: 10,
        minute: 20
      ),
      minutesDuration: 30,
      work: 10,
      repeatability: ActivityRepeatability.repeated,
      repeatedActivity: tRepeatedActivity
    );
    when(dbManager.insert(any, any))
        .thenAnswer((_) async => 1);
    await dayLocalDataSource.setActivityToDay(tActivity, tDay);
    verifyNever(dbManager.insert(activitiesTableName, any));
    verify(adapter.getMapFromDayIdAndActivityId(tDay.id, updatedActivity));
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
    await dayLocalDataSource.updateRestantWork(restantWork, initDay);
    verify(adapter.getMapFromDay(updatedDay));
    verify(dbManager.update(
      daysTableName,
      jsonDay,
      dayId
    ));
  });
}

void _testDeleteActivityFromDay(){
  late int activityId;
  late HabitActivity activity;
  late Day day;
  //TODO: Revisar variable para su uso o eliminación
  //late int restantActivitiesCounts;
  setUp((){
    activityId = 100;
    activity = HabitActivity(
      id: activityId,
      name: 'ha_100',
      minutesDuration: 60,
      work: 100,
      initialTime: const CustomTime(
        hour: 10,
        minute: 20
      )
    );
    day = Day(
      id: 10,
      activities: [
        activity
      ],
      date: CustomDate.fromDateTime(
        DateTime.now()
      ),
      totalWork: 150,
      restantWork: 50
    );
  });

  test('Debe llamar los métodos esperados cuando la cantidad restante de activities es 2', ()async{
    //verify(dbManager.remove(tableName, id))
    when(dbManager.queryCount(
      daysActivitiesTableName,
      any,
      any
    )).thenAnswer((_) async => 2);
    await dayLocalDataSource.deleteActivityFromDay(activity, day);
    verify(dbManager.removeWhere(
      daysActivitiesTableName,
      DayLocalDataSourceImpl.activityByIdOnDaysActivitiesQuery,
      [activity.id]
    ));
    verify(dbManager.queryCount(
      daysActivitiesTableName,
      DayLocalDataSourceImpl.activityByIdOnDaysActivitiesQuery,
      [activityId]
    ));
    verifyNever(
      dbManager.remove(
        activitiesTableName,
        any
      )
    );
  });

  test('Debe llamar los métodos esperados cuando la cantidad restante de activities es 0', ()async{
    when(dbManager.queryCount(
      daysActivitiesTableName,
      any,
      any
    )).thenAnswer((_) async => 0);
    await dayLocalDataSource.deleteActivityFromDay(activity, day);
    verify(dbManager.removeWhere(
      daysActivitiesTableName,
      DayLocalDataSourceImpl.activityByIdOnDaysActivitiesQuery,
      [activity.id]
    ));
    verify(dbManager.queryCount(
      daysActivitiesTableName,
      DayLocalDataSourceImpl.activityByIdOnDaysActivitiesQuery,
      [activityId]
    ));
    verify(
      dbManager.remove(
        activitiesTableName,
        activityId
      )
    );
  });
}

void _testGetAllRepeatableActivities(){
  late List<HabitActivity> activities;
  late List<Map<String, dynamic>> dbActivities;
  setUp((){
    activities = const [
      HabitActivity(
        id: 0,
        name: 'a_0',
        minutesDuration: 30,
        work: 30,
        initialTime: CustomTime(
          hour: 10,
          minute: 10
        )
      ),
      HabitActivity(
        id: 1,
        name: 'a_1',
        minutesDuration: 50,
        work: 50,
        initialTime: CustomTime(
          hour: 15,
          minute: 20
        )
      )
    ];
    dbActivities = const [
      {
        idKey: 0,
        'etc': 'info_0'
      },
      {
        idKey: 1,
        'etc': 'info_1'
      }
    ];
    when(dbManager.queryWhere(
      any,
      any,
      any
    )).thenAnswer((_) async => dbActivities);
    when(adapter.getActivitiesFromJson(any))
      .thenReturn(activities);
  });

  test('Debe llamar a los métodos esperados', ()async{
    await dayLocalDataSource.getAllRepeatableActivities();
    verify(dbManager.queryWhere(
      activitiesTableName,
      DayLocalDataSourceImpl.activitiesByRepeatablesQuery,
      [1]
    ));
    verify(adapter.getActivitiesFromJson(dbActivities));
  });

  test('Debe retornar el resultado esperado', ()async{
    final result = await dayLocalDataSource.getAllRepeatableActivities();
    expect(result, activities);
  });
}