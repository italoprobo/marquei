// controllers/addplace_controller.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geolocator/geolocator.dart';

class AddPlaceController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  double? lat;
  double? long;

  // Método para obter a localização atual do usuário
  Future<LatLng> getCurrentLocation() async {
    // Solicita permissões de localização e verifica se o serviço está habilitado
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Por favor, habilite os serviços de localização.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Permissão de localização permanentemente negada. Não podemos acessar sua localização.');
    }

    // Obtém a localização atual do usuário com a precisão desejada
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high, // Usa precisão alta
    );

    // Atualiza as coordenadas no controller
    lat = position.latitude;
    long = position.longitude;

    return LatLng(lat!, long!);
  }

  // Função para obter o endereço a partir da latitude e longitude
  Future<void> getAddressFromLatLng(double lat, double long) async {
    final apiKey = dotenv.env['SUPABASE_GOOGLE_API_KEY'];
    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$long&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final address = data['results'][0]['formatted_address'];
        addressController.text = address;
      } else {
        throw Exception('Nenhum endereço encontrado');
      }
    } else {
      throw Exception('Erro ao obter endereço: ${response.reasonPhrase}');
    }
  }

  // Função para adicionar o estabelecimento no Supabase
  Future<void> addEstablishment() async {
    if (lat == null || long == null) {
      throw Exception('Por favor, selecione um local no mapa.');
    }

    final supabase = Supabase.instance.client;
    final data = {
      'nome': nameController.text,
      'lat': lat,
      'long': long,
      'endereco': addressController.text,
      'avaliacao': 0,
    };

    try {
      await supabase.from('estabelecimento').insert(data);
    } catch (e) {
      throw Exception('Erro ao salvar o estabelecimento: $e');
    }
  }
}