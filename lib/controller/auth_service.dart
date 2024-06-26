import 'package:supabase_flutter/supabase_flutter.dart';



class AuthService {
  static final SupabaseClient supabase = Supabase.instance.client;

  static Future<bool> isLoggedIn() async {
    User? user = supabase.auth.currentUser;
    return user != null;
  }
}