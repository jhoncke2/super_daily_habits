import 'package:super_daily_habits/features/today/domain/entities/day_creation.dart';

class Day extends DayCreation{
  final int id;
  const Day({
    required this.id,
    required super.date,
    required super.activities,
    required super.work
  });
  @override
  List<Object?> get props => [
    ...super.props,
    id
  ];
}