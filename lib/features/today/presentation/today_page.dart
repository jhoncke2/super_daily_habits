import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/today_loaded.dart';
import 'package:super_daily_habits/injection_container.dart';

class TodayPage extends StatelessWidget {
  const TodayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dimens = AppDimens();
    return BlocProvider<TodayBloc>(
      create: (_) => sl<TodayBloc>(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            height: dimens.getHeightPercentage(1),
            child: BlocBuilder<TodayBloc, TodayState>(
              builder: (blocContext, blocState) {
                _managePostFrameCallbacks(blocContext, blocState);
                return (
                  (blocState is OnTodayDay)?
                    TodayLoaded(
                      today: blocState.today,
                    ):
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                );
              }
            ),
          )
        )
      )
    );
  }

  void _managePostFrameCallbacks(BuildContext context, TodayState state) {
    if(state is TodayInitial){
      BlocProvider.of<TodayBloc>(context).add(LoadDayByCurrentDate());
    }
  }
}
