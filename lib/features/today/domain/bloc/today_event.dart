part of 'today_bloc.dart';

abstract class TodayEvent extends Equatable {
  const TodayEvent();

  @override
  List<Object> get props => [];
}

class LoadDay extends TodayEvent{
  final DateTime? date;
  const LoadDay({
    this.date
  });
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
  final String minutesDuration;
  const UpdateActivityMinutesDuration(this.minutesDuration);
}

class UpdateActivityWork extends TodayEvent{
  final String work;
  const UpdateActivityWork(this.work);
}

class CreateActivity extends TodayEvent{

}

class CancelActivityCreation extends TodayEvent{
  
}
