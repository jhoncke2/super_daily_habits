import 'dart:convert';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/common/data/database.dart' as database;
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';

abstract class DayLocalAdapter{
  Map<String, dynamic> getMapFromDay(DayBase day);
  Day getEmptyDayFromMap(Map<String, dynamic> map);
  Day getFilledDayWithActivitiesFromMap(Map<String, dynamic> jsonDay, List<Map<String, dynamic>> jsonActivities);
  String getStringMapFromDate(CustomDate date);
  Map<String, dynamic> getMapFromActivity(HabitActivityCreation activity);
  Map<String, dynamic> getMapFromDayIdAndActivityId(int dayId, HabitActivity activity);
  List<HabitActivity> getActivitiesFromJson(List<Map<String, dynamic>> jsonList);
  HabitActivity getActivityFromJson(Map<String, dynamic> jsonActivity);
}

class DayLocalAdapterImpl extends DayLocalAdapter{

  static const yearKey = 'year';
  static const monthKey = 'month';
  static const dayKey = 'day';
  static const weekDayKey = 'week_day';
  static const hourKey = 'hour';
  static const minuteKey = 'minute';

  @override
  Day getEmptyDayFromMap(Map<String, dynamic> map) => Day(
    id: map[database.idKey],
    date: _getDateFromMap(
      jsonDecode(map[
        database.daysDateKey
      ])
    ),
    activities: [],
    totalWork: map[database.daysWorkKey],
    restantWork: map[database.daysRestantWorkKey]
  );

  CustomDate _getDateFromMap(Map<String, dynamic> jsonDate) => CustomDate(
    year: jsonDate[yearKey],
    month: jsonDate[monthKey],
    day: jsonDate[dayKey],
    weekDay: jsonDate[weekDayKey]
  );

  @override
  Map<String, dynamic> getMapFromDay(DayBase day) => {
    database.daysDateKey: getStringMapFromDate(day.date),
    database.daysWorkKey: day.totalWork,
    database.daysRestantWorkKey: day.restantWork
  };

  @override
  String getStringMapFromDate(CustomDate date) =>
      jsonEncode(_getMapFromDate(date));
  
  Map<String, dynamic> _getMapFromDate(CustomDate date) => {
    yearKey: date.year,
    monthKey: date.month,
    dayKey: date.day,
    weekDayKey: date.weekDay
  };
  
  @override
  Map<String, dynamic> getMapFromActivity(HabitActivityCreation activity) => {
    database.activitiesNameKey: activity.name,
    database.activitiesInitHourKey: _getStringMapFromTime(activity.initialTime!),
    database.activitiesDurationKey: activity.minutesDuration,
    database.activitiesWorkKey: activity.work,
    database.activitiesIsRepeatableKey: activity.repeatability == ActivityRepeatability.repeatable?
      1:
      0
  };

  String _getStringMapFromTime(CustomTime time) => jsonEncode({
    hourKey: time.hour,
    minuteKey: time.minute
  });
  
  @override
  Map<String, dynamic> getMapFromDayIdAndActivityId(int dayId, HabitActivity activity) => {
    database.daysActivitiesDayIdKey: dayId,
    database.daysActivitiesActivityIdKey: activity.id,
    database.daysActivitiesInitHourKey: _getStringMapFromTime(
      activity.initialTime
    ),
    database.daysActivitiesDurationKey: activity.minutesDuration
  };
  
  @override
  List<HabitActivity> getActivitiesFromJson(List<Map<String, dynamic>> jsonList) => jsonList.map<HabitActivity>(
    (item) => HabitActivity(
      id: item[database.idKey],
      name: item[database.activitiesNameKey],
      initialTime: _getTimeFromJsonString(
        item[database.activitiesInitHourKey]
      ),
      minutesDuration: item[database.activitiesDurationKey],
      work: item[database.activitiesWorkKey]
    )
  ).toList();

  CustomTime _getTimeFromJsonString(String jsonString){
    final json = jsonDecode(jsonString);
    return CustomTime(
      hour: json[hourKey],
      minute: json[minuteKey]
    );
  }
  
  @override
  Day getFilledDayWithActivitiesFromMap(Map<String, dynamic> jsonDay, List<Map<String, dynamic>> jsonActivities) => Day(
    id: jsonDay[database.idKey],
    date: _getDateFromMap(jsonDecode(
      jsonDay[database.daysDateKey]
    )),
    activities: jsonActivities.map<HabitActivity>(
      (item) => HabitActivity(
        id: item[database.idKey],
        name: item[database.activitiesNameKey],
        initialTime: _getTimeFromJsonString(
          item[database.activitiesInitHourKey]
        ),
        minutesDuration: item[database.activitiesDurationKey],
        work: item[database.activitiesWorkKey]
      )
    ).toList(),
    totalWork: jsonDay[database.daysWorkKey],
    restantWork: jsonDay[database.daysRestantWorkKey]
  );
  
  @override
  HabitActivity getActivityFromJson(Map<String, dynamic> jsonActivity) => HabitActivity(
    id: jsonActivity[database.idKey],
    name: jsonActivity[database.activitiesNameKey],
    minutesDuration: jsonActivity[database.activitiesDurationKey],
    work: jsonActivity[database.activitiesWorkKey],
    initialTime: _getTimeFromJsonString(
      database.activitiesInitHourKey
    )
  );
}