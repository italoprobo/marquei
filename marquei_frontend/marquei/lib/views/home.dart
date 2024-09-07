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
  String _userName = '';
  List<Map<String, dynamic>> _estabelecimentos = [];

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _fetchUserName();
    _fetchEstabelecimentos();
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

  Future<void> _fetchUserName() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('nome')
          .eq('id', user.id)
          .single();

      if (response != null) {
        setState(() {
          _userName = response['nome'] ?? 'Usuário';
        });
      }
    }
  }

  Future<void> _fetchEstabelecimentos() async {
    // Buscando os estabelecimentos no Supabase (limitado a 3)
    final response = await Supabase.instance.client
        .from('estabelecimento')
        .select('nome, endereco')
        .limit(3); // Limitando para exibir até 3 estabelecimento

    if (response != null) {
      setState(() {
        _estabelecimentos = List<Map<String, dynamic>>.from(response);
      });
    }
  }

  void _navigateToAllEstabelecimentos() {
    Navigator.pushNamed(context,
        '/all-establishments'); // Rota para a tela com todos os estabelecimentos
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text('Olá, $_userName'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-place');
            },
            child: const Text('Add Estabelecimento'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          if (_estabelecimentos.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: _estabelecimentos.map((estabelecimento) {
                  return Expanded(
                    child: Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              estabelecimento['nome'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              estabelecimento['endereco'],
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToAllEstabelecimentos,
            child: const Text('Ver Todos'),
          ),
        ],
      ),
    );
  }
}
