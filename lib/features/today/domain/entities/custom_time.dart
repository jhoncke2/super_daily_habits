import 'package:equatable/equatable.dart';

class CustomTime extends Equatable{
  final int hour;
  final int minute;
  const CustomTime(this.hour, this.minute);
  @override
  List<Object?> get props => [
    hour,
    minute
  ];
}