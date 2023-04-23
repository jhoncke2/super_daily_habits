import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

String formatDate(CustomDate date) =>
  '${date.year}-${date.month}-${date.day}';