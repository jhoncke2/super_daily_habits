import 'package:equatable/equatable.dart';

class CustomTime extends Equatable{
  final int hour;
  final int minute;
  const CustomTime({
    required this.hour,
    required this.minute
  });
  @override
  List<Object?> get props => [
    hour,
    minute
  ];
}