import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/today_repository.dart';
part 'today_event.dart';
part 'today_state.dart';

class TodayBloc extends Bloc<TodayEvent, TodayState> {
  static const unexpectedErrorMessage = 'Ha ocurdido un error inesperado';
  final TodayRepository repository;
  final CurrentDateGetter currentDateGetter;
  final ActivityCompletitionValidator activityCompletitionValidator;
  TodayBloc({
    required this.repository,
    required this.currentDateGetter,
    required this.activityCompletitionValidator
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
    emit(OnShowingTodayDay(today: today));
  }

  void _initActivityCreation(Emitter<TodayState> emit){
    final today = (state as OnTodayDay).today;
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
      canEnd: canEnd
    ));
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
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        initialTime: formattedInitialTime
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        today: initialState.today,
        activity: activity,
        canEnd: canEnd
      ));
    }
  }

  void _updateActivityMinutesDuration(Emitter<TodayState> emit, UpdateActivityMinutesDuration event){
    final initialState = (state as OnCreatingActivity);
    final activity = _getActivityCreationFromExistent(
      initialState.activity,
      minutesDuration: event.minutesDuration
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      today: initialState.today,
      activity: activity,
      canEnd: canEnd
    ));
  }

  void _updateActivityWork(Emitter<TodayState> emit, UpdateActivityWork event){
    final initialState = (state as OnCreatingActivity);
    final activity = _getActivityCreationFromExistent(
      initialState.activity,
      work: event.work
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      today: initialState.today,
      activity: activity,
      canEnd: canEnd
    ));
  }

  Future<void> _createActivity(Emitter<TodayState> emit)async{
    final initialState = (state as OnCreatingActivity);
    try{
      emit(OnLoadingTodayDay());
      final updatedDay = await repository.setActivityToDay(
        initialState.activity,
        initialState.today
      );
      emit(OnTodayDay(today: updatedDay));
    }on AppException catch(exception){
      emit(OnCreatingActivityError(
        today: initialState.today,
        activity: initialState.activity,
        canEnd: initialState.canEnd,
        message: exception.message.isNotEmpty? exception.message : unexpectedErrorMessage
      ));
    }
  }

  void _cancelActivityCreation(Emitter<TodayState> emit){
    final initialState = (state as OnCreatingActivity);
    emit(OnTodayDay(
      today: initialState.today
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
