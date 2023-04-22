// Mocks generated by Mockito 5.4.0 from annotations
// in super_daily_habits/test/features/today/data/data_sources/today_local_data_source_impl_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:mockito/mockito.dart' as _i1;
import 'package:super_daily_habits/common/data/database.dart' as _i3;
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart'
    as _i5;
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart'
    as _i7;
import 'package:super_daily_habits/features/today/domain/entities/day.dart'
    as _i2;
import 'package:super_daily_habits/features/today/domain/entities/day_creation.dart'
    as _i6;
import 'package:super_daily_habits/features/today/domain/entities/habit_activity.dart'
    as _i9;
import 'package:super_daily_habits/features/today/domain/entities/habit_activity_creation.dart'
    as _i8;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeDay_0 extends _i1.SmartFake implements _i2.Day {
  _FakeDay_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [DatabaseManager].
///
/// See the documentation for Mockito's code generation for more information.
class MockDatabaseManager extends _i1.Mock implements _i3.DatabaseManager {
  MockDatabaseManager() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<List<Map<String, dynamic>>> queryAll(String? tableName) =>
      (super.noSuchMethod(
        Invocation.method(
          #queryAll,
          [tableName],
        ),
        returnValue: _i4.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i4.Future<List<Map<String, dynamic>>>);
  @override
  _i4.Future<Map<String, dynamic>> querySingleOne(
    String? tableName,
    int? id,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #querySingleOne,
          [
            tableName,
            id,
          ],
        ),
        returnValue:
            _i4.Future<Map<String, dynamic>>.value(<String, dynamic>{}),
      ) as _i4.Future<Map<String, dynamic>>);
  @override
  _i4.Future<List<Map<String, dynamic>>> queryWhere(
    String? tableName,
    String? whereStatement,
    List<dynamic>? whereVariables,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #queryWhere,
          [
            tableName,
            whereStatement,
            whereVariables,
          ],
        ),
        returnValue: _i4.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i4.Future<List<Map<String, dynamic>>>);
  @override
  _i4.Future<int> insert(
    String? tableName,
    Map<String, dynamic>? data,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #insert,
          [
            tableName,
            data,
          ],
        ),
        returnValue: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);
  @override
  _i4.Future<void> update(
    String? tableName,
    Map<String, dynamic>? updatedData,
    int? id,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #update,
          [
            tableName,
            updatedData,
            id,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> remove(
    String? tableName,
    int? id,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #remove,
          [
            tableName,
            id,
          ],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<void> removeAll(String? tableName) => (super.noSuchMethod(
        Invocation.method(
          #removeAll,
          [tableName],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);
  @override
  _i4.Future<List<Map<String, dynamic>>> queryInnerJoin(
    String? tableName1,
    String? tableName2,
    String? whereStatement,
    List<dynamic>? whereVariables,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #queryInnerJoin,
          [
            tableName1,
            tableName2,
            whereStatement,
            whereVariables,
          ],
        ),
        returnValue: _i4.Future<List<Map<String, dynamic>>>.value(
            <Map<String, dynamic>>[]),
      ) as _i4.Future<List<Map<String, dynamic>>>);
}

/// A class which mocks [TodayLocalAdapter].
///
/// See the documentation for Mockito's code generation for more information.
class MockTodayLocalAdapter extends _i1.Mock implements _i5.TodayLocalAdapter {
  MockTodayLocalAdapter() {
    _i1.throwOnMissingStub(this);
  }

  @override
  Map<String, dynamic> getMapFromDay(_i6.DayCreation? day) =>
      (super.noSuchMethod(
        Invocation.method(
          #getMapFromDay,
          [day],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
  @override
  _i2.Day getEmptyDayFromMap(Map<String, dynamic>? map) => (super.noSuchMethod(
        Invocation.method(
          #getEmptyDayFromMap,
          [map],
        ),
        returnValue: _FakeDay_0(
          this,
          Invocation.method(
            #getEmptyDayFromMap,
            [map],
          ),
        ),
      ) as _i2.Day);
  @override
  String getStringMapFromDate(_i7.CustomDate? date) => (super.noSuchMethod(
        Invocation.method(
          #getStringMapFromDate,
          [date],
        ),
        returnValue: '',
      ) as String);
  @override
  Map<String, dynamic> getMapFromActivity(
          _i8.HabitActivityCreation? activity) =>
      (super.noSuchMethod(
        Invocation.method(
          #getMapFromActivity,
          [activity],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
  @override
  Map<String, dynamic> getMapFromDayIdAndActivityId(
    int? dayId,
    int? activityId,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #getMapFromDayIdAndActivityId,
          [
            dayId,
            activityId,
          ],
        ),
        returnValue: <String, dynamic>{},
      ) as Map<String, dynamic>);
  @override
  List<_i9.HabitActivity> getActivitiesFromJson(
          List<Map<String, dynamic>>? jsonList) =>
      (super.noSuchMethod(
        Invocation.method(
          #getActivitiesFromJson,
          [jsonList],
        ),
        returnValue: <_i9.HabitActivity>[],
      ) as List<_i9.HabitActivity>);
}
