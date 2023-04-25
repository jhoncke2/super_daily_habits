import 'package:flutter/material.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

String formatDate(CustomDate date) =>
  '${date.year}-${date.month}-${date.day}';

String formatTime(CustomTime time) =>
   '${time.hour<10?"0":""}${time.hour>12?(time.hour%12):time.hour}:${time.minute<10?"0":""}${time.minute} ${time.hour>11?"PM":"AM"}' ;

TimeOfDay getTimeOfDayFromCustomTime(CustomTime time) =>
  TimeOfDay(
    hour: time.hour,
    minute: time.minute
  );

CustomTime getFinalHour(CustomTime initial, int minutesDuration) =>
  CustomTime(
    hour: initial.hour + (minutesDuration ~/ 60),
    minute: initial.minute + (minutesDuration % 60)
  );