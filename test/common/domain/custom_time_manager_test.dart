import 'package:flutter_test/flutter_test.dart';
import 'package:super_daily_habits/common/domain/custom_time_manager.dart';
import 'package:super_daily_habits/features/today/domain/entities/custom_time.dart';

late CustomTimeManagerImpl customTimeManager;
void main(){
  late CustomTime initTime;
  late int minutes;

  setUp((){
    customTimeManager = CustomTimeManagerImpl();
  });

  test('''Debe retornar el resultado esperado
  cuando la hora <no> llega a 24 y los minutos <no> llegan a 60''', (){
    initTime = const CustomTime(hour: 10, minute: 10);
    minutes = 70;
    final result = customTimeManager.getTimeWithMinutesAdded(initTime, minutes);
    expect(
      result,
      const CustomTime(
        hour: 11,
        minute: 20
      )
    );
  });

  test('''Debe retornar el resultado esperado
  cuando la hora <no> llega a 24 y los minutos <sí> llegan a 60''', (){
    initTime = const CustomTime(hour: 10, minute: 10);
    minutes = 111;
    final result = customTimeManager.getTimeWithMinutesAdded(initTime, minutes);
    expect(
      result,
      const CustomTime(
        hour: 12,
        minute: 01
      )
    );
  });

  test('''Debe retornar el resultado esperado
  cuando la hora <sí> llega a 24 y los minutos <no> llegan a 60''', (){
    initTime = const CustomTime(hour: 22, minute: 10);
    minutes = 130;
    final result = customTimeManager.getTimeWithMinutesAdded(initTime, minutes);
    expect(
      result,
      const CustomTime(
        hour: 00,
        minute: 20
      )
    );
  });

  test('''Debe retornar el resultado esperado
  cuando la hora <sí> llega a 24
  y es debido a que los minutos <sí> llegan a 60''', (){
    initTime = const CustomTime(hour: 22, minute: 30);
    minutes = 100;
    final result = customTimeManager.getTimeWithMinutesAdded(initTime, minutes);
    expect(
      result,
      const CustomTime(
        hour: 00,
        minute: 10
      )
    );
  });
}