import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/work_bar.dart';
import '../utils.dart' as utils;
class TodayLoaded extends StatelessWidget {
  final Day today;
  const TodayLoaded({
    Key? key,
    required this.today
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return SizedBox(
      width: dimens.getWidthPercentage(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            utils.formatDate(today.date)
          ),
          Expanded(
            child: Container(),
          ),
          InkWell(
            onTap: (){

            },
            child: Icon(
              Icons.add,
              size: dimens.bigIconSize,
              color: AppColors.primaryDark,
            )
          ),
          WorkBar()
        ]
      ),
    );
  }
}