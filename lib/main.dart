import 'package:flutter/material.dart';
import 'login_page.dart';
import 'home_page.dart';

void main() {
  runApp(GovertApp());
}

class GovertApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}
