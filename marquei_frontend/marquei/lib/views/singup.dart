import 'package:flutter/material.dart';
import 'package:marquei/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _isAdmin = false;

  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text;
    final phone = _phoneController.text;

    try {
      final response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao criar conta.')),
        );
        return;
      }

      final userId = response.user?.id;
      if (userId != null) {
        await Supabase.instance.client.from('usuarios').insert({
          'id': userId,
          'nome': name,
          'telefone': phone,
          'is_admin': _isAdmin, 
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      print('Erro ao tentar registrar o usuário: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocorreu um erro no cadastro.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Número de Telefone'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('Administrador'),
                Switch(
                  value: _isAdmin,
                  onChanged: (bool value) {
                    setState(() {
                      _isAdmin = value; 
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Criar minha conta'),
            ),
          ],
        ),
      ),
    );
  }
}

