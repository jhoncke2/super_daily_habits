// ignore_for_file: prefer_const_constructors_in_immutables

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
import 'package:super_daily_habits/features/today/domain/entities/activity/habit_activity_creation.dart';
class RepeatableActivitiesSelecter extends StatelessWidget {
  RepeatableActivitiesSelecter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final blocState = BlocProvider.of<DayBloc>(context).state as OnCreatingActivity;
    return DropdownButton<int>(
      hint: Text(
        (blocState.activity.repeatability == ActivityRepeatability.repeated)?
          'Actividad del storage seleccionada':
          'Seleccionar actividad del storage'
      ),
      onChanged: (index){
        BlocProvider.of<DayBloc>(context).add(ChooseRepeatableActivity(index));
      },
      items: (){
        final items = <DropdownMenuItem<int>>[];
        final activities = blocState.repeatableActivities;
        for(int i = 0; i < activities.length; i++){
          items.add(DropdownMenuItem<int>(
            value: i,
            child: Text(
              activities[i].name
            )
          ));
        }
        return items;
      }()..add(
        DropdownMenuItem(
          value: blocState.repeatableActivities.length,
          child: const Text(
            'Ninguno'
          )
        )
      ),
    );
  }
}