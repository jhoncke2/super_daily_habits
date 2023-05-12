import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/common/presentation/widgets/nav_bar/nav_bar.dart';
import 'package:super_daily_habits/features/today/domain/bloc/today_bloc.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/today_loaded.dart';
import 'package:super_daily_habits/injection_container.dart';

class DayPage extends StatelessWidget {
  const DayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)!.settings.arguments as DateTime?;
    final dimens = AppDimens();
    return BlocProvider<TodayBloc>(
      create: (_) => sl<TodayBloc>(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const NavBar(),
              SizedBox(
                height: dimens.getHeightPercentage(0.9),
                child: BlocBuilder<TodayBloc, TodayState>(
                  builder: (blocContext, blocState) {
                    _managePostFrameCallbacks(blocContext, blocState, date);
                    return (
                      (blocState is OnTodayDay)?
                        TodayLoaded(
                          today: blocState.day,
                        ):
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                    );
                  }
                ),
              ),
            ],
          )
        )
      )
    );
  }

  void _managePostFrameCallbacks(BuildContext context, TodayState state, DateTime? date) {
    if(state is TodayInitial){
      BlocProvider.of<TodayBloc>(context).add(LoadDay(
        date: date
      ));
    }
  }
}
