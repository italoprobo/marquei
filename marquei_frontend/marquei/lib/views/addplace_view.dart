import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';  
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../controllers/addplace_controller.dart';

class AddPlaces extends StatefulWidget {
  const AddPlaces({super.key});

  @override
  State<AddPlaces> createState() => _AddPlacesState();
}

class _AddPlacesState extends State<AddPlaces> {
  final _formKey = GlobalKey<FormState>();
  final _controller = AddPlaceController();
  final Set<Marker> _markers = {};
  late GoogleMapController _mapController;
  Uint8List? _selectedImage; // Armazena os bytes da imagem selecionada
  String? _fileName; // Armazena o nome do arquivo selecionado

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _setCurrentLocation();
  }

  void _setCurrentLocation() async {
    try {
      LatLng currentLocation = await _controller.getCurrentLocation();
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: currentLocation,
            zoom: 14,
          ),
        ),
      );

      setState(() {
        _markers.clear();
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          position: currentLocation,
          infoWindow: const InfoWindow(title: 'Você está aqui'),
        ));
      });
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _onTap(LatLng latLng) async {
    setState(() {
      _controller.lat = latLng.latitude;
      _controller.long = latLng.longitude;
      _markers.clear();
      _markers.add(Marker(
        markerId: const MarkerId('selected_location'),
        position: latLng,
        infoWindow: const InfoWindow(title: 'Localização Selecionada'),
      ));
    });

    try {
      await _controller.getAddressFromLatLng(
          _controller.lat!, _controller.long!);
    } catch (e) {
      _showSnackBar(e.toString());
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImage = imageBytes;
        _fileName = pickedFile.name; // Salva o nome do arquivo
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Estabelecimento'),
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
                    controller: _controller.nameController,
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
                    controller: _controller.addressController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Endereço',
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _controller.photoUrlController,
                    decoration: const InputDecoration(
                      labelText: 'URL da Foto (opcional)',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_selectedImage != null)
                    Image.memory(_selectedImage!),
                  ElevatedButton(
                    onPressed: _pickImage,
                    child: const Text('Carregar Imagem'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          await _controller.addEstablishment(_selectedImage, _fileName);
                          _showSnackBar(
                              'Estabelecimento adicionado com sucesso!');
                          Navigator.pop(context);
                        } catch (e) {
                          _showSnackBar(e.toString());
                        }
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