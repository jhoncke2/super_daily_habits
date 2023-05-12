import 'package:flutter/material.dart';
import 'package:super_daily_habits/common/presentation/providers/nav_provider.dart';
import 'package:super_daily_habits/common/presentation/widgets/nav_bar/nav_bar.dart';
import 'package:super_daily_habits/features/today/presentation/day_page.dart';
import 'package:super_daily_habits/injection_container.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalendarPage extends StatelessWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const NavBar(),
            Expanded(
              child: SfCalendar(
                view: CalendarView.month,
                onTap: (details){
                  if(details.date != null){
                    sl<NavProvider>().index = 0;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DayPage(),
                        settings: RouteSettings(
                          arguments: details.date
                        )
                      )
                    );
                  }
                },
              ),
            ),
          ],
        )
      )
    );
  }
}