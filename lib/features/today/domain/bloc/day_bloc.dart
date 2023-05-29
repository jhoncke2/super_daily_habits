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
import 'package:super_daily_habits/features/today/domain/helpers/activity_text_controllers_generator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/day_calificator.dart';
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
  final ActivityTextControllersGenerator activityTextControllersGenerator;
  final CurrentDateGetter currentDateGetter;
  final ActivityCompletitionValidator activityCompletitionValidator;
  final TimeRangeCalificator timeRangeCalificator;
  final DayCalificator dayCalificator;
  DayBloc({
    required this.repository,
    required this.commonRepository,
    required this.activityTextControllersGenerator,
    required this.currentDateGetter,
    required this.activityCompletitionValidator,
    required this.timeRangeCalificator,
    required this.dayCalificator
  }) : super(TodayInitial()) {
    on<DayEvent>((event, emit)async{
      if(event is LoadDay){
        await _loadDay(emit, event);
      }else if(event is InitActivityCreation){
        await _initActivityCreation(emit);
      }else if(event is ChooseRepeatableActivity){
        _chooseRepeatableActivity(emit, event);
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
      date = currentDateGetter.getTodayDate();
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
    final todayDate = currentDateGetter.getTodayDate();
    final canBeModified = dayCalificator.canBeModified(day, todayDate);
    emit(OnShowingDay(
      day: day,
      restantWork: day.restantWork,
      canBeModified: canBeModified
    ));
  }

  Future<void> _manageLoadDayEmptyDBException(CustomDate date, Emitter<DayState> emit)async{
    final commonWork = await commonRepository.getCommonWork();
    final newDay = await repository.createDay(DayBase(
      totalWork: commonWork,
      restantWork: commonWork,
      date: date
    ));
    final todayDate = currentDateGetter.getTodayDate();
    final canBeModified = dayCalificator.canBeModified(newDay, todayDate);
    emit(OnShowingDay(
      day: newDay,
      restantWork: commonWork,
      canBeModified: canBeModified
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

  Future<void> _initActivityCreation(Emitter<DayState> emit)async{
    final initialState = state as OnDay;
    final totalDuration = initialState.day.activities.fold<int>(
      0,
      (previousValue, activity) => previousValue + activity.minutesDuration
    );
    if(totalDuration < maxDayMinutes){
      await _continueActivityCreationInitWithEnoughDayMinutes(emit, initialState);
    }else{
      emit(OnShowingDayError(
        day: initialState.day,
        restantWork: initialState.restantWork,
        message: dayTimeFilledMessage,
        type: ErrorType.general,
        canBeModified: initialState.canBeModified
      ));
    }
  }

  Future<void> _continueActivityCreationInitWithEnoughDayMinutes(Emitter<DayState> emit, OnDay initialState)async{
    final repeatableActivities = await repository.getAllRepeatableActivities();
    final today = initialState.day;
    const activity = HabitActivityCreation(
      name: '',
      initialTime: null,
      minutesDuration: 0,
      work: 0,
      repeatability: ActivityRepeatability.none
    );
    activityTextControllersGenerator.generate();
    final canEnd = activityCompletitionValidator.isCompleted(activity);
    emit(OnCreatingActivity(
      day: today,
      activity: activity,
      repeatableActivities: repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: null,
      activityControllersContainer: activityTextControllersGenerator,
      canEnd: canEnd,
      canBeModified: initialState.canBeModified,
    ));
  }

  void _chooseRepeatableActivity(Emitter<DayState> emit, ChooseRepeatableActivity event){
    final initialState = (state as OnCreatingActivity);
    final eventActivity = event.activity!;
    final newActivity = HabitActivityCreation(
      name: eventActivity.name,
      minutesDuration: eventActivity.minutesDuration,
      work: eventActivity.work,
      initialTime: eventActivity.initialTime,
      repeatability: ActivityRepeatability.repeated
    );
    final canEnd = activityCompletitionValidator.isCompleted(newActivity);
    activityTextControllersGenerator.updateNameController(eventActivity.name);
    activityTextControllersGenerator.updateMinutesDurationController('${eventActivity.minutesDuration}');
    activityTextControllersGenerator.updateWorkController('${eventActivity.work}');
    emit(OnCreatingActivity(
      day: initialState.day,
      activity: newActivity,
      repeatableActivities: initialState.repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: event.activity,
      activityControllersContainer: initialState.activityControllersContainer,
      canEnd: canEnd,
      canBeModified: initialState.canBeModified
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
      repeatableActivities: initialState.repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: initialState.chosenRepeatableActivity,
      activityControllersContainer: initialState.activityControllersContainer,
      canEnd: canEnd,
      canBeModified: initialState.canBeModified
    ));
  }

  HabitActivityCreation _getActivityCreationFromExistent(
    HabitActivityCreation activity,
    {
      String? name,
      CustomTime? initialTime,
      int? minutesDuration,
      int? work,
      ActivityRepeatability? repeatability
    }
  ) => HabitActivityCreation(
    name: name ?? activity.name,
    initialTime: initialTime ?? activity.initialTime,
    minutesDuration: minutesDuration ?? activity.minutesDuration,
    work: work ?? activity.work,
    repeatability: repeatability ?? activity.repeatability
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
      repeatableActivities: initialState.repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: initialState.chosenRepeatableActivity,
      activityControllersContainer: initialState.activityControllersContainer,
      canEnd: initialState.canEnd,
      message: timeAdditionRestriction.timeIsBetweenAnyActivityRange? 
        initialTimeIsOnAnotherActivityRangeMessage :
        currentRangeCollidesWithOtherMessage,
      type: ErrorType.initTimeCollides,
      canBeModified: initialState.canBeModified
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
      repeatableActivities: initialState.repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: initialState.chosenRepeatableActivity,
      activityControllersContainer: initialState.activityControllersContainer,
      canEnd: canEnd,
      canBeModified: initialState.canBeModified
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
        repeatableActivities: initialState.repeatableActivities,
        restantWork: initialState.restantWork,
        chosenRepeatableActivity: initialState.chosenRepeatableActivity,
        activityControllersContainer: initialState.activityControllersContainer,
        canEnd: canEnd,
        canBeModified: initialState.canBeModified
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
        repeatableActivities: initialState.repeatableActivities,
        restantWork: initialState.restantWork,
        chosenRepeatableActivity: initialState.chosenRepeatableActivity,
        activityControllersContainer: initialState.activityControllersContainer,
        canEnd: canEnd,
        canBeModified: initialState.canBeModified
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
        _emitActivityCreationError(
          emit,
          initialState,
          currentRangeCollides?
            currentRangeCollidesWithOtherMessage: 
            insufficientRestantWorkMessage,
          currentRangeCollides?
            ErrorType.durationCollides:
            ErrorType.notEnoughWork
        );
      }
    }on AppException catch(exception){
       _emitActivityCreationError(
        emit,
        initialState,
        exception.message.isNotEmpty?
          exception.message:
          unexpectedErrorMessage,
        ErrorType.general
      );
    }
  }

  void _emitActivityCreationError(Emitter<DayState> emit, OnCreatingActivity initialState, String errorMessage, ErrorType errorType){
    emit(OnCreatingActivityError(
      day: initialState.day,
      activity: initialState.activity,
      repeatableActivities: initialState.repeatableActivities,
      restantWork: initialState.restantWork,
      chosenRepeatableActivity: initialState.chosenRepeatableActivity,
      activityControllersContainer: initialState.activityControllersContainer,
      canEnd: initialState.canEnd,
      message: errorMessage,
      type: errorType,
      canBeModified: initialState.canBeModified
    ));
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
    emit(OnShowingDay(
      day: updatedDay,
      restantWork: updatedRestantWork,
      canBeModified: initialState.canBeModified
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
    emit(OnShowingDay(
      day: initialState.day,
      restantWork: initialState.restantWork,
      canBeModified: initialState.canBeModified
    ));
  }
}