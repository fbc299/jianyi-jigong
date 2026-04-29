import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/work_provider.dart';
import 'providers/salary_provider.dart';
import 'database/database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper().database;
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WorkProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
      ],
      child: const JianYiApp(),
    ),
  );
}
