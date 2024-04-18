import 'package:flutter/material.dart';
import 'package:travel_buddy/pages/login_page.dart';
import 'package:travel_buddy/pages/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => const HomePage(username: 'Demo'),
      },
    );
  }
}
