import 'package:flutter/material.dart';

class EstablishmentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> estabelecimento;

  const EstablishmentDetailsScreen({super.key, required this.estabelecimento});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(estabelecimento['nome'] ?? 'Detalhes do Estabelecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              estabelecimento['nome'] ?? 'Nome não disponível',
              style: Theme.of(context).textTheme.headline5,
            ),
            const SizedBox(height: 10),
            Text(
              'Endereço:',
              style: Theme.of(context).textTheme.subtitle1,
            ),
            Text(
              estabelecimento['endereco'] ?? 'Endereço não disponível',
              style: const TextStyle(fontSize: 16),
            ),
            // Adicione mais informações sobre o estabelecimento aqui, se necessário
          ],
        ),
      ),
    );
  }
}

extension on TextTheme {
  get headline5 => null;
  
  get subtitle1 => null;
}
