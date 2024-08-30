import 'package:flutter/material.dart';
import 'package:marquei/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); 
  final _phoneController = TextEditingController(); 

  Future<void> _register() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final name = _nameController.text; 
    final phone = _phoneController.text; 

    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: ${response.error!.message}')),
      );
    } else {

      final userId = response.user?.id;
      if (userId != null) {
        await Supabase.instance.client
            .from('profiles')
            .insert({
          'id': userId,
          'name': name,
          'phone': phone,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cadastro')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Número de Telefone'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: Text('Criar minha conta'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on AuthResponse {
  get error => null;
}
