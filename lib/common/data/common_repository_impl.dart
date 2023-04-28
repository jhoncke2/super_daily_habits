import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_daily_habits/common/data/shared_preferences_manager.dart';
import 'package:super_daily_habits/common/domain/common_repository.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';

class CommonRepositoryImpl implements CommonRepository{
  static const commonWorkKey = 'common_work';
  static const defaultCommonWork = 100;

  final SharedPreferencesManager sharedPreferences;
  CommonRepositoryImpl({
    required this.sharedPreferences
  });
  @override
  Future<int> getCommonWork() async{
    try{
      return await sharedPreferences.getInt(commonWorkKey);
    } on StorageException catch(exception){
      if(exception.type == StorageExceptionType.empty){
        await setCommonWork(defaultCommonWork);
        return defaultCommonWork;
      }else{
        rethrow;
      }
    }
  }
    
  @override
  Future<void> setCommonWork(int work)async{
    await sharedPreferences.setInt(
      commonWorkKey,
      work
    );
  }
}