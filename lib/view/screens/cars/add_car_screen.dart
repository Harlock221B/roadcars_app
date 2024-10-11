import 'package:flutter/material.dart';
import 'package:roadcarsapp/data/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadcarsapp/components/color_selection/color_selection.dart';
import 'package:roadcarsapp/components/utils/dropdown_field.dart';
import 'package:roadcarsapp/components/utils/text_field.dart';
import 'dart:typed_data';
import 'package:firebase_auth/firebase_auth.dart'; // Adicionado para autenticação
import 'package:dotted_border/dotted_border.dart'; // Adicionado para borda pontilhada

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
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

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
            _storage.ref().child('carImages/$carId/$_selectedBrand-$i.jpg');
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
      crossAxisAlignment: CrossAxisAlignment.center, // Centraliza o conteúdo
      children: [
        const Text(
          'Imagens do Carro',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87, // Cor de texto mais elegante
          ),
          textAlign: TextAlign.center, // Centraliza o texto
        ),
        const SizedBox(height: 16), // Mais espaço entre o título e o grid
        GridView.builder(
          shrinkWrap: true,
          itemCount: (_carImages.length + 1) > 6
              ? _carImages.length
              : _carImages.length + 1,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16, // Mais espaço entre os quadrados
            mainAxisSpacing: 16, // Mais espaço entre os quadrados
          ),
          itemBuilder: (context, index) {
            if (index < _carImages.length) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius:
                        BorderRadius.circular(12), // Bordas suavizadas
                    child: Image.memory(
                      _carImages[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 6, // Ajuste fino na posição do ícone de remover
                    right: 6,
                    child: GestureDetector(
                      onTap: () => _removeImage(index),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (index == _carImages.length && _carImages.length < 6) {
              // Placeholder visual para adicionar mais imagens
              return GestureDetector(
                onTap: _pickImages,
                child: DottedBorder(
                  borderType: BorderType.RRect,
                  radius: const Radius.circular(12),
                  dashPattern: const [6, 3],
                  color: Colors.grey[400]!,
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo,
                          color: Colors.grey,
                          size: 32,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Adicionar mais fotos',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center, // Centraliza o texto
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const SizedBox
                  .shrink(); // Se o número de imagens for superior a 6
            }
          },
        ),
      ],
    );
  }

  void _removeImage(int index) {
    setState(() {
      _carImages.removeAt(index);
    });
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
        // Adiciona o carro à coleção "cars"
        DocumentReference carDoc = await _firestore.collection('cars').add({
          'brand': _selectedBrand,
          'model': _modelController.text,
          'motor': _selectedMotor,
          'fuel': _selectedFuel,
          'transmission': _selectedTransmission,
          'color': _selectedColor,
          'km': _kmController.text,
          'year': _yearController.text,
          'armored': _isArmored,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': _auth.currentUser!.uid,
        });

        // Upload das imagens para o Storage
        _carImageUrls = await _uploadCarImagesToStorage(carDoc.id);

        // Atualiza o documento do carro com as URLs das imagens
        if (_carImageUrls.isNotEmpty) {
          await carDoc.update({
            'imageUrls': _carImageUrls,
          });
        }

        // Atualiza o documento do usuário, adicionando o carId na lista de carros registrados
        await _firestore
            .collection('users')
            .doc(_auth.currentUser!.uid)
            .update({
          'registeredCars': FieldValue.arrayUnion([carDoc.id]),
        });

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
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCar,
        backgroundColor: Colors.blueGrey,
        child: const Icon(Icons.save),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  DropdownField(
                    label: 'Marca',
                    selectedValue: _selectedBrand,
                    options: brands,
                    onChanged: (value) {
                      setState(() {
                        _selectedBrand = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _modelController,
                    label: 'Modelo',
                  ),
                  const SizedBox(height: 16),
                  DropdownField(
                    label: 'Motor',
                    selectedValue: _selectedMotor,
                    options: motors,
                    onChanged: (value) {
                      setState(() {
                        _selectedMotor = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownField(
                      label: 'Combustível',
                      selectedValue: _selectedFuel,
                      options: fuelTypes,
                      onChanged: (value) {
                        setState(() {
                          _selectedFuel = value!;
                        });
                      }),
                  const SizedBox(height: 16),
                  DropdownField(
                      label: 'Câmbio',
                      selectedValue: _selectedTransmission,
                      options: transmissions,
                      onChanged: (value) {
                        setState(() {
                          _selectedTransmission = value!;
                        });
                      }),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _yearController, label: 'Ano'),
                  const SizedBox(height: 16),
                  ColorSelection(
                    selectedColor: _selectedColor,
                    colors: carColors,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _kmController, label: 'KM Rodados'),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Blindado',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    value: _isArmored,
                    onChanged: (bool value) {
                      setState(() {
                        _isArmored = value;
                      });
                    },
                    activeColor: Colors.blueGrey,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(controller: _priceController, label: 'Preço'),
                  const SizedBox(height: 16),
                  CustomTextField(
                      controller: _descriptionController,
                      label: 'Descrição',
                      maxLines: 3),
                  const SizedBox(height: 16),
                  _buildImagePicker(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
