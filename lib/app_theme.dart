import 'package:flutter/material.dart';

class AppColors{
  static const other = Colors.blue;
  static const _primaryPrimaryColor = 0x195672;
  static const futurePrimary = MaterialColor(
    _primaryPrimaryColor,
    <int, Color>{
      50: Color.fromRGBO(61, 204, 250, 1),
      100: Color.fromRGBO(54, 181, 221, 1),
      200: Color.fromRGBO(47, 157, 192, 1),
      300: Color.fromRGBO(40, 133, 163, 1),
      400: Color.fromRGBO(33, 110, 134, 1),
      500: Color.fromRGBO(25, 86, 114, 1),
      600: Color.fromRGBO(21, 73, 97, 1),
      700: Color.fromRGBO(17, 60, 80, 1),
      800: Color.fromRGBO(14, 47, 63, 1),
      900: Color.fromRGBO(10, 34, 46, 1)
    }
  );
  static const primary = Color.fromRGBO(25, 86, 114, 1);
  static const primaryLight = Color.fromRGBO(79, 190, 220, 1);
  static const primarySuperLight = Color.fromRGBO(89, 200, 230, 1);
  static const secondary = Color.fromRGBO(240, 240, 240, 1);
  static const secondaryLight = Color.fromRGBO(249, 249, 249, 1);
  static const primaryDisabled = Color.fromRGBO(146, 165, 173, 1);
  static const textPrimary = Colors.black;
  static const textPrimaryDark = Colors.white;
  static const textSecondary = Colors.grey;
  static const shadow = Color.fromRGBO(200, 200, 200, 1);
  static const backgroundPrimary = Colors.white;
  static const backgroundSecondary = Color.fromRGBO(240, 240, 240, 1);
  static const iconPrimary = Color.fromRGBO(143, 171, 221, 1);
  static const error = Colors.redAccent;
  static const errorText = Color.fromARGB(255, 208, 23, 23);
}

class AppDimens{
  static final AppDimens _instance = AppDimens._();
  
  AppDimens._():
    _screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
    _screenHeight = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;

  factory AppDimens() => _instance;

  final double _screenHeight;
  final double _screenWidth;

  double get scaffoldHorizontalPadding => _screenWidth * 0.03; 
  double get scaffoldVerticalPadding => _screenHeight * 0.01;
  double get normalContainerHorizontalMargin => _screenWidth * 0.022;
  double get normalContainerVerticalMargin => _screenHeight * 0.0075;
  double get titleTextSize => 26;
  double get subtitleTextSize => 20;
  double get normalTextSize => 17;
  double get littleTextSize => 15;
  double get littleIconSize => 40;
  double get normalIconSize => 50;
  double get bigIconSize => 65;
  double getHeightPercentage(double perc) => _screenHeight * perc;
  double getWidthPercentage(double perc) => _screenWidth * perc;
}