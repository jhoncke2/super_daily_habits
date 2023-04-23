import 'package:super_daily_habits/features/today/domain/entities/custom_date.dart';

abstract class CurrentDateGetter{
  CustomDate getCurrentDate();
}

class CurrentDateGetterImpl implements CurrentDateGetter{
  @override
  CustomDate getCurrentDate() => CustomDate.fromDateTime(
    DateTime.now()
  );
}