import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/common/presentation/providers/nav_provider.dart';
import 'package:super_daily_habits/common/presentation/widgets/nav_bar/nav_button.dart';
import 'package:super_daily_habits/injection_container.dart';
import 'package:super_daily_habits/routes.dart';
class NavBar extends StatelessWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: sl<NavProvider>().navIndex,
      builder: (_, navIndex, __) {
        return AppBar(
          backgroundColor: AppColors.backgroundPrimary,
          actions: [
            NavButton(
              name: 'Hoy',
              currentIndex: navIndex,
              buttonIndex: 0,
              route: NavRoutes.specificDay
            ),
            NavButton(
              name: 'Calendario',
              currentIndex: navIndex,
              buttonIndex: 1,
              route: NavRoutes.calendar
            )
          ]
        );
      }
    );
  }
}