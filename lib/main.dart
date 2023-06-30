import 'package:flutter/material.dart';
import 'package:text_recognition_app/home_screen.dart';


late Size mq;

void main() async {

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff01293f),
        ),
      ),
      home:  HomeScreen(),
    );
  }
}