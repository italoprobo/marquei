import 'package:flutter/material.dart';
import 'package:marquei/services/signup_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignupController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  bool isAdmin = false;

  final SignupService _registerService;

  SignupController(SupabaseClient supabaseClient)
      : _registerService = SignupService(supabaseClient);

  Future<String?> registerUser() async {
    final email = emailController.text;
    final password = passwordController.text;
    final name = nameController.text;
    final phone = phoneController.text;

    // Chama o serviço para registrar o usuário
    return await _registerService.registerUser(
      email: email,
      password: password,
      name: name,
      phone: phone,
      isAdmin: isAdmin,
    );
  }
}
