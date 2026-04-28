import 'package:flutter/material.dart';

import '../screens/route_viewer_screen.dart';
import '../theme/app_theme.dart';

class KkApp extends StatelessWidget {
  const KkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Komoot Killer',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(Brightness.light),
      darkTheme: buildAppTheme(Brightness.dark),
      themeMode: ThemeMode.dark,
      home: const RouteViewerScreen(),
    );
  }
}
