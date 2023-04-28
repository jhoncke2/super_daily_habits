import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:super_daily_habits/common/domain/custom_time_manager.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'time_range_calificator_test.mocks.dart';

late TimeRangeCalificatorImpl calificator;
late MockCustomTimeManager customTimeManager;

@GenerateMocks([
  CustomTimeManager
])
void main(){
  setUp((){
    customTimeManager = MockCustomTimeManager();
    calificator = TimeRangeCalificatorImpl(
      customTimeManager: customTimeManager
    );
  });
  group('time is between time range', _testTimeIsBetweenTimeRange);
  group('time range is between time range', _testTimeRangeIsBetweenTimeRange);
}

void _testTimeIsBetweenTimeRange(){
  late CustomTime initial;
  late int minutesDuration;
  late CustomTime end;
  late CustomTime calificated;
  
  
  group('Cuando el time inicial y final tienen la misma hora', (){
    setUp((){
      initial = const CustomTime(
        hour: 5,
        minute: 20
      );
      minutesDuration = 20;
      end = const CustomTime(
        hour: 5,
        minute: 40
      );
      when(customTimeManager.getTimeWithMinutesAdded(initial, minutesDuration))
          .thenReturn(end);
    });

    test('Debe lanzar <false> cuando el minuto del calificated es <menor> al minuto <inicial>', (){
      calificated = const CustomTime(
        hour: 5,
        minute: 19
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, false);
    });

    test('Debe lanzar <true> cuando el minuto del calificated está dentro del rango de minutos', (){
      calificated = const CustomTime(
        hour: 5,
        minute: 35
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });

    test('Debe lanzar <false> cuando el minuto del calificated es <mayor> al minuto <final>', (){
      calificated = const CustomTime(
        hour: 5,
        minute: 35
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });
    test('Debe lanzar <false> cuando el minuto del calificated es <igual> al minuto <inicial>', (){
      calificated = const CustomTime(
        hour: 5,
        minute: 20
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });

    test('Debe lanzar <false> cuando el minuto del calificated es <igual> al minuto <final>', (){
      calificated = const CustomTime(
        hour: 5,
        minute: 40
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });

    test('''Debe lanzar <false> cuando la hora del calificated es <menor> a la hora en común
    y el minute del calificated está entre los minutes inicial y final''', (){
      calificated = const CustomTime(
        hour: 4,
        minute: 35
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, false);
    });

    test('''Debe lanzar <false> cuando la hora del calificated es <mayor> a la hora en común
    y el minute del calificated está entre los minutes inicial y final''', (){
      calificated = const CustomTime(
        hour: 6,
        minute: 35
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, false);
    });
  });

  group('Cuando el time inicial y final tienen distinta hora (el minuto final es mayor al minuto inicial)', (){
    setUp((){
      initial = const CustomTime(
        hour: 5,
        minute: 20
      );
      minutesDuration = 130;
      end = const CustomTime(
        hour: 7,
        minute: 30
      );
      when(customTimeManager.getTimeWithMinutesAdded(initial, minutesDuration))
          .thenReturn(end);
    });

    test('Debe retornar <true> cuando la hora del calificated está entre la hora inicial y la final', ()async{
      calificated = const CustomTime(
        hour: 6,
        minute: 35
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });

    test('''Debe retornar <true> cuando la hora del calificated es la final,
    el minuto mayor al minuto de inicio y menor al minuto final''', ()async{
      calificated = const CustomTime(
        hour: 7,
        minute: 21
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });
  });

  group('Cuando el time inicial y final tienen distina hora (el minuto final es menor al minuto inicial)', (){
    setUp((){
      initial = const CustomTime(
        hour: 5,
        minute: 20
      );
      minutesDuration = 110;
      end = const CustomTime(
        hour: 7,
        minute: 10
      );
      when(customTimeManager.getTimeWithMinutesAdded(initial, minutesDuration))
          .thenReturn(end);
    });
    test('Debe retornar <false> cuando la hora del calificated es la inicial y el minuto es menor al inicial pero mayor al final', ()async{
      calificated = const CustomTime(
        hour: 5,
        minute: 19
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, false);
    });

    test('Debe retornar <false> cuando la hora del calificated es la final y el minuto es menor al inicial pero mayor al final', ()async{
      calificated = const CustomTime(
        hour: 7,
        minute: 11
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, false);
    });

    test('Debe retornar <true> cuando la hora del calificated es la final y el minuto es mayor al inicial pero menor al final', ()async{
      calificated = const CustomTime(
        hour: 7,
        minute: 9
      );
      final result = calificator.timeIsBetweenTimeRange(
        calificated,
        initial,
        minutesDuration
      );
      expect(result, true);
    });
  });
}

void _testTimeRangeIsBetweenTimeRange(){
  late CustomTime initTime1;
  late int duration1;
  late CustomTime endTime1;
  late CustomTime initTime2;
  late int duration2;
  setUp((){
    initTime1 = const CustomTime(
      hour: 12,
      minute: 00
    );
    duration1 = 60;
    endTime1 = const CustomTime(
      hour: 13,
      minute: 0
    );
    when(customTimeManager.getTimeWithMinutesAdded(initTime1, duration1))
        .thenReturn(endTime1);
  });

  test('''Debe retornar el resultado esperado
  cuando el rango 1 está por debajo del rango 2''', (){
    initTime2 = const CustomTime(
      hour: 13,
      minute: 1
    );
    duration2 = 20;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 13,
          minute: 21
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, false);
  });

  test('''Debe retornar el resultado esperado
  cuando el rango 1 comienza y termina en el rango 2''', (){
    initTime2 = const CustomTime(
      hour: 11,
      minute: 59
    );
    duration2 = 62;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 13,
          minute: 01
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, true);
  });
  
  
  test('''Debe retornar el resultado esperado
    cuando el rango 1 comienza en el rango 2 pero termina por fuera''', (){
    initTime2 = const CustomTime(
      hour: 12,
      minute: 50
    );
    duration2 = 12;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 13,
          minute: 02
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, true);
  });

  test('''Debe retornar el resultado esperado
    cuando el rango 1 comienza antes del rango 2 pero termina dentro''', (){
    initTime2 = const CustomTime(
      hour: 11,
      minute: 50
    );
    duration2 = 12;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 12,
          minute: 02
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, true);
  });

  test('''Debe retornar el resultado esperado
    cuando el rango 1 está después del rango dos''', (){
    initTime2 = const CustomTime(
      hour: 13,
      minute: 01
    );
    duration2 = 12;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 13,
          minute: 13
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, false);
  });

  test('''Debe retornar el resultado esperado
    cuando el rango 1 comienza antes del rango dos y termina después''', (){
    initTime2 = const CustomTime(
      hour: 12,
      minute: 01
    );
    duration2 = 58;
    when(customTimeManager.getTimeWithMinutesAdded(initTime2, duration2))
        .thenReturn(const CustomTime(
          hour: 12,
          minute: 59
        ));
    final result = calificator.timeRangesCollide(
      initTime1,
      duration1,
      initTime2,
      duration2
    );
    expect(result, true);
  });
}