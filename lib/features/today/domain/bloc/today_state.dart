part of 'today_bloc.dart';

abstract class TodayState extends Equatable {
  const TodayState();
  
  @override
  List<Object> get props => [];
}

class TodayInitial extends TodayState {}

abstract class OnError extends TodayState{
  String get message;
}

class OnLoadingTodayDay extends TodayState {

}

abstract class OnTodayDay extends TodayState{
  final Day today;
  const OnTodayDay({
    required this.today
  });
  @override
  List<Object> get props => [
    today
  ];
}

class OnShowingTodayDay extends OnTodayDay{
  const OnShowingTodayDay({
    required super.today
  });
}

class OnShowingTodayDayError extends OnShowingTodayDay implements OnError{
  @override
  final String message;
  const OnShowingTodayDayError({
    required super.today,
    required this.message
  });
  @override
  List<Object> get props => [
    message
  ];
}

class OnCreatingActivity extends OnTodayDay{
  final HabitActivityCreation activity;
  final bool canEnd;
  const OnCreatingActivity({
    required super.today,
    required this.activity,
    required this.canEnd
  });
  @override
  List<Object> get props => [
    activity,
    canEnd
  ];
}

class OnCreatingActivityError extends OnCreatingActivity implements OnError{
  @override
  final String message;
  const OnCreatingActivityError({
    required super.today,
    required super.activity,
    required super.canEnd,
    required this.message
  });
  @override
  List<Object> get props => [
    message
  ];
}