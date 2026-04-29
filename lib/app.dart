import 'package:flutter/material.dart';
import 'config/theme.dart';
import 'config/routes.dart';

class JianYiApp extends StatelessWidget {
  const JianYiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '简约记工',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialRoute: AppRoutes.home,
      routes: AppRoutes.routes,
      debugShowCheckedModeBanner: false,
    );
  }
}
