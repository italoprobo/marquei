// services/login_service.dart
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginService {
  final supabase = Supabase.instance.client;

  Future<AuthResponse> login(String email, String password) async {
    return await supabase.auth.signInWithPassword(email: email, password: password);
  }
}
