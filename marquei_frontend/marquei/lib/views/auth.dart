import 'package:flutter/material.dart';
import 'package:marquei/views/home.dart';
import 'package:marquei/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          // Usuário autenticado
          return HomeScreen(); 
        } else {
          // Usuário não autenticado
          return LoginScreen(); 
        }
      },
    );
  }

  Future<User?> _getCurrentUser() async {
    final user = Supabase.instance.client.auth.currentUser;
    return user;
  }
}
