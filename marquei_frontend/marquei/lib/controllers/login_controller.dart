// controllers/login_controller.dart
import 'package:flutter/material.dart';
import '../services/login_service.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final LoginService _loginService = LoginService();

  Future<String?> login() async {
    final email = emailController.text;
    final password = passwordController.text;

    try {
      final response = await _loginService.login(email, password);
      if (response.user == null) {
        return 'Erro ao fazer login: usuário não encontrado.';
      }
      return null; // Sucesso
    } catch (e) {
      return 'Erro ao tentar logar: $e';
    }
  }
}
