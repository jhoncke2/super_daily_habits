part of 'today_bloc.dart';

abstract class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object> get props => [];
}

class LoadDayByCurrentDate extends TodayEvent{

}

class InitActivityCreation extends TodayEvent{
  
}

class UpdateActivityName extends TodayEvent{
  final String name;
  const UpdateActivityName(this.name);
}

class UpdateActivityInitialTime extends TodayEvent{
  final TimeOfDay? initialTime;
  const UpdateActivityInitialTime(this.initialTime);
}

class UpdateActivityMinutesDuration extends TodayEvent{
  final int minutesDuration;
  const UpdateActivityMinutesDuration(this.minutesDuration);
}

class UpdateActivityWork extends TodayEvent{
  final int work;
  const UpdateActivityWork(this.work);
}

class CreateActivity extends TodayEvent{

}

class CancelActtivityCreation extends TodayEvent{
  
}
