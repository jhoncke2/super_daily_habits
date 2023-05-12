import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/common/presentation/providers/nav_provider.dart';
import 'package:super_daily_habits/injection_container.dart';

class NavButton extends StatelessWidget {
  final String name;
  final int currentIndex;
  final int buttonIndex;
  final String route;
  
  const NavButton({
    Key? key,
    required this.name,
    required this.currentIndex,
    required this.buttonIndex,
    required this.route
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return MaterialButton(
      elevation: 0,
      minWidth: dimens.getWidthPercentage(0.5),
      color: currentIndex == buttonIndex?
        AppColors.primary:
          AppColors.backgroundPrimary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(buttonIndex == 0? 22 : 0),
          bottomRight: Radius.circular(buttonIndex == 0? 22 : 0),
          topLeft: Radius.circular(buttonIndex == 1? 22 : 0),
          bottomLeft: Radius.circular(buttonIndex == 1? 22 : 0),
        )
      ),
      onPressed: (){
        sl<NavProvider>().index = buttonIndex;
        Navigator.of(context).pushNamed(route);
      },
      child: Text(
        name,
        style: TextStyle(
          fontSize: dimens.normalTextSize,
          color: currentIndex == buttonIndex?
            AppColors.textPrimaryDark:
            AppColors.textPrimary
        )
      )
    );
  }
}