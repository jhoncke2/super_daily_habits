import 'package:equatable/equatable.dart';

class InitialTimeAdditionRestriction extends Equatable{
  final bool timeIsBetweenAnyActivityRange;
  final bool newRangeCollides;
  const InitialTimeAdditionRestriction({
    required this.timeIsBetweenAnyActivityRange,
    required this.newRangeCollides
  });
  @override
  List<Object?> get props => [
    timeIsBetweenAnyActivityRange,
    newRangeCollides
  ];
}