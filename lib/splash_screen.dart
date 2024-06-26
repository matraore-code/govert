// lib/pages/splash_screen.dart
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:govert/controller/auth_service.dart';
import 'package:govert/home_page.dart';
import 'package:govert/login_page.dart';
import 'package:page_transition/page_transition.dart';


class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      duration: 1000,
      splash: Image.asset('assets/images/logo.png'), 
      nextScreen: CheckUserLoggedInOrNot(),
      splashTransition: SplashTransition.scaleTransition,
      pageTransitionType: PageTransitionType.rightToLeftWithFade,
      backgroundColor: Colors.green,
    );
  }
}

class CheckUserLoggedInOrNot extends StatefulWidget {
  const CheckUserLoggedInOrNot({super.key});

  @override
  State<CheckUserLoggedInOrNot> createState() => _CheckUserLoggedInOrNotState();
}

class _CheckUserLoggedInOrNotState extends State<CheckUserLoggedInOrNot> {
  @override
  void initState() {
    super.initState();
    _checkUser();
  }

  Future<void> _checkUser() async {
    // Check if user is logged in
    bool isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
     Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else {
     Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => LoginPage()));
        } 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
