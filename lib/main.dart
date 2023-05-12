import 'package:flutter/material.dart';
import 'package:super_daily_habits/app_theme.dart';
import 'package:super_daily_habits/features/today/presentation/day_page.dart';
import './injection_container.dart' as ic;
import './routes.dart' as routes;

Future<void> main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await ic.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        //primarySwatch: AppColors.primary,
        primaryColor: AppColors.primary
      ),
      routes: routes.routes,
      home: const DayPage()
    );
  }
}