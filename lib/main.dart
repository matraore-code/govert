import 'package:flutter/material.dart';
import 'package:govert/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


Future<void> main() async {
  await Supabase.initialize(
    url: 'https://yxvbvtgtrxsgsmirrfmp.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl4dmJ2dGd0cnhzZ3NtaXJyZm1wIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTc4Mzg4ODAsImV4cCI6MjAzMzQxNDg4MH0.OoMKpVw_yxijEf9Kz4-hZv-DxwTcI9837yOWnsQreho',
  );
            
  runApp(GovertApp()) ;
}

// Get a reference your Supabase client
final supabase = Supabase.instance.client;
class GovertApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOVERT',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: SplashScreen(), 
    );
  }
}

