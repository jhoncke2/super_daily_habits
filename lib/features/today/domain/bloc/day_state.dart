part of 'day_bloc.dart';

enum ErrorType{
  general,
  initTimeCollides,
  durationCollides,
  notEnoughWork
}

abstract class DayState extends Equatable {
  const DayState();
  
  @override
  List<Object?> get props => [];
}

class TodayInitial extends DayState {}

abstract class OnError extends DayState{
  String get message;
  ErrorType get type;
}

class OnLoadingTodayDay extends DayState {

}

abstract class OnDay extends DayState{
  final Day day;
  final int restantWork;
  final bool canBeModified;
  const OnDay({
    required this.day,
    required this.restantWork,
    required this.canBeModified
  });
  @override
  List<Object?> get props => [
    day,
    restantWork,
    canBeModified
  ];
}

class OnShowingDay extends OnDay{
  const OnShowingDay({
    required super.day,
    required super.restantWork,
    required super.canBeModified
  });
}

class OnShowingDayError extends OnShowingDay implements OnError{
  @override
  final String message;
  @override
  final ErrorType type;
  const OnShowingDayError({
    required super.day,
    required super.restantWork,
    required super.canBeModified,
    required this.message,
    required this.type
  });
  @override
  List<Object?> get props => [
    ...super.props,
    message,
    type
  ];
}

class OnCreatingActivity extends OnDay{
  final HabitActivityCreation activity;
  final List<HabitActivity> repeatableActivities;
  final HabitActivity? chosenRepeatableActivity;
  final bool canEnd;
  const OnCreatingActivity({
    required super.day,
    required super.restantWork,
    required super.canBeModified,
    required this.activity,
    required this.repeatableActivities,
    required this.chosenRepeatableActivity,
    required this.canEnd
  });
  @override
  List<Object?> get props => [
    activity,
    repeatableActivities,
    chosenRepeatableActivity,
    canEnd
  ];
}

class OnCreatingActivityError extends OnCreatingActivity implements OnError{
  @override
  final String message;
  @override
  final ErrorType type;
  const OnCreatingActivityError({
    required super.day,
    required super.activity,
    required super.restantWork,
    required super.repeatableActivities,
    required super.chosenRepeatableActivity,
    required super.canBeModified,
    required super.canEnd,
    required this.message,
    required this.type
  });
  @override
  List<Object?> get props => [
    ...super.props,
    message,
    type
  ];
}