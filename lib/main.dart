import 'package:flutter/material.dart';
import 'package:pru/Login.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dietali',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: LoginScreen(), // 🔥 Inicia en Login
      debugShowCheckedModeBanner: false,
    );
  }
}
