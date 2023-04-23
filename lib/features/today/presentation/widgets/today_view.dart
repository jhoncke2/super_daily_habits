import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/day.dart';
class TodayView extends StatelessWidget {
  final Day today;
  const TodayView({
    Key? key,
    required this.today
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return Expanded(
      child: Column(
        children: [
          Column(
            children: today.activities.map<Widget>(
              (activity) => Text(
                activity.name
              )
            ).toList(),
          ),
          Expanded(
            child: Container()
          ),
          InkWell(
            onTap: (){
              BlocProvider.of<TodayBloc>(context).add(InitActivityCreation());
            },
            child: Icon(
              Icons.add_rounded,
              size: dimens.bigIconSize,
              color: AppColors.primary,
            )
          )
        ],
      ),
    );
  }
}