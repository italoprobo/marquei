import 'package:supabase_flutter/supabase_flutter.dart';

class SignupService {
  final SupabaseClient _supabaseClient;

  SignupService(this._supabaseClient);

  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required bool isAdmin,
  }) async {
    try {
      // Realiza o cadastro no Supabase (auth)
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
      );

      // Verifica se o cadastro foi bem-sucedido
      if (response.user == null) {
        return 'Erro ao criar conta.';
      }

      // Pega o id do usuário autenticado
      final userIdAuth = response.user?.id;

      // Insere o usuário na tabela 'usuarios' com o id de autenticação
      if (userIdAuth != null) {
        await _supabaseClient.from('usuarios').insert({
          'id_auth': userIdAuth, // ID da autenticação
          'nome': name,
          'telefone': phone,
          'is_admin': isAdmin,
        });
      }

      return null; // Cadastro bem-sucedido
    } catch (e) {
      return 'Erro ao tentar registrar o usuário: $e';
    }
  }
}
