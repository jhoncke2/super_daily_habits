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

abstract class OnTodayDay extends DayState{
  final Day day;
  final int restantWork;
  const OnTodayDay({
    required this.day,
    required this.restantWork
  });
  @override
  List<Object?> get props => [
    day,
    restantWork
  ];
}

class OnShowingTodayDay extends OnTodayDay{
  const OnShowingTodayDay({
    required super.day,
    required super.restantWork
  });
}

class OnShowingTodayDayError extends OnShowingTodayDay implements OnError{
  @override
  final String message;
  @override
  final ErrorType type;
  const OnShowingTodayDayError({
    required super.day,
    required super.restantWork,
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

class OnCreatingActivity extends OnTodayDay{
  final HabitActivityCreation activity;
  final List<HabitActivity> repeatablesActivities;
  final bool canEnd;
  const OnCreatingActivity({
    required super.day,
    required super.restantWork,
    required this.activity,
    required this.repeatablesActivities,
    required this.canEnd
  });
  @override
  List<Object> get props => [
    activity,
    repeatablesActivities,
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
    required super.repeatablesActivities,
    required super.canEnd,
    required this.message,
    required this.type
  });
  @override
  List<Object> get props => [
    ...super.props,
    message,
    type
  ];
}