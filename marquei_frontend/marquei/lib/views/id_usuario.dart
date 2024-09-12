import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserIdCheckScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar ID do Usuário'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            final supabase = Supabase.instance.client;
            final user = supabase.auth.currentUser;

            if (user == null) {
              print("Usuário não autenticado.");
            } else {
              print("ID do Usuário: ${user.id}");
            }
          },
          child: Text('Obter ID do Usuário'),
        ),
      ),
    );
  }
}
