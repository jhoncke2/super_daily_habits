import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

class DayBase extends Equatable{
  final int totalWork;
  final CustomDate date;
  //redundancia necesaria para eficiencia del método getMonth en módulo <calendar>
  final int restantWork;
  const DayBase({
    required this.totalWork,
    required this.date,
    required this.restantWork
  });
  @override
  List<Object?> get props => [
    totalWork,
    date,
    restantWork
  ];
}