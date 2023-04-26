import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/common/presentation/widgets/error_panel.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/activity_creator.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/today_view.dart';
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
    final blocState = BlocProvider.of<TodayBloc>(context).state as OnTodayDay;
    return SizedBox(
      width: dimens.getWidthPercentage(1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: dimens.getHeightPercentage(0.03)
          ),
          Container(
            width: dimens.getWidthPercentage(1),
            padding: EdgeInsets.only(
              left: dimens.scaffoldHorizontalPadding,
              top: dimens.getHeightPercentage(0.01),
              bottom: dimens.getHeightPercentage(0.01)
            ),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  offset: Offset(1, 2.5),
                  blurRadius: 1,
                  spreadRadius: 2
                )
              ]
            ),
            child: SizedBox(
              width: dimens.getWidthPercentage(0.3),
              child: Text(
                utils.formatDate(today.date),
                textAlign: TextAlign.start,
                style: TextStyle(
                  fontSize: dimens.normalTextSize,
                  color: AppColors.textPrimary
                )
              )
            )
          ),
          Visibility(
            visible: blocState is OnShowingTodayDay,
            child: TodayView(today: today)
          ),
          Visibility(
            visible: blocState is OnCreatingActivity,
            child: ActivityCreator()
          ),
          (
            blocState is OnError?
                ErrorPanel(
                  errorTitle: (blocState as OnError).message
                ):
                Container()
          ),
          WorkBar()
        ]
      ),
    );
  }
}