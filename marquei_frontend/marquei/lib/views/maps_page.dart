import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapsPage extends StatefulWidget {
  const MapsPage({super.key});

  @override
  State<MapsPage> createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  static const LatLng _GoogleLocation = LatLng(-5.08921, -42.8016);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: GoogleMap(initialCameraPosition: CameraPosition(target: _GoogleLocation, zoom: 14)));
  }
}