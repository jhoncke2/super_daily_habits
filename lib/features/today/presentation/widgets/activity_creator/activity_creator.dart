// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/activity_creator/activity_input.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/activity_creator/repeatable_activities_selecter.dart';
import '../../utils.dart' as utils;

const durationCollidesMessage = 'Elige una duración que se ajuste';
const notEnoughWorkMessage = 'Elige una cantidad de trabajo que se ajuste';

class ActivityCreator extends StatelessWidget {
  const ActivityCreator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    final blocState = BlocProvider.of<DayBloc>(context).state as OnCreatingActivity;
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: dimens.getHeightPercentage(0.03),
          horizontal: dimens.scaffoldHorizontalPadding
        ),
        child: Column(
          children: [
            Text(
              'Nueva Actividad',
              style: TextStyle(
                fontSize: dimens.normalTextSize
              ),
            ),
            TextField(
              onChanged: (newValue){
                BlocProvider.of<DayBloc>(context).add(UpdateActivityName(newValue));
              },
              controller: blocState.activityControllersContainer.nameController,
              decoration: const InputDecoration(
                hintText: 'Nombre'
              ),
              readOnly: blocState.activity.repeatability == ActivityRepeatability.repeated
            ),
            SizedBox(
              height: dimens.getHeightPercentage(0.02)
            ),
            MaterialButton(
              color: blocState.activity.initialTime != null? AppColors.backgroundPrimary: 
                  AppColors.primary,
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10)
              ),
              onPressed: ()async{
                final time = await showTimePicker(
                  context: context,
                  initialTime: blocState.activity.initialTime == null?
                      const TimeOfDay(hour: 0, minute: 0):
                      utils.getTimeOfDayFromCustomTime(blocState.activity.initialTime!)
                );
                BlocProvider.of<DayBloc>(context).add(UpdateActivityInitialTime(time));
              },
              child: (
                Text(
                  (
                    blocState.activity.initialTime != null?
                      utils.formatTime(blocState.activity.initialTime!):
                      'Hora de inicio'
                  ),
                  style: TextStyle(
                    color: blocState.activity.initialTime != null? 
                        AppColors.textPrimary:
                        AppColors.textPrimaryDark,
                    fontSize: dimens.normalTextSize
                  ),
                )
              ),
            ),
            SizedBox(
              height: dimens.getHeightPercentage(0.02)
            ),
            ActivityInput(
              hintText: 'Duración',
              onChanged: (newValue){
                BlocProvider.of<DayBloc>(context).add(UpdateActivityMinutesDuration(newValue));
              },
              isOnError: (
                blocState is OnError && (blocState as OnError).type == ErrorType.durationCollides
              ),
              errorMessage: durationCollidesMessage,
              controller: blocState.activityControllersContainer.minutesDurationController,
            ),
            SizedBox(
              height: dimens.getHeightPercentage(0.02)
            ),
            ActivityInput(
              hintText: 'Trabajo',
              onChanged: (newValue){
                BlocProvider.of<DayBloc>(context).add(UpdateActivityWork(newValue));
              },
              isOnError: (
                blocState is OnError && (blocState as OnError).type == ErrorType.notEnoughWork
              ),
              errorMessage: notEnoughWorkMessage,
              controller: blocState.activityControllersContainer.workController,
              isAvaible: blocState.activity.repeatability != ActivityRepeatability.repeated,
            ),
            SizedBox(
              height: dimens.getHeightPercentage(0.03)
            ),
            RepeatableActivitiesSelecter(),
            SizedBox(
              height: dimens.getHeightPercentage(0.03)
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                  value: blocState.activity.repeatability == ActivityRepeatability.repeatable,
                  onChanged: blocState.activity.repeatability == ActivityRepeatability.repeated? null : (_){
                    BlocProvider.of<DayBloc>(context).add(const ChangeSaveActivityToRepeat());
                  }
                ),
                Text(
                  'Guardar como repetible',
                  style: TextStyle(
                    fontSize: dimens.normalTextSize,
                    color: blocState.activity.repeatability == ActivityRepeatability.repeated?
                      AppColors.textSecondary:
                      AppColors.textPrimary
                  ),
                )
              ],
            ),
            SizedBox(
              height: dimens.getHeightPercentage(0.03)
            ),
            MaterialButton(
              minWidth: double.infinity,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50)
              ),
              onPressed: (blocState.canEnd)?
                (){
                  BlocProvider.of<DayBloc>(context).add(CreateActivity());
                }: null,
              color: AppColors.primary,
              child: Text(
                'Crear',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: dimens.normalTextSize
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}