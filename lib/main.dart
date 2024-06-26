import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart';
import 'home_page.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'postgresql://postgres.yxvbvtgtrxsgsmirrfmp:[YOUR-PASSWORD]@aws-0-eu-west-1.pooler.supabase.com:6543/postgres',
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
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}

