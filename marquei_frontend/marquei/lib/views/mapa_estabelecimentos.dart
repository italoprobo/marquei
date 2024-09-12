import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapaEstabelecimentos extends StatefulWidget {
  const MapaEstabelecimentos({Key? key}) : super(key: key);

  @override
  _MapaEstabelecimentosState createState() => _MapaEstabelecimentosState();
}

class _MapaEstabelecimentosState extends State<MapaEstabelecimentos> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  LatLng _initialPosition = const LatLng(-5.101197108532969, -42.81045181541382);

  @override
  void initState() {
    super.initState();
    _loadEstabelecimentos();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _initialPosition = LatLng(position.latitude, position.longitude);
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: _initialPosition, zoom: 14),
        ),
      );
    });
  }

  Future<void> _loadEstabelecimentos() async {
    final response = await Supabase.instance.client
        .from('estabelecimento')
        .select('nome, lat, long');

    if (response != null && response.isNotEmpty) {
      setState(() {
        for (var estabelecimento in response) {
          _markers.add(Marker(
            markerId: MarkerId(estabelecimento['nome']),
            position: LatLng(estabelecimento['lat'], estabelecimento['long']),
            infoWindow: InfoWindow(
              title: estabelecimento['nome'],
            ),
          ));
        }
      });
    } else {
      print('Erro ao carregar estabelecimentos: $response');
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;

    // Aplicar estilo customizado
    String style = '''
    [
      {
        "featureType": "poi",
        "elementType": "labels",
        "stylers": [
          { "visibility": "off" }
        ]
      },
      {
        "featureType": "transit",
        "elementType": "labels.icon",
        "stylers": [
          { "visibility": "off" }
        ]
      }
    ]
    ''';
    
    _mapController.setMapStyle(style);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa dos Estabelecimentos'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14,
        ),
        markers: _markers,
      ),
    );
  }
}
