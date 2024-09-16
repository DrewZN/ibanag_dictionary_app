import 'package:flutter/material.dart';

import 'package:ibanag_dictionary_app/screens/home_screen.dart';

void main() {
  // Start application
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ibanag Dictionary',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.dark
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}