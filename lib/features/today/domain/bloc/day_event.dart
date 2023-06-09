part of 'day_bloc.dart';

abstract class DayEvent extends Equatable {
  const DayEvent();

  @override
  List<Object> get props => [];
}

class LoadDay extends DayEvent{
  final DateTime? date;
  const LoadDay({
    this.date
  });
}

class InitActivityCreation extends DayEvent{
  
}

class ChooseRepeatableActivity extends DayEvent{
  final int? index;
  const ChooseRepeatableActivity(this.index);
}

class UpdateActivityName extends DayEvent{
  final String name;
  const UpdateActivityName(this.name);
}

class UpdateActivityInitialTime extends DayEvent{
  final TimeOfDay? initialTime;
  const UpdateActivityInitialTime(this.initialTime);
}

class UpdateActivityMinutesDuration extends DayEvent{
  final String minutesDuration;
  const UpdateActivityMinutesDuration(this.minutesDuration);
}

class UpdateActivityWork extends DayEvent{
  final String work;
  const UpdateActivityWork(this.work);
}

class ChangeSaveActivityToRepeat extends DayEvent{
  const ChangeSaveActivityToRepeat();
}

class CreateActivity extends DayEvent{

}

class CancelActivityCreation extends DayEvent{
  
}
