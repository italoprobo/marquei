import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:geocoding/geocoding.dart';

class AddPlaces extends StatefulWidget {
  const AddPlaces({super.key});

  @override
  State<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends State<AddPlaces> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  double _lat = 0;
  double _long = 0;

  Future<void> _getLatLngFromAddress(String address) async {
    final locations = await GeocodingPlatform.instance?.locationFromAddress(address);
    final location = locations?.first;
    setState(() {
      _lat = location!.latitude;
      _long = location!.longitude;
    });
  }

  Future<void> _addEstablishment() async {
    final supabase = Supabase.instance.client;
    final data = {
      'nome': _nameController.text,
      'endereco': _addressController.text,
      'lat': _lat,
      'long': _long,
      'avaliacao': 0,
    };
    await supabase.from('estabelecimentos').insert(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Establishment'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter an address';
                }
                return null;
              },
              onFieldSubmitted: (value) async {
                await _getLatLngFromAddress(value);
              },
            ),
            ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  await _addEstablishment();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Establishment'),
            ),
          ],
        ),
      ),
    );
  }
}