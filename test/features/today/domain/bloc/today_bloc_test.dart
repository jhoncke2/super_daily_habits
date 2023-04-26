import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'package:super_daily_habits/features/today/domain/today_repository.dart';
import 'today_bloc_test.mocks.dart';

late TodayBloc todayBloc;
late MockTodayRepository todayRepository;
late MockCurrentDateGetter currentDateGetter;
late MockActivityCompletitionValidator activityCompletitionValidator;
late MockTimeRangeCalificator timeRangeCalificator;

@GenerateMocks([
  TodayRepository,
  CurrentDateGetter,
  ActivityCompletitionValidator,
  TimeRangeCalificator
])
void main(){
  setUp((){
    timeRangeCalificator = MockTimeRangeCalificator();
    activityCompletitionValidator = MockActivityCompletitionValidator();
    currentDateGetter = MockCurrentDateGetter();
    todayRepository = MockTodayRepository();
    todayBloc = TodayBloc(
      repository: todayRepository,
      currentDateGetter: currentDateGetter,
      activityCompletitionValidator: activityCompletitionValidator,
      timeRangeCalificator: timeRangeCalificator
    );
  });

  group('load day by current date', _testLoadDayByCurrentDate);
  group('init activity creation', _testInitActivityCreation);
  group('update activity initial time', _testUpdateActivityInitialTime);
  group('create activity', _testCreateActivity);
}

void _testLoadDayByCurrentDate(){
  late CustomDate currentDate;
  setUp((){
    currentDate = const CustomDate(
      year: 2023,
      month: 04,
      day: 22,
      weekDay: 1
    );
    when(currentDateGetter.getCurrentDate())
        .thenReturn(currentDate);
  });

  group('Cuando todo sale bien', (){
    late Day currentDay;
    setUp((){
      currentDay = Day(
        id: 100,
        date: currentDate,
        activities: const [
          HabitActivity(
            id: 0,
            name: 'ac_0', 
            minutesDuration: 10, 
            work: 2, 
            initialTime: CustomTime(
              hour: 10,
              minute: 20
            )
          ),
          HabitActivity(
            id: 1,
            name: 'ac_1', 
            minutesDuration: 20, 
            work: 3, 
            initialTime: CustomTime(
              hour: 10,
              minute: 20
            )
          )
        ],
        work: 10
      );
      when(todayRepository.getDayByDate(any))
          .thenAnswer((_) async => currentDay);
    });
    
    test('Debe llamar los métodos esperados', ()async{
      todayBloc.add(LoadDayByCurrentDate());
      await untilCalled(currentDateGetter.getCurrentDate());
      verify(currentDateGetter.getCurrentDate());
      await untilCalled(todayRepository.getDayByDate(any));
      verify(todayRepository.getDayByDate(currentDate));
    });
    test('''Debe emitir los siguientes estados en el orden esperado
    con un restantWork de 5''', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnShowingTodayDay(
          today: currentDay,
          restantWork: 5
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(LoadDayByCurrentDate());
    });
  });
}

void _testInitActivityCreation(){
  late Day today;
  late int restantWorK;
  
  group('Cuando aún hay espacio en el tiempo del día para llenar', (){
    late HabitActivityCreation activity;
    setUp((){
      restantWorK = 20;
      today = Day(
        id: 0,
        date: CustomDate.fromDateTime(
          DateTime.now()
        ),
        activities: const [
          HabitActivity(
            id: 100,
            name: 'act_x0',
            minutesDuration: 25,
            work: 10,
            initialTime: CustomTime(
              hour: 10,
              minute: 10
            )
          ),
          HabitActivity(
            id: 101,
            name: 'act_x1',
            minutesDuration: 250,
            work: 20,
            initialTime: CustomTime(
              hour: 11,
              minute: 20
            )
          )
        ],
        work: 50
      );
      activity = const HabitActivityCreation(
        name: '',
        initialTime: null,
        minutesDuration: 0,
        work: 0
      );
      todayBloc.emit(OnShowingTodayDay(
        today: today,
        restantWork: restantWorK
      ));
    });

    test('Debe llamar los métodos esperados', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      todayBloc.add(InitActivityCreation());
      await untilCalled(activityCompletitionValidator.isCompleted(any));
      verify(activityCompletitionValidator.isCompleted(activity));
    });

    test('''Debe emitir los siguientes estados en el orden esperado
    activity no está completa''', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      final states = [
        OnCreatingActivity(
          today: today,
          activity: activity,
          restantWork: restantWorK,
          canEnd: false
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(InitActivityCreation());
    });
  });

  group('Cuando ya no hay espacio en el tiempo del día para llenar', (){
    late HabitActivityCreation activity;
    setUp((){
      restantWorK = 0;
      today = Day(
        id: 0,
        date: CustomDate.fromDateTime(
          DateTime.now()
        ),
        activities: const [
          HabitActivity(
            id: 100,
            name: 'act_x0',
            minutesDuration: 900,
            work: 30,
            initialTime: CustomTime(
              hour: 00,
              minute: 00
            )
          ),
          HabitActivity(
            id: 101,
            name: 'act_x1',
            minutesDuration: 540,
            work: 20,
            initialTime: CustomTime(
              hour: 15,
              minute: 00
            )
          )
        ],
        work: 50
      );
      activity = const HabitActivityCreation(
        name: '',
        initialTime: null,
        minutesDuration: 0,
        work: 0
      );
      todayBloc.emit(OnShowingTodayDay(
        today: today,
        restantWork: restantWorK
      ));
    });

    test('''Debe emitir los siguientes estados en el orden esperado
    activity no está completa''', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      final states = [
        OnShowingTodayDayError(
          today: today,
          restantWork: restantWorK,
          message: TodayBloc.dayTimeFilledMessage
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(InitActivityCreation());
    });
  });
}

void _testUpdateActivityInitialTime(){
  late Day currentDay;
  late TimeOfDay? time;
  late HabitActivityCreation initActivity;
  late int tRestantWork;
  setUp((){
    initActivity = const HabitActivityCreation(
      name: 'act_x',
      initialTime: null,
      minutesDuration: 10,
      work: 1
    );
    tRestantWork = 10;
    when(todayRepository.getDayByDate(any))
        .thenAnswer((_) async => currentDay);
  });

  group('Cuando el date es != null', (){
    late CustomTime formattedTime;
    late HabitActivityCreation updatedActivity;
    late List<HabitActivity> dayActivities;

    setUp((){
      time = const TimeOfDay(
        hour: 11,
        minute: 06
      );
      formattedTime = const CustomTime(
        hour: 11,
        minute: 06
      );
      updatedActivity = HabitActivityCreation(
        name: 'act_x',
        initialTime: formattedTime,
        minutesDuration: 10,
        work: 1
      );
      dayActivities = const [
        HabitActivity(
          id: 0,
          name: 'ac_0',
          minutesDuration: 50,
          work: 10,
          initialTime: CustomTime(
            hour: 10,
            minute: 15
          )
        ),
        HabitActivity(
          id: 1,
          name: 'ac_1',
          minutesDuration: 120,
          work: 7,
          initialTime: CustomTime(
            hour: 15,
            minute: 20
          )
        )
      ];
      currentDay = Day(
        id: 100,
        date: CustomDate.fromDateTime(
          DateTime.now()
        ),
        activities: dayActivities,
        work: 10
      );
      todayBloc.emit(OnCreatingActivity(
        today: currentDay,
        activity: initActivity,
        restantWork: tRestantWork,
        canEnd: false
      ));
    });

    group('cuando el initialTime <no> está dentro de alguno de los rangos de duración de las demás activities', (){
      setUp((){
        when(timeRangeCalificator.timeIsBetweenTimeRange(any, any, any))
          .thenReturn(false);
      });

      test('Debe llamar los métodos esperados', ()async{
        when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(true);
        todayBloc.add(UpdateActivityInitialTime(time));
        await untilCalled(timeRangeCalificator.timeIsBetweenTimeRange(any, any, any));
        verify(timeRangeCalificator.timeIsBetweenTimeRange(
          formattedTime,
          dayActivities[0].initialTime,
          dayActivities[0].minutesDuration
        ));
        await untilCalled(timeRangeCalificator.timeIsBetweenTimeRange(any, any, any));
        verify(timeRangeCalificator.timeIsBetweenTimeRange(
          formattedTime,
          dayActivities[1].initialTime,
          dayActivities[1].minutesDuration
        ));
        await untilCalled(activityCompletitionValidator.isCompleted(any));
        verify(activityCompletitionValidator.isCompleted(updatedActivity));
      });

      test('''Debe emitir los siguientes estados en el orden esperado
      cuando el activity <sí> está completo''', ()async{
        when(activityCompletitionValidator.isCompleted(any))
            .thenReturn(true);
        final states = [
          OnCreatingActivity(
            today: currentDay,
            activity: updatedActivity,
            restantWork: tRestantWork,
            canEnd: true
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(UpdateActivityInitialTime(time));
      });

      test('''Debe emitir los siguientes estados en el orden esperado
      cuando el activity <no> está completo''', ()async{
        when(activityCompletitionValidator.isCompleted(any))
            .thenReturn(false);
        final states = [
          OnCreatingActivity(
            today: currentDay,
            activity: updatedActivity,
            restantWork: tRestantWork,
            canEnd: false
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(UpdateActivityInitialTime(time));
      });
    });
    

    test('''Debe emitir los siguientes estados en el orden esperado
    cuando el initialTime está dentro de uno de los rangos de duración de las demás activities''', ()async{
      final timeResponses = [false, true];
      when(timeRangeCalificator.timeIsBetweenTimeRange(any, any, any))
        .thenAnswer( (_) => timeResponses.removeAt(0));
      final states = [
        OnCreatingActivityError(
          today: currentDay,
          activity: updatedActivity,
          restantWork: tRestantWork,
          canEnd: false,
          message: TodayBloc.initialTimeIsOnAnotherActivityRangeMessage
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(UpdateActivityInitialTime(time));
    });
  });

  test('''Debe emitir los siguientes estados en el orden esperado
  cuando el time es null''', ()async{
    currentDay = Day(
      id: 100,
      date: CustomDate.fromDateTime(
        DateTime.now()
      ),
      activities: [],
      work: 10
    );
    todayBloc.emit(OnCreatingActivity(
      today: currentDay,
      activity: initActivity,
      restantWork: tRestantWork,
      canEnd: false
    ));
    time = null;
    expectLater(todayBloc.stream, emitsInOrder([]));
    todayBloc.add(UpdateActivityInitialTime(time));
  });
}

void _testCreateActivity(){
  late CustomDate dayDate;
  late Day initDay;
  late HabitActivityCreation activity;
  late int initRestantWork;
  setUp((){
    dayDate = CustomDate.fromDateTime(
      DateTime.now()
    );
    initDay = Day(
      id: 0,
      date: dayDate,
      activities: [],
      work: 10
    );
    activity = const HabitActivityCreation(
      name: 'act_x',
      initialTime: CustomTime(
        hour: 20,
        minute: 10
      ),
      minutesDuration: 10,
      work: 10
    );
    
  });

  group('Cuando todo sale bien', (){
    late Day updatedDay;
    setUp((){
      initRestantWork = 11;
      todayBloc.emit(OnCreatingActivity(
        today: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true
      ));
      updatedDay = Day(
        id: 0,
        date: dayDate,
        activities: const [
          HabitActivity(
            id: 0,
            name: 'ac_0', 
            minutesDuration: 10, 
            work: 8, 
            initialTime: CustomTime(
              hour: 10,
              minute: 20
            )
          ),
          HabitActivity(
            id: 1,
            name: 'ac_1', 
            minutesDuration: 20, 
            work: 3, 
            initialTime: CustomTime(
              hour: 10,
              minute: 20
            )
          )
        ],
        work: 20
      );
      when(todayRepository.setActivityToDay(any, any))
          .thenAnswer((_) async => updatedDay);
    });

    test('Debe llamar los métodos esperados', ()async{
      todayBloc.add(CreateActivity());
      await untilCalled(todayRepository.setActivityToDay(any, any));
      verify(todayRepository.setActivityToDay(activity, initDay));
    });

    test('''Debe emitir los siguientes estados en el orden esperado
    con un restant work de 9''', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnShowingTodayDay(
          today: updatedDay,
          restantWork: 9
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(CreateActivity());
    });
  });

  test('''Debe emitir los siguientes estados en el orden esperado cuando
  la cantidad de trabajo de la actividad supera a la restante''', ()async{
    initRestantWork = 9;
    todayBloc.emit(OnCreatingActivity(
      today: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    final states = [
      OnCreatingActivityError(
        today: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: TodayBloc.insufficientRestantWorkMessage
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });

  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <con> mensaje''', ()async{
    initRestantWork = 11;
    todayBloc.emit(OnCreatingActivity(
      today: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    const message = 'error_message';
    when(todayRepository.setActivityToDay(any, any))
        .thenThrow(const DBException(
          message: message,
          type: DBExceptionType.normal
        ));
    final states = [
      OnLoadingTodayDay(),
      OnCreatingActivityError(
        today: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: message
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
  
  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <sin> mensaje''', ()async{
    initRestantWork = 11;
    todayBloc.emit(OnCreatingActivity(
      today: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    when(todayRepository.setActivityToDay(any, any))
        .thenThrow(const DBException(
          message: '',
          type: DBExceptionType.normal
        ));
    final states = [
      OnLoadingTodayDay(),
      OnCreatingActivityError(
        today: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: TodayBloc.unexpectedErrorMessage
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
}