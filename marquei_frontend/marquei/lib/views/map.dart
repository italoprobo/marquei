import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Inicializa a câmera na localização central do mapa
  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(-23.5505, -46.6333), // Coordenadas de São Paulo, Brasil
    zoom: 10,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa do Google'),
      ),
      body: GoogleMap(
        initialCameraPosition: _initialPosition,
        mapType: MapType.normal,
        // Adicione outros parâmetros ou funcionalidades conforme necessário
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MapPage(),
  ));
}
