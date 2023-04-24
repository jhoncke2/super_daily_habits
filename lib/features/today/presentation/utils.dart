import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

String formatDate(CustomDate date) =>
  '${date.year}-${date.month}-${date.day}';

String formatTime(CustomTime time) =>
   '${time.hour<10?"0":""}${time.hour>12?(time.hour%12):time.hour}:${time.minute<10?"0":""}${time.minute} ${time.hour>11?"PM":"AM"}' ;