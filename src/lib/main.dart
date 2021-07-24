import 'package:flutter/material.dart';

import 'package:src/screens/home.dart';
import 'package:src/screens/search.dart';
import 'package:src/screens/settings.dart';

void main() {
  runApp(const RainfallApp());
}

class RainfallApp extends StatelessWidget {
  const RainfallApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'rainfall',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/search': (context) => const SearchScreen()
      },
    );
  }
}
