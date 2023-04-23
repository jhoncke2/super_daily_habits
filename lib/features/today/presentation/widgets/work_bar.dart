import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
class WorkBar extends StatelessWidget {
  const WorkBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Container(
      width: dimens.getWidthPercentage(1),
      height: dimens.getHeightPercentage(0.05),
      padding: EdgeInsets.symmetric(
        horizontal: dimens.getWidthPercentage(0.1)
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(
          100
        ),
        boxShadow: const [
          BoxShadow(
            offset: Offset(0, -1),
            blurRadius: 5,
            spreadRadius: 1,
            color: AppColors.shadow
          )
        ]
      ),
      child: Row(
        children: [
          Container(
            width: dimens.getWidthPercentage(0.25),
            height: dimens.getHeightPercentage(0.025),
            decoration: BoxDecoration(
              color: AppColors.primaryDark,
              borderRadius: BorderRadius.circular(25)
            ),
          )
        ],
      ),
    );
  }
}