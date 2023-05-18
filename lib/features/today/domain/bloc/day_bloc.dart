import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:super_daily_habits/common/domain/common_repository.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
import 'package:super_daily_habits/features/today/domain/entities/initial_time_addition_restriction.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'package:super_daily_habits/features/today/domain/day_repository.dart';
part 'day_event.dart';
part 'day_state.dart';

class DayBloc extends Bloc<DayEvent, DayState> {
  static const unexpectedErrorMessage = 'Ha ocurdido un error inesperado';
  static const insufficientRestantWorkMessage = 'No hay suficiente trabajo disponible';
  static const dayTimeFilledMessage = 'El tiempo del día está completamente lleno';
  static const initialTimeIsOnAnotherActivityRangeMessage = 'El tiempo elegido colisiona con el rango de tiempo de otra actividad';
  static const currentRangeCollidesWithOtherMessage = 'El rango de tiempo de esta actividad colisiona con el de otra';
  static const maxDayMinutes = 1440;
  final DayRepository repository;
  final CommonRepository commonRepository;
  final CurrentDateGetter currentDateGetter;
  final ActivityCompletitionValidator activityCompletitionValidator;
  final TimeRangeCalificator timeRangeCalificator;
  DayBloc({
    required this.repository,
    required this.commonRepository,
    required this.currentDateGetter,
    required this.activityCompletitionValidator,
    required this.timeRangeCalificator
  }) : super(TodayInitial()) {
    on<DayEvent>((event, emit)async{
      if(event is LoadDay){
        await _loadDay(emit, event);
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

  Future<void> _loadDay(Emitter<DayState> emit, LoadDay event)async{
    emit(OnLoadingTodayDay());
    late CustomDate date;
    if(event.date == null){
      date = currentDateGetter.getCurrentDate();
    }else{
      date = CustomDate.fromDateTime(event.date!);
    }
    try{
      await _tryLoadDay(date, emit);
    }on DBException catch(exception){
      if(exception.type == DBExceptionType.empty){
        await _manageLoadDayEmptyDBException(date, emit);
      }
    }
  }

  Future<void> _tryLoadDay(CustomDate date, Emitter<DayState> emit)async{
    var day = await repository.getDayByDate(date);
    final activities = _getSortedActivities(day.activities);
    day = _createDayFromExistent(
      day,
      activities: activities
    );
    final restantWork = _calculateRestantWork(
      day.totalWork,
      day.activities
    );
    emit(OnShowingTodayDay(
      day: day,
      restantWork: restantWork
    ));
  }

  Future<void> _manageLoadDayEmptyDBException(CustomDate date, Emitter<DayState> emit)async{
    final commonWork = await commonRepository.getCommonWork();
    final newDay = await repository.createDay(DayBase(
      totalWork: commonWork,
      restantWork: commonWork,
      date: date
    ));
    emit(OnShowingTodayDay(
      day: newDay,
      restantWork: commonWork
    ));
  }

  List<HabitActivity> _getSortedActivities(List<HabitActivity> activities) =>
    activities.toList()
      ..sort(
        (act1, act2) => 
          act1.initialTime.hour > act2.initialTime.hour?
          1: act1.initialTime.hour < act2.initialTime.hour?
            -1: act1.initialTime.minute > act2.initialTime.minute?
              1: act1.initialTime.minute < act2.initialTime.minute?
              -1: 0
      );

  Day _createDayFromExistent(
    Day day,
    {
      List<HabitActivity>? activities
    }
  ) => Day(
    id: day.id,
    date: day.date,
    activities: activities ?? day.activities,
    totalWork: day.totalWork,
    restantWork: day.restantWork
  );

  int _calculateRestantWork(int totalWork, List<HabitActivity> activities){
    final usedWork = activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.work
    );
    return totalWork - usedWork;
  }

  void _initActivityCreation(Emitter<DayState> emit){
    final initialState = state as OnTodayDay;
    final totalDuration = initialState.day.activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.minutesDuration
    );
    if(totalDuration < maxDayMinutes){
      _continueActivityCreationWithEnoughDayMinutes(emit, initialState);
    }else{
      emit(OnShowingTodayDayError(
        day: initialState.day,
        restantWork: initialState.restantWork,
        message: dayTimeFilledMessage,
        type: ErrorType.general
      ));
    }
  }

  void _continueActivityCreationWithEnoughDayMinutes(Emitter<DayState> emit, OnTodayDay initialState){
    final today = initialState.day;
    const activity = HabitActivityCreation(
      name: '',
      initialTime: null,
      minutesDuration: 0,
      work: 0
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      day: today,
      activity: activity,
      //TODO: Implementar data real desde el caso de uso
      repeatablesActivities: [],
      restantWork: initialState.restantWork,
      canEnd: canEnd
    ));
  }

  void _updateActivityName(Emitter<DayState> emit, UpdateActivityName event){
    final initialState = (state as OnCreatingActivity);
    final activity = _getActivityCreationFromExistent(
      initialState.activity,
      name: event.name
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      day: initialState.day,
      activity: activity,
      repeatablesActivities: initialState.repeatablesActivities,
      restantWork: initialState.restantWork,
      canEnd: canEnd
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

  void _updateActivityInitialTime(Emitter<DayState> emit, UpdateActivityInitialTime event){
    if(event.initialTime != null){
      final initialState = (state as OnCreatingActivity);
      final formattedInitialTime = CustomTime(
        hour: event.initialTime!.hour,
        minute: event.initialTime!.minute
      );
      final timeAdditionRestriction = _defineTimeAdditionRestriction(initialState, formattedInitialTime);
      if(timeAdditionRestriction.timeIsBetweenAnyActivityRange || timeAdditionRestriction.newRangeCollides){
        _emitInitialTimeAdditionError(emit, initialState, timeAdditionRestriction);
      }else{
        _emitInitialTimeAdditionSuccess(initialState, formattedInitialTime, emit);
      }
    }
  }
  
  InitialTimeAdditionRestriction _defineTimeAdditionRestriction(OnCreatingActivity initialState, CustomTime formattedInitialTime){
    final activities = initialState.day.activities;
    bool timeIsBetweenAnyActivityRange = false;
    bool newRangeCollides = false;
    for(int i = 0; i < activities.length && !timeIsBetweenAnyActivityRange; i++){
      final currentActivity = activities[i];
      timeIsBetweenAnyActivityRange |= timeRangeCalificator.timeIsBetweenTimeRange(
        formattedInitialTime,
        currentActivity.initialTime,
        currentActivity.minutesDuration
      );
      newRangeCollides |= timeRangeCalificator.timeRangesCollide(
        formattedInitialTime,
        initialState.activity.minutesDuration,
        currentActivity.initialTime,
        currentActivity.minutesDuration
      );
    }
    return InitialTimeAdditionRestriction(
      timeIsBetweenAnyActivityRange: timeIsBetweenAnyActivityRange,
      newRangeCollides: newRangeCollides
    );
  }

  void _emitInitialTimeAdditionError(Emitter<DayState> emit, OnCreatingActivity initialState, InitialTimeAdditionRestriction timeAdditionRestriction){
    emit(OnCreatingActivityError(
      day: initialState.day,
      activity: initialState.activity,
      repeatablesActivities: initialState.repeatablesActivities,
      restantWork: initialState.restantWork,
      canEnd: initialState.canEnd,
      message: timeAdditionRestriction.timeIsBetweenAnyActivityRange? 
        initialTimeIsOnAnotherActivityRangeMessage :
        currentRangeCollidesWithOtherMessage,
      type: ErrorType.initTimeCollides
    ));
  }

  void _emitInitialTimeAdditionSuccess(OnCreatingActivity initialState, CustomTime formattedInitialTime, Emitter<DayState> emit){
    final activity = _getActivityCreationFromExistent(
      initialState.activity,
      initialTime: formattedInitialTime
    );
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      day: initialState.day,
      activity: activity,
      repeatablesActivities: initialState.repeatablesActivities,
      restantWork: initialState.restantWork,
      canEnd: canEnd
    ));
  }

  void _updateActivityMinutesDuration(Emitter<DayState> emit, UpdateActivityMinutesDuration event){
    try{
      final initialState = (state as OnCreatingActivity);
      final duration = int.parse(event.minutesDuration);
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        minutesDuration: duration
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        day: initialState.day,
        activity: activity,
        repeatablesActivities: initialState.repeatablesActivities,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }on Object catch(_){

    }
  }

  void _updateActivityWork(Emitter<DayState> emit, UpdateActivityWork event){
    try{
      final initialState = (state as OnCreatingActivity);
      final activity = _getActivityCreationFromExistent(
        initialState.activity,
        work: int.parse(event.work)
      );
      final canEnd = activityCompletitionValidator.isCompleted(activity);
      emit(OnCreatingActivity(
        day: initialState.day,
        activity: activity,
        repeatablesActivities: initialState.repeatablesActivities,
        restantWork: initialState.restantWork,
        canEnd: canEnd
      ));
    }on Object catch(_){

    }
  }

  Future<void> _createActivity(Emitter<DayState> emit)async{
    final initialState = (state as OnCreatingActivity);
    final activity = initialState.activity;
    try{
      final currentRangeCollides = _currentRangeCollides(
        emit,
        initialState
      );
      final thereIsEnoughDayWork = activity.work <= initialState.restantWork;
      if(thereIsEnoughDayWork && !currentRangeCollides){
        await _endActivityCreation(emit, initialState);
      }else{
        emit(OnCreatingActivityError(
          day: initialState.day,
          activity: activity,
          repeatablesActivities: initialState.repeatablesActivities,
          restantWork: initialState.restantWork,
          canEnd: initialState.canEnd,
          message: currentRangeCollides?
            currentRangeCollidesWithOtherMessage: 
            insufficientRestantWorkMessage,
          type: currentRangeCollides?
            ErrorType.durationCollides:
            ErrorType.notEnoughWork
        ));
      }
    }on AppException catch(exception){
      emit(OnCreatingActivityError(
        day: initialState.day,
        activity: activity,
        repeatablesActivities: initialState.repeatablesActivities,
        restantWork: initialState.restantWork,
        canEnd: initialState.canEnd,
        message: exception.message.isNotEmpty? exception.message : unexpectedErrorMessage,
        type: ErrorType.general
      ));
    }
  }

  Future<void> _endActivityCreation(Emitter<DayState> emit, OnCreatingActivity initialState)async{
    emit(OnLoadingTodayDay());
    final day = initialState.day;
    final activity = initialState.activity;
    final updatedRestantWork = day.restantWork - activity.work;
    var updatedDay = await repository.setActivityToDay(
      activity,
      day,
      updatedRestantWork
    );
    final activities = _getSortedActivities(updatedDay.activities);
    updatedDay = _createDayFromExistent(
      updatedDay,
      activities: activities
    );
    emit(OnShowingTodayDay(
      day: updatedDay,
      restantWork: updatedRestantWork
    ));
  }

  bool _currentRangeCollides(Emitter<DayState> emit, OnCreatingActivity initialState){
    bool currentRangeCollides = false;
    final activities = initialState.day.activities;
    for(int i = 0; i < activities.length && !currentRangeCollides; i++){
      final activity = activities[i];
      currentRangeCollides |= timeRangeCalificator.timeRangesCollide(
        initialState.activity.initialTime!,
        initialState.activity.minutesDuration,
        activity.initialTime,
        activity.minutesDuration
      );
    }
    return currentRangeCollides;
  }

  void _cancelActivityCreation(Emitter<DayState> emit){
    final initialState = (state as OnCreatingActivity);
    emit(OnShowingTodayDay(
      day: initialState.day,
      restantWork: initialState.restantWork
    ));
  }
}