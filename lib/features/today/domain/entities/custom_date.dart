import 'package:equatable/equatable.dart';

class CustomDate extends Equatable{
  final int year;
  final int month;
  final int day;
  const CustomDate({
    required this.year,
    required this.month,
    required this.day
  });
  @override
  List<Object?> get props => [
    year,
    month,
    day
  ];

}