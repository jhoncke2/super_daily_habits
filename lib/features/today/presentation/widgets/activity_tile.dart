import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/work_pill.dart';
import '../utils.dart' as utils;
class ActivityTile extends StatelessWidget {
  final HabitActivity activity;
  const ActivityTile({
    Key? key,
    required this.activity
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Container(
      height: dimens.getHeightPercentage(0.085),
      padding: EdgeInsets.symmetric(
        horizontal: dimens.getWidthPercentage(0.05),
        vertical: dimens.getHeightPercentage(0.01)
      ),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary,
            width: 1.5
          )
        )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: dimens.getWidthPercentage(0.3),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  utils.formatTime(
                    activity.initialTime
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: dimens.subtitleTextSize,
                    color: AppColors.textPrimary.withOpacity(0.75)
                  )
                ),
                SizedBox(
                  width: dimens.getWidthPercentage(0.175),
                  child: const Divider(
                    color: AppColors.textPrimary,
                    thickness: 0.75,
                    height: 2,
                  ),
                ),
                Text(
                  utils.formatTime(
                    utils.getFinalHour(
                      activity.initialTime,
                      activity.minutesDuration
                    )
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: dimens.subtitleTextSize,
                    color: AppColors.textPrimary.withOpacity(0.75)
                  )
                )
              ]
            )
          ),
          SizedBox(
            width: dimens.getWidthPercentage(0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  activity.name,
                  style: TextStyle(
                    fontSize: dimens.normalTextSize,
                    fontWeight: FontWeight.bold
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Trabajo',
                      style: TextStyle(
                        fontSize: dimens.littleTextSize
                      ),
                    ),
                    WorkPill(
                      work: activity.work,
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}