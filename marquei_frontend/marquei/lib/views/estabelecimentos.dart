import 'package:flutter/material.dart';
import 'package:marquei/views/estabelecimento_detalhes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AllEstablishmentsScreen extends StatefulWidget {
  const AllEstablishmentsScreen({super.key});

  @override
  _AllEstablishmentsScreenState createState() =>
      _AllEstablishmentsScreenState();
}

class _AllEstablishmentsScreenState extends State<AllEstablishmentsScreen> {
  List<Map<String, dynamic>> _allEstabelecimentos = [];
  List<Map<String, dynamic>> _filteredEstabelecimentos = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchAllEstabelecimentos();
  }

  // Método para buscar todos os estabelecimentos no Supabase
  Future<void> _fetchAllEstabelecimentos() async {
    final response = await Supabase.instance.client
        .from('estabelecimento')
        .select('*');

    setState(() {
      _allEstabelecimentos = List<Map<String, dynamic>>.from(response);
      _filteredEstabelecimentos = _allEstabelecimentos;
    });
  }

  // Método para filtrar estabelecimentos pelo nome
  void _filterEstabelecimentos(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredEstabelecimentos = _allEstabelecimentos;
      });
    } else {
      setState(() {
        _filteredEstabelecimentos = _allEstabelecimentos
            .where((estabelecimento) => estabelecimento['nome']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os Estabelecimentos'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add-place');
            },
            child: const Text('Add Estabelecimento'),
          ),
          // Barra de pesquisa
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Pesquisar por nome',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterEstabelecimentos,
            ),
          ),
          // Lista de estabelecimentos filtrados
          Expanded(
            child: _filteredEstabelecimentos.isEmpty
                ? const Center(
                    child: Text('Nenhum estabelecimento encontrado.'),
                  )
                : ListView.builder(
                    itemCount: _filteredEstabelecimentos.length,
                    itemBuilder: (context, index) {
                      final estabelecimento = _filteredEstabelecimentos[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          leading: estabelecimento['foto_url'] != null
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    estabelecimento['foto_url'],
                                  ),
                                  radius: 30,
                                )
                              : const Icon(Icons.store),
                          title: Text(estabelecimento['nome']),
                          subtitle: Text(estabelecimento['endereco']),
                          // Redireciona para a página de detalhes ao clicar no card
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
