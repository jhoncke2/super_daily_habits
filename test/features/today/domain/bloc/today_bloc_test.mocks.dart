// Mocks generated by Mockito 5.4.0 from annotations
// in super_daily_habits/test/features/today/domain/bloc/today_bloc_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;

import 'package:mockito/mockito.dart' as _i1;
import 'package:super_daily_habits/common/domain/common_repository.dart' as _i9;
import 'package:super_daily_habits/features/today/domain/day_repository.dart'
    as _i4;
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart'
    as _i8;
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart'
    as _i6;
import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart'
    as _i3;
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart'
    as _i13;
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart'
    as _i2;
import 'package:super_daily_habits/features/today/domain/entities/day/day_base.dart'
    as _i7;
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart'
    as _i11;
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart'
    as _i10;
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart'
    as _i12;

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

class _FakeCustomDate_1 extends _i1.SmartFake implements _i3.CustomDate {
  _FakeCustomDate_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [DayRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockDayRepository extends _i1.Mock implements _i4.DayRepository {
  MockDayRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<_i2.Day> getDayByDate(_i3.CustomDate? date) => (super.noSuchMethod(
        Invocation.method(
          #getDayByDate,
          [date],
        ),
        returnValue: _i5.Future<_i2.Day>.value(_FakeDay_0(
          this,
          Invocation.method(
            #getDayByDate,
            [date],
          ),
        )),
      ) as _i5.Future<_i2.Day>);
  @override
  _i5.Future<_i2.Day> setActivityToDay(
    _i6.HabitActivityCreation? activity,
    _i2.Day? day,
    int? newRestantWork,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #setActivityToDay,
          [
            activity,
            day,
            newRestantWork,
          ],
        ),
        returnValue: _i5.Future<_i2.Day>.value(_FakeDay_0(
          this,
          Invocation.method(
            #setActivityToDay,
            [
              activity,
              day,
              newRestantWork,
            ],
          ),
        )),
      ) as _i5.Future<_i2.Day>);
  @override
  _i5.Future<_i2.Day> createDay(_i7.DayBase? day) => (super.noSuchMethod(
        Invocation.method(
          #createDay,
          [day],
        ),
        returnValue: _i5.Future<_i2.Day>.value(_FakeDay_0(
          this,
          Invocation.method(
            #createDay,
            [day],
          ),
        )),
      ) as _i5.Future<_i2.Day>);
  @override
  _i5.Future<_i2.Day> updateActivityRestantWork(
    int? restantWork,
    _i2.Day? day,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateActivityRestantWork,
          [
            restantWork,
            day,
          ],
        ),
        returnValue: _i5.Future<_i2.Day>.value(_FakeDay_0(
          this,
          Invocation.method(
            #updateActivityRestantWork,
            [
              restantWork,
              day,
            ],
          ),
        )),
      ) as _i5.Future<_i2.Day>);
  @override
  _i5.Future<_i2.Day> deleteHabitFromDay(
    _i8.HabitActivity? habit,
    _i2.Day? day,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #deleteHabitFromDay,
          [
            habit,
            day,
          ],
        ),
        returnValue: _i5.Future<_i2.Day>.value(_FakeDay_0(
          this,
          Invocation.method(
            #deleteHabitFromDay,
            [
              habit,
              day,
            ],
          ),
        )),
      ) as _i5.Future<_i2.Day>);
  @override
  _i5.Future<List<_i8.HabitActivity>> getAllRepeatableActivities() =>
      (super.noSuchMethod(
        Invocation.method(
          #getAllRepeatableActivities,
          [],
        ),
        returnValue:
            _i5.Future<List<_i8.HabitActivity>>.value(<_i8.HabitActivity>[]),
      ) as _i5.Future<List<_i8.HabitActivity>>);
}

/// A class which mocks [CommonRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockCommonRepository extends _i1.Mock implements _i9.CommonRepository {
  MockCommonRepository() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i5.Future<void> setCommonWork(int? work) => (super.noSuchMethod(
        Invocation.method(
          #setCommonWork,
          [work],
        ),
        returnValue: _i5.Future<void>.value(),
        returnValueForMissingStub: _i5.Future<void>.value(),
      ) as _i5.Future<void>);
  @override
  _i5.Future<int> getCommonWork() => (super.noSuchMethod(
        Invocation.method(
          #getCommonWork,
          [],
        ),
        returnValue: _i5.Future<int>.value(0),
      ) as _i5.Future<int>);
}

/// A class which mocks [CurrentDateGetter].
///
/// See the documentation for Mockito's code generation for more information.
class MockCurrentDateGetter extends _i1.Mock implements _i10.CurrentDateGetter {
  MockCurrentDateGetter() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i3.CustomDate getCurrentDate() => (super.noSuchMethod(
        Invocation.method(
          #getCurrentDate,
          [],
        ),
        returnValue: _FakeCustomDate_1(
          this,
          Invocation.method(
            #getCurrentDate,
            [],
          ),
        ),
      ) as _i3.CustomDate);
}

/// A class which mocks [ActivityCompletitionValidator].
///
/// See the documentation for Mockito's code generation for more information.
class MockActivityCompletitionValidator extends _i1.Mock
    implements _i11.ActivityCompletitionValidator {
  MockActivityCompletitionValidator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool isCompleted(_i6.HabitActivityCreation? activity) => (super.noSuchMethod(
        Invocation.method(
          #isCompleted,
          [activity],
        ),
        returnValue: false,
      ) as bool);
}

/// A class which mocks [TimeRangeCalificator].
///
/// See the documentation for Mockito's code generation for more information.
class MockTimeRangeCalificator extends _i1.Mock
    implements _i12.TimeRangeCalificator {
  MockTimeRangeCalificator() {
    _i1.throwOnMissingStub(this);
  }

  @override
  bool timeIsBetweenTimeRange(
    _i13.CustomTime? time,
    _i13.CustomTime? rangeInit,
    int? minutesDuration,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #timeIsBetweenTimeRange,
          [
            time,
            rangeInit,
            minutesDuration,
          ],
        ),
        returnValue: false,
      ) as bool);
  @override
  bool timeRangesCollide(
    _i13.CustomTime? initialTime1,
    int? duration1,
    _i13.CustomTime? initialTime2,
    int? duration2,
  ) =>
      (super.noSuchMethod(
        Invocation.method(
          #timeRangesCollide,
          [
            initialTime1,
            duration1,
            initialTime2,
            duration2,
          ],
        ),
        returnValue: false,
      ) as bool);
}
