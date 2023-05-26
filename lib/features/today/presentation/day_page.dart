import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/common/presentation/widgets/nav_bar/nav_bar.dart';
import 'package:super_daily_habits/features/today/domain/bloc/day_bloc.dart';
import 'package:super_daily_habits/features/today/presentation/widgets/day_loaded.dart';
import 'package:super_daily_habits/injection_container.dart';
class DayPage extends StatelessWidget {
  const DayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = ModalRoute.of(context)!.settings.arguments as DateTime?;
    final dimens = AppDimens();
    return BlocProvider<DayBloc>(
      create: (_) => sl<DayBloc>(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              const NavBar(),
              SizedBox(
                height: dimens.getHeightPercentage(0.9),
                child: BlocBuilder<DayBloc, DayState>(
                  builder: (blocContext, blocState) {
                    _managePostFrameCallbacks(blocContext, blocState, date);
                    return (
                      (blocState is OnDay)?
                        DayLoaded(
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

  void _managePostFrameCallbacks(BuildContext context, DayState state, DateTime? date) {
    if(state is TodayInitial){
      BlocProvider.of<DayBloc>(context).add(LoadDay(
        date: date
      ));
    }
  }
}
