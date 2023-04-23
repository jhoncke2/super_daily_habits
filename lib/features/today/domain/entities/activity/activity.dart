import 'package:equatable/equatable.dart';

abstract class Activity extends Equatable{
  final int minutesDuration;
  final int work;
  final String name;
  const Activity({
    required this.minutesDuration,
    required this.work,
    required this.name
  });
  @override
  List<Object?> get props => [
    minutesDuration,
    work,
    name
  ];
}