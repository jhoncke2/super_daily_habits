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
import 'package:super_daily_habits/features/today/domain/today_repository.dart';
import 'dotay_bloc_test.mocks.dart';

late TodayBloc todayBloc;
late MockTodayRepository todayRepository;
late MockCurrentDateGetter currentDateGetter;
late MockActivityCompletitionValidator activityCompletitionValidator;

@GenerateMocks([
  TodayRepository,
  CurrentDateGetter,
  ActivityCompletitionValidator
])
void main(){
  setUp((){
    activityCompletitionValidator = MockActivityCompletitionValidator();
    currentDateGetter = MockCurrentDateGetter();
    todayRepository = MockTodayRepository();
    todayBloc = TodayBloc(
      repository: todayRepository,
      currentDateGetter: currentDateGetter,
      activityCompletitionValidator: activityCompletitionValidator
    );
  });

  group('load day by current date', _testLoadDayByCurrentDate);
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
        activities: [],
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
    test('Debe emitir los siguientes estados en el orden esperado', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnShowingTodayDay(today: currentDay)
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(LoadDayByCurrentDate());
    });
  });
}

void _testUpdateActivityInitialTime(){
  late Day currentDay;
  late TimeOfDay? time;
  late HabitActivityCreation initActivity;
  setUp((){
    currentDay = Day(
      id: 100,
      date: CustomDate.fromDateTime(
        DateTime.now()
      ),
      activities: [],
      work: 10
    );
    initActivity = const HabitActivityCreation(
      name: 'act_x',
      initialTime: null,
      minutesDuration: 10,
      work: 1
    );
    todayBloc.emit(OnCreatingActivity(
      today: currentDay,
      activity: initActivity,
      canEnd: false
    ));
    when(todayRepository.getDayByDate(any))
        .thenAnswer((_) async => currentDay);
  });

  group('Cuando el date es != null', (){
    late CustomTime formattedTime;
    late HabitActivityCreation updatedActivity;
    setUp((){
      time = const TimeOfDay(hour: 10, minute: 20);
      formattedTime = const CustomTime(hour: 10, minute: 20);
      updatedActivity = HabitActivityCreation(
        name: 'act_x',
        initialTime: formattedTime,
        minutesDuration: 10,
        work: 1
      );
    });

    test('Debe llamar los métodos esperados', ()async{
      when(activityCompletitionValidator.isCompleted(any))
          .thenReturn(true);
      todayBloc.add(UpdateActivityInitialTime(time));
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
          canEnd: false
        )
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(UpdateActivityInitialTime(time));
    });
  });

  test('''Debe emitir los siguientes estados en el orden esperado
  cuando el time es null''', ()async{
    time = null;
    expectLater(todayBloc.stream, emitsInOrder([]));
    todayBloc.add(UpdateActivityInitialTime(time));
  });
}

void _testCreateActivity(){
  late CustomDate dayDate;
  late Day initDay;
  late HabitActivityCreation activity;
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
      work: 20
    );
    todayBloc.emit(OnCreatingActivity(
      today: initDay,
      activity: activity,
      canEnd: true
    ));
  });

  group('Cuando todo sale bien', (){
    late Day updatedDay;
    setUp((){
      updatedDay = Day(
        id: 0,
        date: dayDate,
        activities: const [
          HabitActivity(
            id: 1000,
            name: 'act_x',
            initialTime: CustomTime(
              hour: 20,
              minute: 10
            ),
            minutesDuration: 10,
            work: 20
          )
        ],
        work: 10
      );
      when(todayRepository.setActivityToDay(any, any))
          .thenAnswer((_) async => updatedDay);
    });

    test('Debe llamar los métodos esperados', ()async{
      todayBloc.add(CreateActivity());
      await untilCalled(todayRepository.setActivityToDay(any, any));
      verify(todayRepository.setActivityToDay(activity, initDay));
    });

    test('Debe emitir los siguientes estados en el orden esperado', ()async{
      final states = [
        OnLoadingTodayDay(),
        OnTodayDay(today: updatedDay)
      ];
      expectLater(todayBloc.stream, emitsInOrder(states));
      todayBloc.add(CreateActivity());
    });
  });

  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <con> menesaje''', ()async{
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
        canEnd: true,
        message: message
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
  
  test('''Debe emitir los siguientes estados en el orden esperados
  cuando ocurre un AppException <sin> menesaje''', ()async{
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
        canEnd: true,
        message: TodayBloc.unexpectedErrorMessage
      )
    ];
    expectLater(todayBloc.stream, emitsInOrder(states));
    todayBloc.add(CreateActivity());
  });
}