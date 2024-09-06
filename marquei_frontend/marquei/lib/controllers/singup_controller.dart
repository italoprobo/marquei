// controllers/register_controller.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isAdmin = false;

  // Função para realizar o cadastro no Supabase
  Future<String?> registerUser() async {
    final email = emailController.text;
    final password = passwordController.text;
    final name = nameController.text;
    final phone = phoneController.text;

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return 'Erro ao criar conta.';
      }

      final userId = response.user?.id;
      if (userId != null) {
        await Supabase.instance.client.from('usuarios').insert({
          'id': userId,
          'nome': name,
          'telefone': phone,
          'is_admin': isAdmin,
        });
      }

      return null; // Sucesso
    } catch (e) {
      return 'Erro ao tentar registrar o usuário: $e';
    }
  }
}
