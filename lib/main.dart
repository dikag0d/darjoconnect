import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/user/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Darjo Connect',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const LoginScreen(), // Halaman Login
        '/main': (context) => const MainScreen(), // Halaman Utama
      },
    );
  }
}
