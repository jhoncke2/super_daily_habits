import 'package:flutter/material.dart';

class AppColors{
  static const primary = Color.fromRGBO(47, 157, 192, 1);
  static const primaryLight = Color.fromRGBO(79, 190, 220, 1);
  static const primaryDark = Color.fromRGBO(25, 86, 114, 1);
  static const primarySuperLight = Color.fromRGBO(89, 200, 230, 1);
  static const secondary = Color.fromRGBO(240, 240, 240, 1);
  static const secondaryLight = Color.fromRGBO(249, 249, 249, 1);
  static const textPrimary = Colors.black;
  static const textPrimaryDark = Colors.white;
  static const textSecondary = Colors.grey;
  static const shadow = Color.fromRGBO(200, 200, 200, 1);
  static const backgroundPrimary = Colors.white;
  static const backgroundSecondary = Color.fromRGBO(240, 240, 240, 1);
  static const iconPrimary = Color.fromRGBO(143, 171, 221, 1);
}

class AppDimens{
  static final AppDimens _instance = AppDimens._();
  
  AppDimens._():
    _screenWidth = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.width,
    _screenHeight = MediaQueryData.fromWindow(WidgetsBinding.instance.window).size.height;

  factory AppDimens() => _instance;

  final double _screenHeight;
  final double _screenWidth;

  double get scaffoldHorizontalPadding => _screenWidth * 0.02; 
  double get scaffoldVerticalPadding => _screenHeight * 0.01;
  double get normalContainerHorizontalMargin => _screenWidth * 0.022;
  double get normalContainerVerticalMargin => _screenHeight * 0.011;
  double get titleTextSize => 26;
  double get subtitleTextSize => 20;
  double get normalTextSize => 17;
  double get littleTextSize => 15;
  double get littleIconSize => 22;
  double get normalIconSize => 50;
  double get bigIconSize => 65;
  double getHeightPercentage(double perc) => _screenHeight * perc;
  double getWidthPercentage(double perc) => _screenWidth * perc;
}