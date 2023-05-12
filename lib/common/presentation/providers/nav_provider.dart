import 'package:flutter/foundation.dart';

abstract class NavProvider{
  ValueListenable<int> get navIndex;
  set index(int index);
}

class NavProviderImpl implements NavProvider{
  final ValueNotifier<int> _navIndex = ValueNotifier(0);

  @override
  set index(int index){
    _navIndex.value = index;
  }

  @override
  ValueListenable<int> get navIndex =>
      _navIndex;
}