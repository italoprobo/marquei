import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:marquei/views/estabelecimento_detalhes.dart';
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
  List<Map<String, dynamic>> _reservas = [];
  Map<int, String> _quadras = {}; // Mapeia ID da quadra para nome da quadra

  @override
  void initState() {
    super.initState();
    _checkIfAdmin();
    _fetchUserName();
    _fetchEstabelecimentos();
    _fetchReservas();
    _fetchQuadras(); // Buscar os nomes das quadras
  }

  Future<void> _checkIfAdmin() async {
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      final response = await Supabase.instance.client
          .from('usuarios')
          .select('is_admin')
          .eq('id', userId)
          .single();

      if (response['is_admin'] == true) {
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
          .eq('id_auth', user.id)
          .single();

      setState(() {
        _userName = response['nome'] ?? 'Usuário';
      });
    }
  }

  Future<void> _fetchEstabelecimentos() async {
    final response =
        await Supabase.instance.client.from('estabelecimento').select('*');

    setState(() {
      _estabelecimentos = List<Map<String, dynamic>>.from(response);
    });
  }

  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  final DateFormat timeFormat = DateFormat('HH:mm');

  Future<void> _fetchReservas() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final response = await Supabase.instance.client
          .from('reserva')
          .select('id_quadra, data, hora_inicio, hora_fim')
          .eq('id_user_auth', user.id);

      if (response != null && response is List) {
        final reservas = List<Map<String, dynamic>>.from(response);

        final quadrasIds = reservas.map((r) => r['id_quadra'] as int).toSet();

        final quadrasResponse = await Supabase.instance.client
            .from('quadra')
            .select('id, nome, id_estabelecimento')
            .or('id.in.(${quadrasIds.join(',')})');

        final quadras = Map<int, Map<String, dynamic>>.fromEntries(
            (quadrasResponse as List).map((q) => MapEntry(q['id'] as int, q)));

        final estabelecimentosIds =
            quadras.values.map((q) => q['id_estabelecimento'] as int).toSet();

        final estabelecimentosResponse = await Supabase.instance.client
            .from('estabelecimento')
            .select('id, nome')
            .or('id.in.(${estabelecimentosIds.join(',')})');

        final estabelecimentos = Map<int, String>.fromEntries(
            (estabelecimentosResponse as List)
                .map((e) => MapEntry(e['id'] as int, e['nome'] as String)));

        setState(() {
          _reservas = reservas.map((reserva) {
            final quadra = quadras[reserva['id_quadra'] as int];
            final estabelecimento =
                estabelecimentos[quadra?['id_estabelecimento'] as int];
            return {
              'data': dateFormat.format(DateTime.parse(reserva['data'])),
              'hora_inicio': timeFormat.format(DateTime.parse(
                  reserva['data'] + 'T' + reserva['hora_inicio'])),
              'hora_fim': timeFormat.format(
                  DateTime.parse(reserva['data'] + 'T' + reserva['hora_fim'])),
              'quadra_nome': quadra?['nome'],
              'estabelecimento_nome': estabelecimento,
            };
          }).toList();
        });
      } else {
        print('Erro ao buscar reservas ou nenhuma reserva encontrada.');
      }
    }
  }

  Future<void> _fetchQuadras() async {
    final response = await Supabase.instance.client
        .from('quadra')
        .select('id, nome'); // Busca o ID e nome das quadras

    if (response != null && response is List) {
      final quadras = Map<int, String>.fromIterable(
        response,
        key: (item) => item['id'],
        value: (item) => item['nome'],
      );
      setState(() {
        _quadras = quadras;
      });
    } else {
      print('Erro ao buscar quadras ou nenhuma quadra encontrada.');
    }
  }

  void _navigateToAllEstabelecimentos() {
    Navigator.pushNamed(context, '/all-establishments');
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                    16.0), // Opcional: adiciona algum padding ao redor
                child: Text(
                  'Estabelecimentos:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        19, // Ajuste o tamanho da fonte conforme necessário
                    fontWeight:
                        FontWeight.bold, // Opcional: ajusta o peso da fonte
                  ),
                ),
              ),
            ],
          ),
          if (_estabelecimentos.isNotEmpty)
            CarouselSlider(
              options: CarouselOptions(
                height: 235.0,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: _estabelecimentos.map((estabelecimento) {
                return Builder(
                  builder: (BuildContext context) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EstablishmentDetailsScreen(
                              estabelecimento: estabelecimento,
                            ),
                          ),
                        );
                      },
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (estabelecimento['foto_url'] != null)
                                Image.network(
                                  estabelecimento['foto_url'],
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              const SizedBox(height: 8),
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
                  },
                );
              }).toList(),
            ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _navigateToAllEstabelecimentos,
            child: const Text('Ver Todos'),
          ),
          const SizedBox(height: 20),
          // Exibindo as reservas
          const Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.all(
                    16.0), // Opcional: adiciona algum padding ao redor
                child: Text(
                  'Minhas Reservas:',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize:
                        19, // Ajuste o tamanho da fonte conforme necessário
                    fontWeight:
                        FontWeight.bold, // Opcional: ajusta o peso da fonte
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _reservas.length,
              itemBuilder: (context, index) {
                final reserva = _reservas[index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                        'Estabelecimento: ${reserva['estabelecimento_nome'] ?? 'Desconhecido'}'),
                    subtitle: Text(
                      'Quadra: ${reserva['quadra_nome'] ?? 'Desconhecida'}\n'
                      'Data: ${reserva['data']}\n'
                      'Hora Inicial: ${reserva['hora_inicio']}\n'
                      'Hora Final: ${reserva['hora_fim']}\n',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
