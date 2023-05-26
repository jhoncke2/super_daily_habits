import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
class WorkBar extends StatelessWidget {
  const WorkBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocState = BlocProvider.of<DayBloc>(context).state as OnDay;
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            '${blocState.restantWork}/${blocState.day.totalWork}'
          ),
          SizedBox(
            width: dimens.getWidthPercentage(0.05),
          ),
          SizedBox(
            width: dimens.getWidthPercentage(0.25),
            child: Stack(
              children: [
                Container(
                  width: dimens.getWidthPercentage(
                    0.25
                  ),
                  height: dimens.getHeightPercentage(0.025),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(50)
                  )
                ),
                Container(
                  width: dimens.getWidthPercentage(( 1 - (blocState.restantWork / blocState.day.totalWork)) * 0.25),
                  height: dimens.getHeightPercentage(0.025),
                  margin: EdgeInsets.only(
                    left: dimens.getWidthPercentage(0.25 - ( 1 - (blocState.restantWork / blocState.day.totalWork)) * 0.25)
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.white
                  )
                ),
                Container(
                  width: dimens.getWidthPercentage(0.25),
                  height: dimens.getHeightPercentage(0.025),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(50),
                    border: Border.all(
                      color: AppColors.primary,
                      width: 1.5
                    )
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container()
          ),
          InkWell(
            onTap: blocState.restantWork > 0? (){
              BlocProvider.of<DayBloc>(context).add(InitActivityCreation());
            } : null,
            child: Icon(
              Icons.add_rounded,
              size: dimens.littleIconSize,
              color: blocState.restantWork > 0?
                AppColors.primary:
                AppColors.primaryDisabled,
            )
          )
        ],
      ),
    );
  }
}