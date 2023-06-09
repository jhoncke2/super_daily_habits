// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:super_daily_habits/features/today/domain/entities/day/day.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/activity_tile.dart';
class DayView extends StatelessWidget {
  late ScrollController activitiesController;
  final Day today;
  DayView({
    Key? key,
    required this.today
  }) : super(key: key){
    activitiesController = ScrollController();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Scrollbar(
        controller: activitiesController,
        thumbVisibility: true,
        child: ListView(
          padding: const EdgeInsets.all(0),
          controller: activitiesController,
          children: today.activities.map<Widget>(
            (activity) => ActivityTile(
              activity: activity
            )
          ).toList(),
        ),
      ),
    );
  }
}