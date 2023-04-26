import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'package:super_daily_habits/features/today/domain/today_repository.dart';
part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  static const unexpectedErrorMessage = 'Ha ocurdido un error inesperado';
  static const insufficientRestantWorkMessage = 'No hay suficiente trabajo disponible';
  static const dayTimeFilledMessage = 'El tiempo del día está completamente lleno';
  static const initialTimeIsOnAnotherActivityRangeMessage = 'El tiempo elegido colisiona con el rango de tiempo de otra actividad';
  static const maxDayMinutes = 1440;
  final TodayRepository repository;
  final CurrentDateGetter currentDateGetter;
  final ActivityCompletitionValidator activityCompletitionValidator;
  final TimeRangeCalificator timeRangeCalificator;
  TodayBloc({
    required this.repository,
    required this.currentDateGetter,
    required this.activityCompletitionValidator,
    required this.timeRangeCalificator
  }) : super(TodayInitial()) {
    on<TodayEvent>((event, emit)async{
      if(event is LoadDayByCurrentDate){
        await _loadDayByCurrentDate(emit);
      }else if(event is InitActivityCreation){
        _initActivityCreation(emit);
      }else if(event is UpdateActivityName){
        _updateActivityName(emit, event);
      }else if(event is UpdateActivityInitialTime){
        _updateActivityInitialTime(emit, event);
      }else if(event is UpdateActivityMinutesDuration){
        _updateActivityMinutesDuration(emit, event);
      }else if(event is UpdateActivityWork){
        _updateActivityWork(emit, event);
      }else if(event is CreateActivity){
        await _createActivity(emit);
      }else if(event is CancelActivityCreation){
        _cancelActivityCreation(emit);
      }
    });
  }

  Future<void> _loadDayByCurrentDate(Emitter<TodayState> emit)async{
    emit(OnLoadingTodayDay());
    final currentDate = currentDateGetter.getCurrentDate();
    final today = await repository.getDayByDate(currentDate);
    final restantWork = _calculateRestantWork(today);
    emit(OnShowingTodayDay(
      today: today,
      restantWork: restantWork
    ));
  }

  int _calculateRestantWork(Day day){
    final usedWork = day.activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.work
    );
    return day.work - usedWork;
  }

  void _initActivityCreation(Emitter<TodayState> emit){
    final initialState = state as OnTodayDay;
    final totalDuration = initialState.today.activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.minutesDuration
    );
    if(totalDuration < maxDayMinutes){
      final today = initialState.today;
      const activity = HabitActivityCreation(
        name: '',
        initialTime: null,
        minutesDuration: 0,
        work: 0
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        today: today,
        activity: activity,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }else{
      emit(OnShowingTodayDayError(
        today: initialState.today,
        restantWork: initialState.restantWork,
        message: dayTimeFilledMessage
      ));
    }
  }

  void _updateActivityName(Emitter<TodayState> emit, UpdateActivityName event){
    final initialState = (state as OnCreatingActivity);
    final activity = _getActivityCreationFromExistent(
      initialState.activity,
      name: event.name
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      today: initialState.today,
      activity: activity,
      restantWork: initialState.restantWork,
      canEnd: canEnd
    ));
  }

  void _updateActivityInitialTime(Emitter<TodayState> emit, UpdateActivityInitialTime event){
    if(event.initialTime != null){
      final initialState = (state as OnCreatingActivity);
      final formattedInitialTime = CustomTime(
        hour: event.initialTime!.hour,
        minute: event.initialTime!.minute
      );
      //TODO: Implementar caso de cuando el nuevo initial time está dentro de uno de los rangos de las demás activities
      final activities = initialState.today.activities;
      for (var activity in activities) {
        timeRangeCalificator.timeIsBetweenTimeRange(
          formattedInitialTime,
          activity.initialTime,
          activity.minutesDuration
        );
      }
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        initialTime: formattedInitialTime
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        today: initialState.today,
        activity: activity,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }
  }

  void _updateActivityMinutesDuration(Emitter<TodayState> emit, UpdateActivityMinutesDuration event){
    try{
      final initialState = (state as OnCreatingActivity);
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        minutesDuration: int.parse(event.minutesDuration)
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        today: initialState.today,
        activity: activity,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }on Object catch(_){

    }
  }

  void _updateActivityWork(Emitter<TodayState> emit, UpdateActivityWork event){
    try{
      final initialState = (state as OnCreatingActivity);
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        work: int.parse(event.work)
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        today: initialState.today,
        activity: activity,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }on Object catch(_){

    }
  }

  Future<void> _createActivity(Emitter<TodayState> emit)async{
    final initialState = (state as OnCreatingActivity);
    try{
      final activity = initialState.activity;
      if(activity.work <= initialState.restantWork){
        emit(OnLoadingTodayDay());
        final updatedDay = await repository.setActivityToDay(
          activity,
          initialState.today
        );
        final restantWork = _calculateRestantWork(updatedDay);
        emit(OnShowingTodayDay(
          today: updatedDay,
          restantWork: restantWork
        ));
      }else{
        emit(OnCreatingActivityError(
          today: initialState.today,
          activity: initialState.activity,
          restantWork: initialState.restantWork,
          canEnd: initialState.canEnd,
          message: insufficientRestantWorkMessage
        ));
      }
    }on AppException catch(exception){
      emit(OnCreatingActivityError(
        today: initialState.today,
        activity: initialState.activity,
        restantWork: initialState.restantWork,
        canEnd: initialState.canEnd,
        message: exception.message.isNotEmpty? exception.message : unexpectedErrorMessage
      ));
    }
  }

  void _cancelActivityCreation(Emitter<TodayState> emit){
    final initialState = (state as OnCreatingActivity);
    emit(OnShowingTodayDay(
      today: initialState.today,
      restantWork: initialState.restantWork
    ));
  }

  HabitActivityCreation _getActivityCreationFromExistent(
    HabitActivityCreation activity,
    {
      String? name,
      CustomTime? initialTime,
      int? minutesDuration,
      int? work
    }
  ) => HabitActivityCreation(
    name: name ?? activity.name,
    initialTime: initialTime ?? activity.initialTime,
    minutesDuration: minutesDuration ?? activity.minutesDuration,
    work: work ?? activity.work
  );
}