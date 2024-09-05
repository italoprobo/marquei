import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPlaces extends StatefulWidget {
  const AddPlaces({super.key});

  @override
  State<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends State<AddPlaces> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  double? _lat;
  double? _long;
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  void _onTap(LatLng latLng) {
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
    print("Latitude: $_lat, Longitude: $_long");
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
      'avaliacao': 0,
    };

    final response = await supabase.from('estabelecimentos').insert(data);

    if (response.error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Estabelecimento adicionado com sucesso!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao adicionar: ${response.error!.message}')),
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
