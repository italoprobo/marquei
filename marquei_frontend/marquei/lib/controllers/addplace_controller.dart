// controllers/addplace_controller.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddPlaceController {
  final nameController = TextEditingController();
  final addressController = TextEditingController();
  double? lat;
  double? long;

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
