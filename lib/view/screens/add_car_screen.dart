import 'package:flutter/material.dart';
import 'package:roadcarsapp/data/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart'; // Adicionado para autenticação

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  _AddCarScreenState createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance; // Autenticação

  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Uint8List> _carImages = [];
  List<String> _carImageUrls = [];

  // Valores iniciais para selects
  String _selectedBrand = 'Toyota'; // Valor inicial para marca
  String _selectedMotor = '1.0'; // Valor inicial para motor
  String _selectedFuel = 'Gasolina'; // Valor inicial para combustível
  String _selectedTransmission = 'Automático'; // Valor inicial para câmbio
  String _selectedColor = 'Preto'; // Valor inicial para cor
  bool _isArmored = false; // Valor inicial para blindagem

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedImages = await picker.pickMultiImage();
      List<Uint8List> imageBytesList = [];

      for (var image in pickedImages) {
        final Uint8List imageBytes = await image.readAsBytes();
        imageBytesList.add(imageBytes);
      }

      setState(() {
        _carImages = imageBytesList;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar imagens.')),
      );
    }
  }

  Future<List<String>> _uploadCarImagesToStorage(String carId) async {
    List<String> downloadUrls = [];
    for (int i = 0; i < _carImages.length; i++) {
      try {
        Reference storageRef =
            _storage.ref().child('carImages/$carId/${_selectedBrand}-$i.jpg');
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
        UploadTask uploadTask = storageRef.putData(_carImages[i], metadata);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadUrl);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
        );
      }
    }
    return downloadUrls;
  }

  Widget _buildImagePicker() {
    return Column(
      children: [
        _carImages.isEmpty
            ? const Text('Nenhuma imagem selecionada.')
            : GridView.builder(
                shrinkWrap: true,
                itemCount: _carImages.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemBuilder: (context, index) {
                  return Image.memory(_carImages[index], fit: BoxFit.cover);
                },
              ),
        ElevatedButton.icon(
          onPressed: _pickImages,
          icon: const Icon(Icons.photo_library),
          label: const Text('Selecionar Imagens'),
        ),
      ],
    );
  }

  Future<void> _addCar() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Você precisa estar logado para adicionar um carro.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference carDoc = await _firestore.collection('cars').add({
          'brand': _selectedBrand,
          'motor': _selectedMotor,
          'fuel': _selectedFuel,
          'transmission': _selectedTransmission,
          'color': _selectedColor,
          'km': _kmController.text,
          'armored': _isArmored,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': _auth.currentUser!.uid,
        });

        _carImageUrls = await _uploadCarImagesToStorage(carDoc.id);

        if (_carImageUrls.isNotEmpty) {
          await carDoc.update({
            'imageUrls': _carImageUrls,
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carro adicionado com sucesso!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar carro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Carro para Venda'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCar,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 5,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedBrand,
                    items: brands.map((String brand) {
                      return DropdownMenuItem<String>(
                        value: brand,
                        child: Text(brand),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedMotor,
                    items: motors.map((String motor) {
                      return DropdownMenuItem<String>(
                        value: motor,
                        child: Text(motor),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedMotor = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Motor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedFuel,
                    items: fuelTypes.map((String fuel) {
                      return DropdownMenuItem<String>(
                        value: fuel,
                        child: Text(fuel),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedFuel = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Combustível',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedTransmission,
                    items: transmissions.map((String transmission) {
                      return DropdownMenuItem<String>(
                        value: transmission,
                        child: Text(transmission),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmission = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Câmbio',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedColor,
                    items: colors.map((String color) {
                      return DropdownMenuItem<String>(
                        value: color,
                        child: Text(color),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedColor = value!;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Cor',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _kmController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'KM Rodados',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a quilometragem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text('Blindado'),
                    value: _isArmored,
                    onChanged: (bool value) {
                      setState(() {
                        _isArmored = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Preço',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o preço';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descrição',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira uma descrição para o carro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addCar,
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Carro'),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
