import 'package:shared_preferences/shared_preferences.dart';
import 'package:super_daily_habits/common/domain/exceptions.dart';

abstract class SharedPreferencesManager{
  Future<int> getInt(String key);
  Future<void> setInt(String key, int value);
  Future<void> remove(String key);
  Future<void> clear();
}

class SharedPreferencesManagerImpl implements SharedPreferencesManager{
  final SharedPreferences preferences;
  const SharedPreferencesManagerImpl({
    required this.preferences
  });

  @override
  Future<int> getInt(String key)async{
    try{
      final result = preferences.getInt(key);
      if(result == null){
        throw const StorageException(
          message: '',
          type: StorageExceptionType.empty
        );
      }
      return result;
    }on Exception{
      throw const StorageException(
        message: '',
        type: StorageExceptionType.normal
      );
    }
  }

  @override
  Future<void> setInt(String key, int value)async{
    await preferences.setInt(key, value);
  }
  
  @override
  Future<void> remove(String key)async{
    await preferences.remove(key);
  }

  @override
  Future<void> clear()async{
    await preferences.clear();
  }
}