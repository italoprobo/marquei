import 'package:flutter/material.dart';
import 'package:marquei/views/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkIfAdmin(); 
  }

  Future<void> _checkIfAdmin() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('is_admin')
          .eq('id', userId)
          .single();

      if (response != null && response['is_admin'] == true) {
        setState(() {
          _isAdmin = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            const Text('Bem-vindo à Home Screen!'),
            const SizedBox(height: 20),
            if (_isAdmin)
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add-place');
                },
                child: const Text('Adicionar Estabelecimento'),
              ),
          ],
        ),
      ),
    );
  }
}