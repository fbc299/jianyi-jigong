import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/work/work_list.dart';
import '../screens/work/work_form.dart';
import '../screens/salary/salary_list.dart';
import '../screens/salary/salary_form.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/settings/settings_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String workList = '/work';
  static const String workForm = '/work/form';
  static const String salaryList = '/salary';
  static const String salaryForm = '/salary/form';
  static const String stats = '/stats';
  static const String settings = '/settings';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const MainScreen(),
        workList: (context) => const WorkListScreen(),
        workForm: (context) => const WorkFormScreen(),
        salaryList: (context) => const SalaryListScreen(),
        salaryForm: (context) => const SalaryFormScreen(),
        stats: (context) => const StatsScreen(),
        settings: (context) => const SettingsScreen(),
      };
}
