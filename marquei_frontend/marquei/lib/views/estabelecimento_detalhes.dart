import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart'; // Importação do url_launcher

// Substitua pelo caminho correto para a tela de adicionar quadras esportivas
import 'add_court_screen.dart';

class EstablishmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> estabelecimento;

  const EstablishmentDetailsScreen({super.key, required this.estabelecimento});

  @override
  _EstablishmentDetailsScreenState createState() =>
      _EstablishmentDetailsScreenState();
}

class _EstablishmentDetailsScreenState
    extends State<EstablishmentDetailsScreen> {
  LatLng? _location;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getCoordinatesFromAddress(widget.estabelecimento['endereco'] ?? '');
  }

  // Função para converter o endereço em coordenadas (latitude e longitude)
  Future<void> _getCoordinatesFromAddress(String address) async {
    final apiKey = dotenv.env[
        'SUPABASE_GOOGLE_API_KEY']; // Substitua pela sua chave da API do Google Maps
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?address=${Uri.encodeComponent(address)}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          setState(() {
            _location = LatLng(location['lat'], location['lng']);
            _isLoading = false;
          });
        } else {
          _showError('Endereço não encontrado.');
        }
      } else {
        _showError('Erro ao obter coordenadas: ${response.reasonPhrase}');
      }
    } catch (e) {
      _showError('Erro ao converter o endereço: $e');
    }
  }

  // Função para abrir a localização no Google Maps
  Future<void> _openInGoogleMaps() async {
    if (_location != null) {
      final url =
          'https://www.google.com/maps/search/?api=1&query=${_location!.latitude},${_location!.longitude}';
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        _showError('Não foi possível abrir o Google Maps.');
      }
    } else {
      _showError('Coordenadas não disponíveis.');
    }
  }

  // Função para exibir mensagens de erro
  void _showError(String message) {
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Função para navegar para a tela de adicionar quadras esportivas
  void _navigateToAddCourt() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AddCourtScreen(estabelecimentoId: widget.estabelecimento['id']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.estabelecimento['nome'] ?? 'Detalhes do Estabelecimento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.estabelecimento['nome'] ?? 'Nome não disponível',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 10),
            Text(
              'Endereço:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              widget.estabelecimento['endereco'] ?? 'Endereço não disponível',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            // Define o tamanho do mapa para reduzir sua altura
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _location != null
                    ? Container(
                        height: 200, // Defina a altura desejada para o mapa
                        child: GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: _location!,
                            zoom: 14,
                          ),
                          markers: {
                            Marker(
                              markerId:
                                  const MarkerId('establishment_location'),
                              position: _location!,
                              infoWindow: InfoWindow(
                                title: widget.estabelecimento['nome'],
                                snippet: widget.estabelecimento['endereco'],
                              ),
                            ),
                          },
                        ),
                      )
                    : const Center(
                        child: Text('Não foi possível obter a localização.'),
                      ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _openInGoogleMaps,
              child: const Text('Abrir no Google Maps'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToAddCourt,
              child: const Text('Adicionar Quadra Esportiva'),
            ),
          ],
        ),
      ),
    );
  }
}
