import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/activity_tile.dart';
class TodayView extends StatelessWidget {
  late ScrollController activitiesController;
  final Day today;
  TodayView({
    Key? key,
    required this.today
  }) : super(key: key){
    activitiesController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: Scrollbar(
              controller: activitiesController,
              thumbVisibility: true,
              child: ListView(
                controller: activitiesController,
                children: today.activities.map<Widget>(
                  (activity) => ActivityTile(
                    activity: activity
                  )
                ).toList(),
              ),
            ),
          ),
          
        ],
      ),
    );
  }
}