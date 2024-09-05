import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AddPlaces extends StatefulWidget {
  const AddPlaces({super.key});

  @override
  State<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends State<AddPlaces> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  double? _lat;
  double? _long;
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng latLng) async {
    setState(() {
      _lat = latLng.latitude;
      _long = latLng.longitude;
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
        infoWindow: InfoWindow(title: 'Marcador Selecionado'),
      ));
    });
    await _getAddressFromLatLng(_lat!, _long!);
    print("Latitude: $_lat, Longitude: $_long");
  }

  Future<void> _getAddressFromLatLng(double lat, double long) async {
    final apiKey = dotenv.env['SUPABASE_GOOGLE_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print(data);
      if (data['results'].isNotEmpty) {
        final address = data['results'][0]['formatted_address'];
        setState(() {
          _addressController.text = address;
        });
      } else {
        _showSnackBar('Nenhum endereço encontrado para esta localização.');
      }
    } else {
      _showSnackBar('Erro ao obter endereço: ${response.reasonPhrase}');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _addEstablishment() async {
    if (_lat == null || _long == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um local no mapa.')),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final data = {
      'nome': _nameController.text,
      'lat': _lat,
      'long': _long,
      'endereco': _addressController.text,
      'avaliacao': 0,
    };

    try {
      // Fazendo a inserção no Supabase
      final response = await supabase.from('estabelecimento').insert(data);
      // Exibe mensagem de sucesso
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Estabelecimento adicionado com sucesso!')),
      );
    } catch (e) {
      // Tratando possíveis exceções
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro inesperado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicione um Estabelecimento'),
      ),
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-5.101197108532969, -42.81045181541382),
                zoom: 14,
              ),
              markers: _markers,
              onTap: _onTap,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o nome';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await _addEstablishment();
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Adicionar Estabelecimento'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
