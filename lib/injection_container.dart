import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:super_daily_habits/common/data/common_repository_impl.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/common/data/shared_preferences_manager.dart';
import 'package:super_daily_habits/common/domain/common_repository.dart';
import 'package:super_daily_habits/common/domain/custom_time_manager.dart';
import 'package:super_daily_habits/common/presentation/providers/nav_provider.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_data_source.dart';
import 'package:super_daily_habits/features/today/data/data_sources/day_local_data_source_impl.dart';
import 'package:super_daily_habits/features/today/data/day_repository_impl.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/helpers/day_calificator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/time_range_calificator.dart';
import 'package:super_daily_habits/features/today/domain/day_repository.dart';

final sl = GetIt.instance;
bool useRealData = true;

Future<void> init() async {
   /**********************************************
   *             Common
   ********************************************** */
  final db = await CustomDataBaseFactory.dataBase;
  sl.registerLazySingleton<DatabaseManager>(
    () => DataBaseManagerImpl(
      db: db
    )
  );
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferencesManager>(
    () => SharedPreferencesManagerImpl(preferences: sharedPreferences)
  );
  sl.registerLazySingleton<CommonRepository>(
    () => CommonRepositoryImpl(
      sharedPreferences: sl<SharedPreferencesManager>()
    )
  );
  sl.registerLazySingleton<NavProvider>(
    () => NavProviderImpl()
  );

  /**********************************************
   *             Today
   ********************************************** */
  //await _clearDataBase(db);
  sl.registerLazySingleton<DayLocalAdapter>(
    () => DayLocalAdapterImpl()
  );
  sl.registerLazySingleton<DayLocalDataSource>(
    () => DayLocalDataSourceImpl(
      dbManager: sl<DatabaseManager>(),
      adapter: sl<DayLocalAdapter>()
    )
  );
  sl.registerLazySingleton<DayRepository>(
    () => DayRepositoryImpl(
      localDataSource: sl<DayLocalDataSource>()
    )
  );
  final currentDateGetter = CurrentDateGetterImpl();
  final activityCompletitionValidator = ActivityCompletitionValidatorImpl();
  final timeRangeCalificator = TimeRangeCalificatorImpl(
    customTimeManager: CustomTimeManagerImpl()
  );
  final dayCalificator = DayCalificatorImpl();
  sl.registerFactory<DayBloc>(
    () => DayBloc(
      repository: sl<DayRepository>(),
      commonRepository: sl<CommonRepository>(),
      currentDateGetter: currentDateGetter,
      activityCompletitionValidator: activityCompletitionValidator,
      timeRangeCalificator: timeRangeCalificator,
      dayCalificator: dayCalificator
    )
  );
}

Future<void> _clearDataBase(Database db)async{
  await db.delete(daysActivitiesTableName);
  await db.delete(activitiesTableName);
  await db.delete(daysTableName);
}