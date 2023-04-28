import 'package:equatable/equatable.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

class DayBase extends Equatable{
  final int work;
  final CustomDate date;
  const DayBase({
    required this.work,
    required this.date
  });
  @override
  List<Object?> get props => [
    work,
    date
  ];
}