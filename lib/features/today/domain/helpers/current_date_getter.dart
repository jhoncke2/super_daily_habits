import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

abstract class CurrentDateGetter{
  CustomDate getTodayDate();
}

class CurrentDateGetterImpl implements CurrentDateGetter{
  @override
  CustomDate getTodayDate() => CustomDate.fromDateTime(
    DateTime.now()
  );
}