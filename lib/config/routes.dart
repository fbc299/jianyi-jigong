import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/work/work_list.dart';
import '../screens/work/work_form.dart';
import '../screens/salary/salary_list.dart';
import '../screens/salary/salary_form.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/project/project_list.dart';
import '../screens/project/project_form.dart';
import '../screens/worker/worker_list.dart';
import '../screens/worker/worker_form.dart';

class AppRoutes {
  static const String home = '/';
  static const String workList = '/work';
  static const String workForm = '/work/form';
  static const String salaryList = '/salary';
  static const String salaryForm = '/salary/form';
  static const String stats = '/stats';
  static const String settings = '/settings';
  static const String projectList = '/project/list';
  static const String projectForm = '/project/form';
  static const String workerList = '/worker/list';
  static const String workerForm = '/worker/form';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const MainScreen(),
        workList: (context) => const WorkListScreen(),
        workForm: (context) => const WorkFormScreen(),
        salaryList: (context) => const SalaryListScreen(),
        salaryForm: (context) => const SalaryFormScreen(),
        stats: (context) => const StatsScreen(),
        settings: (context) => const SettingsScreen(),
        projectList: (context) => const ProjectListScreen(),
        projectForm: (context) => const ProjectFormScreen(),
        workerList: (context) => const WorkerListScreen(),
        workerForm: (context) => const WorkerFormScreen(),
      };
}
