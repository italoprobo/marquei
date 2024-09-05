import 'package:flutter/material.dart';
import 'package:marquei/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Bem-vindo à Home Screen!'),
            SizedBox(height: 20), // Espaço entre o texto e o botão
            ElevatedButton(
              onPressed: () {
                // Navega para a tela de adicionar lugares
                Navigator.pushNamed(context, '/add-place');
              },
              child: Text('Adicionar Estabelecimento'),
            ),
          ],
        ),
      ),
    );
  }
}
