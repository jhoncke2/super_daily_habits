import 'package:get_it/get_it.dart';
import 'package:super_daily_habits/common/data/database.dart';
import 'package:super_daily_habits/features/today/data/data_sources/fake/data_base_injecter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_adapter.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source.dart';
import 'package:super_daily_habits/features/today/data/data_sources/today_local_data_source_impl.dart';
import 'package:super_daily_habits/features/today/data/today_repository_impl.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/domain/helpers/activity_completition_validator.dart';
import 'package:super_daily_habits/features/today/domain/helpers/current_date_getter.dart';
import 'package:super_daily_habits/features/today/domain/today_repository.dart';

final sl = GetIt.instance;
bool useRealData = false;

Future<void> init() async {
  final db = await CustomDataBaseFactory.dataBase;
  sl.registerLazySingleton<DatabaseManager>(
    () => DataBaseManagerImpl(
      db: db
    )
  );
  sl.registerLazySingleton<TodayLocalAdapter>(
    () => TodayLocalAdapterImpl()
  );
  if(!useRealData){
    final databaseInjecter = DataBaseInjecter(
      databaseManager: sl<DatabaseManager>(),
      adapter: sl<TodayLocalAdapter>()
    );
    await databaseInjecter.injectFakeData();
  }
  sl.registerLazySingleton<TodayLocalDataSource>(
    () => TodayLocalDataSourceImpl(
      dbManager: sl<DatabaseManager>(),
      adapter: sl<TodayLocalAdapter>()
    )
  );
  sl.registerLazySingleton<TodayRepository>(
    () => TodayRepositoryImpl(
      localDataSource: sl<TodayLocalDataSource>()
    )
  );
  final currentDateGetter = CurrentDateGetterImpl();
  final activityCompletitionValidator = ActivityCompletitionValidatorImpl();
  sl.registerFactory<TodayBloc>(
    () => TodayBloc(
      repository: sl<TodayRepository>(),
      currentDateGetter: currentDateGetter,
      activityCompletitionValidator: activityCompletitionValidator
    )
  );
}

