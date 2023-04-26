import 'package:flutter_test/flutter_test.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';

late TimeRangeCalificatorImpl calificator;

void main(){
  late CustomTime initial;
  late int minutesDuration;
  late CustomTime calificated;
  setUp((){
    calificator = TimeRangeCalificatorImpl();
  });

  group('Cuando el time inicial y final tienen la misma hora', (){
    setUp((){
      initial = const CustomTime(
        hour: 5,
        minute: 20
      );
      // 5:40
      minutesDuration = 20;
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
      // 7:30
      minutesDuration = 130;
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
      // 7:10
      minutesDuration = 110;
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
      expect(result, false);
    });
  });
}