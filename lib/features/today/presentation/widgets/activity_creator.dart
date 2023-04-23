import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
class ActivityCreator extends StatelessWidget {
  const ActivityCreator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    final blocState = BlocProvider.of<TodayBloc>(context).state as OnCreatingActivity;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: dimens.getHeightPercentage(0.03),
          horizontal: dimens.scaffoldHorizontalPadding
        ),
        child: Column(
          children: [
            Text(
              'Nueva Actividad'
            ),
            TextField(
              onChanged: (newValue){
                BlocProvider.of<TodayBloc>(context).add(UpdateActivityName(newValue));
              },
              decoration: const InputDecoration(
                hintText: 'Nombre'
              ),
            )
          ],
        ),
      ),
    );
  }
}