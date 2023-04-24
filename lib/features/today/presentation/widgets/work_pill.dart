import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
class WorkPill extends StatelessWidget {
  final int work;
  const WorkPill({
    Key? key,
    required this.work
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Container(
      width: dimens.getWidthPercentage(0.2),
      height: dimens.getHeightPercentage(0.025),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.primary
        ),
        borderRadius: BorderRadius.circular(50)
      ),
      child: Center(
        child: Text(
          '$work',
          style: TextStyle(
            fontSize: dimens.littleTextSize
          ),
        ),
      ),
    );
  }
}