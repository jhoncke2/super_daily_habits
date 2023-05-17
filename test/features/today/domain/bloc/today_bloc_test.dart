import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/domain/common_repository.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'package:super_daily_habits/features/today/domain/day_repository.dart';
import 'today_bloc_test.mocks.dart';

late DayBloc todayBloc;
late MockDayRepository todayRepository;
late MockCommonRepository commonRepository;
late MockCurrentDateGetter currentDateGetter;
late MockActivityCompletitionValidator activityCompletitionValidator;
late MockTimeRangeCalificator timeRangeCalificator;

@GenerateMocks([
  DayRepository,
  CommonRepository,
  CurrentDateGetter,
  ActivityCompletitionValidator,
  TimeRangeCalificator
])
void main(){
  setUp((){
    timeRangeCalificator = MockTimeRangeCalificator();
    activityCompletitionValidator = MockActivityCompletitionValidator();
    currentDateGetter = MockCurrentDateGetter();
    commonRepository = MockCommonRepository();
    todayRepository = MockDayRepository();
    todayBloc = DayBloc(
      repository: todayRepository,
      currentDateGetter: currentDateGetter,
      activityCompletitionValidator: activityCompletitionValidator,
      timeRangeCalificator: timeRangeCalificator,
      commonRepository: commonRepository
    );
  });

  group('load day', _testLoadDay);
  group('init activity creation', _testInitActivityCreation);
  group('update activity initial time', _testUpdateActivityInitialTime);
  group('update activity duration', _testUpdateActivityDuration);
  group('create activity', _testCreateActivity);
}

void _testLoadDay(){
  late CustomDate date;
  setUp((){
    final systemDate = DateTime.now();
    date = CustomDate(
      year: systemDate.year,
      month: systemDate.month,
      day: systemDate.day,
      weekDay: systemDate.weekday
    );
  });

  group('Cuando todo sale bien', (){
    late Day initDay;
    late Day sortedDay;
    setUp((){
      initDay = Day(
        id: 100,
        date: date,
        activities: const [
          HabitActivity(
            id: 0,
            name: 'ac_0', 
            minutesDuration: 10, 
            work: 2, 
            initialTime: CustomTime(
              hour: 19,
              minute: 20
            )
          ),
          HabitActivity(
            id: 1,
            name: 'ac_1', 
            minutesDuration: 20, 
            work: 3, 
            initialTime: CustomTime(
              hour: 20,
              minute: 30
            )
          ),
          HabitActivity(
            id: 2,
            name: 'ac_2', 
            minutesDuration: 50, 
            work: 3, 
            initialTime: CustomTime(
              hour: 10,
              minute: 10
            )
          )
        ],
        totalWork: 10,
        restantWork: 5
      );
      sortedDay = Day(
        id: 100,
        date: date,
        activities: const [
          HabitActivity(
            id: 2,
            name: 'ac_2', 
            minutesDuration: 50, 
            work: 3, 
            initialTime: CustomTime(
              hour: 10,
              minute: 10
            )
          ),
          HabitActivity(
            id: 0,
            name: 'ac_0', 
            minutesDuration: 10, 
            work: 2, 
            initialTime: CustomTime(
              hour: 19,
              minute: 20
            )
          ),
          HabitActivity(
            id: 1,
            name: 'ac_1', 
            minutesDuration: 20, 
            work: 3, 
            initialTime: CustomTime(
              hour: 20,
              minute: 30
            )
          )
        ],
        totalWork: 10,
        restantWork: 5
      );
      when(todayRepository.getDayByDate(any))
          .thenAnswer((_) async => initDay);
    });

    group('Cuando el date del evento es null', (){
      setUp((){
        when(currentDateGetter.getCurrentDate())
          .thenReturn(date);
      });

      test('Debe llamar los métodos esperados', ()async{
        todayBloc.add(const LoadDay());
        await untilCalled(currentDateGetter.getCurrentDate());
        verify(currentDateGetter.getCurrentDate());
        await untilCalled(todayRepository.getDayByDate(any));
        verify(todayRepository.getDayByDate(date));
        verifyNever(commonRepository.getCommonWork());
        verifyNever(todayRepository.createDay(any));
      });
      test('''Debe emitir los siguientes estados en el orden esperado
      con un restantWork de 5 y los activities ordenados''', ()async{
        final states = [
          OnLoadingTodayDay(),
          OnShowingTodayDay(
            day: sortedDay,
            restantWork: 2
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(const LoadDay());
      });
    });
    

    group('Cuando el date del evento <no> es null', (){
      late DateTime eventDate;
      setUp((){
        eventDate = DateTime(
          date.year,
          date.month,
          date.day
        );
      });

      test('Debe llamar los métodos esperados cuando el date del evento <no> es null', ()async{
        todayBloc.add(LoadDay(date: eventDate));
        await untilCalled(todayRepository.getDayByDate(any));
        verify(todayRepository.getDayByDate(date));
        verifyNever(currentDateGetter.getCurrentDate());
        verifyNever(commonRepository.getCommonWork());
        verifyNever(todayRepository.createDay(any));
      });

      test('''Debe emitir los siguientes estados en el orden esperado
      con un restantWork de 5 y los activities ordenados''', ()async{
        final states = [
          OnLoadingTodayDay(),
          OnShowingTodayDay(
            day: sortedDay,
            restantWork: 2
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(LoadDay(date: eventDate));
      });
    });
  });

  group('Cuando el repository retorna DBException.empty con current day', (){
    late DayBase newDay;
    late int commonWork;
    late Day createdDay;
    setUp((){
      commonWork = 100;
      when(commonRepository.getCommonWork())
          .thenAnswer((_) async => commonWork);
      newDay = DayBase(
        date: date,
        totalWork: commonWork,
        restantWork: commonWork
      );
      when(todayRepository.getDayByDate(any))
          .thenThrow(const DBException(
            type: DBExceptionType.empty
          ));
      createdDay = Day(
        id: 1000,
        activities: const [],
        date: date,
        totalWork: commonWork,
        restantWork: commonWork
      );
      when(todayRepository.createDay(any))
          .thenAnswer((_) async => createdDay);
      when(currentDateGetter.getCurrentDate())
          .thenReturn(date);
    });

    test('Debe lanzar los siguientes métodos', ()async{
      todayBloc.add(const LoadDay());
      await untilCalled(currentDateGetter.getCurrentDate());
      verify(currentDateGetter.getCurrentDate());
      await untilCalled(todayRepository.getDayByDate(any));
      verify(todayRepository.getDayByDate(date));
      await(commonRepository.getCommonWork());
      verify(commonRepository.getCommonWork());
      await untilCalled(todayRepository.createDay(any));
      verify(todayRepository.createDay(newDay));
    });

    test('Debe emitir los siguientes estados en el orden esperado', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnShowingTodayDay(
          day: createdDay,
          restantWork: commonWork
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(const LoadDay());
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
        totalWork: 50,
        restantWork: 20
      );
      activity = const HabitActivityCreation(
        name: '',
        initialTime: null,
        minutesDuration: 0,
        work: 0
      );
      todayBloc.emit(OnShowingTodayDay(
        day: today,
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
          day: today,
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
        totalWork: 50,
        restantWork: 30
      );
      todayBloc.emit(OnShowingTodayDay(
        day: today,
        restantWork: restantWorK
      ));
    });

    test('''Debe emitir los siguientes estados en el orden esperado
    activity no está completa''', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      final states = [
        OnShowingTodayDayError(
          day: today,
          restantWork: restantWorK,
          message: DayBloc.dayTimeFilledMessage,
          type: ErrorType.general
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
        totalWork: 10,
        restantWork: 5
      );
      initActivity = const HabitActivityCreation(
        name: 'act_x',
        initialTime: null,
        minutesDuration: 10,
        work: 1
      );
      todayBloc.emit(OnCreatingActivity(
        day: currentDay,
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

      group('''Cuando el nuevo initialtime junto con el minutesDuration
      no colisionan con los rangos de tiempos de otras actividades''', (){
        setUp((){
          updatedActivity = HabitActivityCreation(
            name: 'act_x',
            initialTime: formattedTime,
            minutesDuration: 10,
            work: 1
          );
          when(timeRangeCalificator.timeRangesCollide(
            any,
            any,
            any,
            any
          )).thenReturn(false);
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
          await untilCalled(timeRangeCalificator.timeRangesCollide(any, any, any, any));
          verify(timeRangeCalificator.timeRangesCollide(
            formattedTime,
            initActivity.minutesDuration,
            dayActivities[0].initialTime,
            dayActivities[0].minutesDuration
          ));
          await untilCalled(timeRangeCalificator.timeRangesCollide(any, any, any, any));
          verify(timeRangeCalificator.timeRangesCollide(
            formattedTime,
            initActivity.minutesDuration,
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
              day: currentDay,
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
              day: currentDay,
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
      cuando el initialTime <sí> está dentro de alguno de los rangos de duración de las demás activities''', ()async{
        updatedActivity = HabitActivityCreation(
          name: 'act_x',
          initialTime: formattedTime,
          minutesDuration: 10,
          work: 1
        );
        final collidesResponses = [false, true];
        when(timeRangeCalificator.timeRangesCollide(
          any,
          any,
          any,
          any
        )).thenAnswer((_) => collidesResponses.removeAt(0)); 
        final states = [
          OnCreatingActivityError(
            day: currentDay,
            activity: initActivity,
            restantWork: tRestantWork,
            canEnd: false,
            message: DayBloc.currentRangeCollidesWithOtherMessage,
            type: ErrorType.initTimeCollides
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
      when(timeRangeCalificator.timeRangesCollide(
        any,
        any,
        any,
        any
      )).thenReturn(false);
      final states = [
        OnCreatingActivityError(
          day: currentDay,
          activity: initActivity,
          restantWork: tRestantWork,
          canEnd: false,
          message: DayBloc.initialTimeIsOnAnotherActivityRangeMessage,
          type: ErrorType.initTimeCollides
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
      totalWork: 10,
      restantWork: 5
    );
    todayBloc.emit(OnCreatingActivity(
      day: currentDay,
      activity: initActivity,
      restantWork: tRestantWork,
      canEnd: false
    ));
    time = null;
    expectLater(todayBloc.stream, emitsInOrder([]));
    todayBloc.add(UpdateActivityInitialTime(time));
  });
}

void _testUpdateActivityDuration(){
  late List<HabitActivity> currentActivities;
  late Day today;
  late int restantWork;
  late HabitActivityCreation initActivity;
  late String newDuration;
  late int newDurationFormatted;
  setUp((){
    currentActivities = const [
      HabitActivity(
        id: 10,
        name: 'ac_x',
        initialTime: CustomTime(
          hour: 2,
          minute: 2
        ),
        minutesDuration: 10,
        work: 10
      ),
      HabitActivity(
        id: 11,
        name: 'ac_x',
        initialTime: CustomTime(
          hour: 4,
          minute: 2
        ),
        minutesDuration: 30,
        work: 10
      )
    ];
    today = Day(
      id: 0,
      date: const CustomDate(
        day: 20,
        month: 10,
        year: 2020,
        weekDay: 2
      ),
      activities: currentActivities,
      totalWork: 100,
      restantWork: 75
    );
    restantWork = 20;
  });

  group('Cuando hay initial time', (){
    late HabitActivityCreation updatedActivity;
    setUp((){
      initActivity = const HabitActivityCreation(
        name: 'ac_x',
        initialTime: CustomTime(
          hour: 2,
          minute: 2
        ),
        minutesDuration: 0,
        work: 10
      );
      todayBloc.emit(OnCreatingActivity(
        day: today,
        activity: initActivity,
        restantWork: restantWork,
        canEnd: true
      ));
      newDuration = '10';
      newDurationFormatted = 10;
      updatedActivity = HabitActivityCreation(
        name: 'ac_x',
        initialTime: const CustomTime(
          hour: 2,
          minute: 2
        ),
        minutesDuration: newDurationFormatted,
        work: 10
      );
    });

    group('Cuando todo sale bien', (){
      setUp((){
        when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenReturn(false);
      });

      test('Debe llamar los métodos esperados', ()async{
        when(activityCompletitionValidator.isCompleted(any))
            .thenReturn(false);
        todayBloc.add(UpdateActivityMinutesDuration(newDuration));
        await untilCalled(activityCompletitionValidator.isCompleted(any));
        verify(activityCompletitionValidator.isCompleted(updatedActivity));
      });

      test('Debe emitir los siguientes estados en orden cuando canEnd = false', ()async{
        when(activityCompletitionValidator.isCompleted(any))
            .thenReturn(false);
        final states = [
          OnCreatingActivity(
            day: today,
            activity: updatedActivity,
            restantWork: restantWork,
            canEnd: false
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(UpdateActivityMinutesDuration(newDuration));
      });

      test('Debe emitir los siguientes estados en orden cuando canEnd = true', ()async{
        when(activityCompletitionValidator.isCompleted(any))
            .thenReturn(true);
        final states = [
          OnCreatingActivity(
            day: today,
            activity: updatedActivity,
            restantWork: restantWork,
            canEnd: true
          )
        ];
        expectLater(todayBloc.stream, emitsInOrder(states));
        todayBloc.add(UpdateActivityMinutesDuration(newDuration));
      });
    });

  });

  group('Cuando no hay initialTime', (){
    late HabitActivityCreation updatedActivity;
    setUp((){
      initActivity = const HabitActivityCreation(
        name: 'ac_x',
        initialTime: null,
        minutesDuration: 0,
        work: 10
      );
      todayBloc.emit(OnCreatingActivity(
        day: today,
        activity: initActivity,
        restantWork: restantWork,
        canEnd: true
      ));
      newDuration = '1';
      newDurationFormatted = 1;
      updatedActivity = HabitActivityCreation(
        name: 'ac_x',
        initialTime: null,
        minutesDuration: newDurationFormatted,
        work: 10
      );
    });

    test('Debe llamar los métodos esperados', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      todayBloc.add(UpdateActivityMinutesDuration(newDuration));
      verifyNever(timeRangeCalificator.timeRangesCollide(
        any,
        any,
        any,
        any
      ));
      await untilCalled(activityCompletitionValidator.isCompleted(any));
      verify(activityCompletitionValidator.isCompleted(updatedActivity));
    });

    test('Debe emitir los siguientes estados en orden cuando canEnd = false', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(false);
      final states = [
        OnCreatingActivity(
          day: today,
          activity: updatedActivity,
          restantWork: restantWork,
          canEnd: false
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(UpdateActivityMinutesDuration(newDuration));
    });

    test('Debe emitir los siguientes estados en orden cuando canEnd = true', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(true);
      final states = [
        OnCreatingActivity(
          day: today,
          activity: updatedActivity,
          restantWork: restantWork,
          canEnd: true
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(UpdateActivityMinutesDuration(newDuration));
    });
  });
}

void _testCreateActivity(){
  late CustomDate dayDate;
  late List<HabitActivity> initDayActivities;
  late Day initDay;
  late HabitActivityCreation activity;
  late int initRestantWork;
  setUp((){
    dayDate = CustomDate.fromDateTime(
      DateTime.now()
    );
    initDayActivities = const [
      HabitActivity(
        id: 0,
        name: 'ac_0', 
        minutesDuration: 10, 
        work: 8, 
        initialTime: CustomTime(
          hour: 11,
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
    ];
    initRestantWork = 19;
    initDay = Day(
      id: 0,
      date: dayDate,
      activities: initDayActivities,
      totalWork: 30,
      restantWork: initRestantWork
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
    late int updatedRestantWork;
    late Day updatedDay;
    late Day tSortedUpdatedDay;
    setUp((){
      todayBloc.emit(OnCreatingActivity(
        day: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true
      ));
      updatedRestantWork = 9;
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
              hour: 11,
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
        totalWork: 30,
        restantWork: updatedRestantWork
      );
      tSortedUpdatedDay = Day(
        id: 0,
        date: dayDate,
        activities: const [
          HabitActivity(
            id: 1,
            name: 'ac_1', 
            minutesDuration: 20, 
            work: 3, 
            initialTime: CustomTime(
              hour: 10,
              minute: 20
            )
          ),
          HabitActivity(
            id: 0,
            name: 'ac_0', 
            minutesDuration: 10, 
            work: 8, 
            initialTime: CustomTime(
              hour: 11,
              minute: 20
            )
          )
        ],
        totalWork: 30,
        restantWork: updatedRestantWork
      );
      when(todayRepository.setActivityToDay(any, any, any))
          .thenAnswer((_) async => updatedDay);
      when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenReturn(false);
    });

    test('Debe llamar los métodos esperados', ()async{
      todayBloc.add(CreateActivity());
      await untilCalled(todayRepository.setActivityToDay(any, any, any));
      verify(todayRepository.setActivityToDay(
        activity,
        initDay,
        updatedRestantWork
      ));
      await untilCalled(timeRangeCalificator.timeRangesCollide(any, any, any, any));
      verify(timeRangeCalificator.timeRangesCollide(
        activity.initialTime,
        activity.minutesDuration,
        initDayActivities[0].initialTime,
        initDayActivities[0].minutesDuration
      ));
      await untilCalled(timeRangeCalificator.timeRangesCollide(any, any, any, any));
      verify(timeRangeCalificator.timeRangesCollide(
        activity.initialTime,
        activity.minutesDuration,
        initDayActivities[1].initialTime,
        initDayActivities[1].minutesDuration
      ));
    });

    test('''Debe emitir los siguientes estados en el orden esperado
    con un restant work de 9''', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnShowingTodayDay(
          day: tSortedUpdatedDay,
          restantWork: 9
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(CreateActivity());
    });
  });

  test('''Debe emitir los siguientes estados en el orden esperado cuando
  la cantidad de trabajo de la actividad supera a la restante''', ()async{
    when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenReturn(false);
    initRestantWork = 9;
    todayBloc.emit(OnCreatingActivity(
      day: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    final states = [
      OnCreatingActivityError(
        day: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: DayBloc.insufficientRestantWorkMessage,
        type: ErrorType.notEnoughWork
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });

  test('''Debe emitir los siguientes estados en el orden esperado cuando
  la cantidad de trabajo de la actividad supera a la restante''', ()async{
    final collidesResults = [false, true];
    when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenAnswer((_) => collidesResults.removeAt(0));
    initRestantWork = 9;
    todayBloc.emit(OnCreatingActivity(
      day: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    final states = [
      OnCreatingActivityError(
        day: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: DayBloc.currentRangeCollidesWithOtherMessage,
        type: ErrorType.durationCollides
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });

  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <con> mensaje''', ()async{
    when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenReturn(false);
    initRestantWork = 11;
    todayBloc.emit(OnCreatingActivity(
      day: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    const message = 'error_message';
    when(todayRepository.setActivityToDay(any, any, any))
        .thenThrow(const DBException(
          message: message,
          type: DBExceptionType.normal
        ));
    final states = [
      OnLoadingTodayDay(),
      OnCreatingActivityError(
        day: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: message,
        type: ErrorType.general
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
  
  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <sin> mensaje''', ()async{
    when(timeRangeCalificator.timeRangesCollide(any, any, any, any))
          .thenReturn(false);
    initRestantWork = 11;
    todayBloc.emit(OnCreatingActivity(
      day: initDay,
      activity: activity,
      restantWork: initRestantWork,
      canEnd: true
    ));
    when(todayRepository.setActivityToDay(any, any, any))
        .thenThrow(const DBException(
          message: '',
          type: DBExceptionType.normal
        ));
    final states = [
      OnLoadingTodayDay(),
      OnCreatingActivityError(
        day: initDay,
        activity: activity,
        restantWork: initRestantWork,
        canEnd: true,
        message: DayBloc.unexpectedErrorMessage,
        type: ErrorType.general
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
}