import 'package:equatable/equatable.dart';

class CustomDate extends Equatable{
  final int year;
  final int month;
  final int day;
  final int weekDay;
  const CustomDate({
    required this.year,
    required this.month,
    required this.day,
    required this.weekDay
  });
  factory CustomDate.fromDateTime(DateTime date) => CustomDate(
    year: date.year,
    month: date.month,
    day: date.day,
    weekDay: date.weekday
  );
  @override
  List<Object?> get props => [
    year,
    month,
    day,
    weekDay
  ];

}