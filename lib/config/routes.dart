import 'package:flutter/material.dart';
import '../screens/main_screen.dart';
import '../screens/work/work_list.dart';
import '../screens/work/work_form.dart';
import '../screens/work/work_batch.dart';
import '../screens/salary/salary_list.dart';
import '../screens/salary/salary_form.dart';
import '../screens/salary/salary_detail.dart';
import '../screens/stats/stats_screen.dart';
import '../screens/stats/yearly_stats.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/project/project_list.dart';
import '../screens/project/project_form.dart';
import '../screens/worker/worker_list.dart';
import '../screens/worker/worker_form.dart';
import '../screens/backup/backup_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String workList = '/work';
  static const String workForm = '/work/form';
  static const String workBatch = '/work/batch';
  static const String salaryList = '/salary';
  static const String salaryForm = '/salary/form';
  static const String salaryDetail = '/salary/detail';
  static const String stats = '/stats';
  static const String yearlyStats = '/stats/yearly';
  static const String settings = '/settings';
  static const String projectList = '/project';
  static const String projectForm = '/project/form';
  static const String workerList = '/worker';
  static const String workerForm = '/worker/form';
  static const String backup = '/backup';

  static Map<String, WidgetBuilder> get routes => {
        home: (context) => const MainScreen(),
        workList: (context) => const WorkListScreen(),
        workForm: (context) => const WorkFormScreen(),
        workBatch: (context) => const WorkBatchScreen(),
        salaryList: (context) => const SalaryListScreen(),
        salaryForm: (context) => const SalaryFormScreen(),
        salaryDetail: (context) => const SalaryDetailScreen(),
        stats: (context) => const StatsScreen(),
        yearlyStats: (context) => const YearlyStatsScreen(),
        settings: (context) => const SettingsScreen(),
        projectList: (context) => const ProjectListScreen(),
        projectForm: (context) => const ProjectFormScreen(),
        workerList: (context) => const WorkerListScreen(),
        workerForm: (context) => const WorkerFormScreen(),
        backup: (context) => const BackupScreen(),
      };
}
