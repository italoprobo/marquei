// views/login_view.dart
import 'package:flutter/material.dart';
import '../controllers/login_controller.dart';
import 'home.dart';
import 'singup.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _controller = LoginController();
  final _formKey = GlobalKey<FormState>();

  // Função para exibir mensagens
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 50),
              Center(
              child: Image.asset(
                'assets/images/marquei.png',
                height: 120, // Tamanho da imagem
              ),  
            ),
            const SizedBox(height: 20),
            RichText(
                text: TextSpan(
                  text: "Marquei",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Aplica o negrito
                    color: Colors.orange,
                    fontSize: 26,
                  )
                )
              ),
              const SizedBox(height: 20),
              RichText(
                text: TextSpan(
                  text: "Insira seu email e senha",
                  style: TextStyle(
                    fontWeight: FontWeight.bold, // Aplica o negrito
                    color: Colors.black,
                    fontSize: 18,
                  )
                )
              ),
              TextFormField(
                controller: _controller.emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira seu email';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _controller.passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira sua senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final result = await _controller.login();
                    if (result == null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      );
                    } else {
                      _showSnackBar(result);
                    }
                  }
                },
                child: const Text('Entrar'),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Não tem uma conta? Registre-se'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}