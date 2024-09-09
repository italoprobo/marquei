import 'dart:typed_data';
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
  final photoUrlController = TextEditingController();  
  double? lat;
  double? long;

  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('O serviço de localização está desativado.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('As permissões de localização foram negadas');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'As permissões de localização são permanentemente negadas, não podemos solicitar permissões.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> getAddressFromLatLng(double latitude, double longitude) async {
    final apiKey = dotenv.env['SUPABASE_GOOGLE_API_KEY'];
    if (apiKey == null) {
      throw Exception('Google Maps API key não encontrada.');
    }

    final url =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['results'].isNotEmpty) {
        final formattedAddress = data['results'][0]['formatted_address'];
        addressController.text = formattedAddress;
      } else {
        throw Exception('Nenhum endereço encontrado para essa localização.');
      }
    } else {
      throw Exception(
          'Falha ao buscar o endereço: ${response.statusCode}');
    }
  }

  Future<String?> _uploadImage(Uint8List imageBytes, String fileName) async {
    final supabase = Supabase.instance.client;

    try {
      final storageResponse = await supabase.storage
          .from('estabelecimento')
          .uploadBinary(fileName, imageBytes);

      final publicUrl = supabase.storage.from('estabelecimento').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      throw Exception('Erro ao fazer upload da imagem: $e');
    }
  }

  Future<void> addEstablishment(Uint8List? imageBytes, String? fileName) async {
    if (lat == null || long == null) {
      throw Exception('Por favor, selecione um local no mapa.');
    }

    String? photoUrl;

    if (imageBytes != null && fileName != null) {
      photoUrl = await _uploadImage(imageBytes, fileName);
    } else if (photoUrlController.text.isNotEmpty) {
      photoUrl = photoUrlController.text;
    }

    final supabase = Supabase.instance.client;
    final data = {
      'nome': nameController.text,
      'lat': lat,
      'long': long,
      'endereco': addressController.text,
      'avaliacao': 0,
      'foto_url': photoUrl,
    };

    try {
      await supabase.from('estabelecimento').insert(data);
    } catch (e) {
      throw Exception('Erro ao salvar o estabelecimento: $e');
    }
  }
}
