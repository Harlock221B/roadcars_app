import 'package:flutter/material.dart';
import 'package:roadcarsapp/data/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:roadcarsapp/components/color_selection/color_selection.dart';
import 'package:roadcarsapp/components/utils/dropdown_field.dart';
import 'package:roadcarsapp/components/utils/text_field.dart';
import 'package:roadcarsapp/components/image_picker/image_picker.dart';
import 'package:roadcarsapp/components/utils/generic.dart'; // Importação dos componentes genéricos
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart'; // Importação necessária para FilteringTextInputFormatter
import 'package:intl/intl.dart'; // Importação do pacote intl

class EditCarScreen extends StatefulWidget {
  final String carId;

  const EditCarScreen({required this.carId, super.key});

  @override
  _EditCarScreenState createState() => _EditCarScreenState();
}

class _EditCarScreenState extends State<EditCarScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _kmController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  List<Uint8List> _carImages = [];
  List<String> _carImageUrls = [];

  String _selectedBrand = 'Toyota';
  String _selectedMotor = '1.0';
  String _selectedFuel = 'Gasolina';
  String _selectedTransmission = 'Automático';
  String _selectedColor = 'Preto';
  bool _isArmored = false;

  @override
  void initState() {
    super.initState();
    _loadCarDetails();
  }

  Future<void> _loadCarDetails() async {
    try {
      DocumentSnapshot carSnapshot =
          await _firestore.collection('cars').doc(widget.carId).get();

      if (!carSnapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carro não encontrado.')),
        );
        return;
      }

      Map<String, dynamic> carData = carSnapshot.data() as Map<String, dynamic>;

      setState(() {
        _selectedBrand = carData['brand'] ?? 'Toyota';
        _modelController.text = carData['model'] ?? '';
        _selectedMotor = carData['motor'] ?? '1.0';
        _selectedFuel = carData['fuel'] ?? 'Gasolina';
        _selectedTransmission = carData['transmission'] ?? 'Automático';
        _selectedColor = carData['color'] ?? 'Preto';
        _kmController.text = carData['km']?.toString() ?? '';
        _yearController.text = carData['year']?.toString() ?? '';
        _isArmored = carData['armored'] ?? false;
        _priceController.text = carData['price']?.toString() ?? '';
        _descriptionController.text = carData['description'] ?? '';
        _carImageUrls = List<String>.from(carData['imageUrls'] ?? []);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar dados do carro: $e')),
      );
    }
  }

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

  void _removeImageUrl(int index) {
    setState(() {
      _carImageUrls.removeAt(index);
    });
  }

  void _removeImage(int index) {
    setState(() {
      _carImages.removeAt(index);
    });
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

  Future<void> _editCar() async {
    if (_auth.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Você precisa estar logado para editar um carro.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      try {
        DocumentReference carDoc =
            _firestore.collection('cars').doc(widget.carId);

        if (_carImages.isNotEmpty) {
          _carImageUrls = await _uploadCarImagesToStorage(carDoc.id);
        }

        final NumberFormat kmFormat = NumberFormat.decimalPattern('pt_BR');
        final int km = int.parse(_kmController.text.replaceAll('.', ''));

        await carDoc.update({
          'brand': _selectedBrand,
          'model': _modelController.text,
          'motor': _selectedMotor,
          'fuel': _selectedFuel,
          'transmission': _selectedTransmission,
          'color': _selectedColor,
          'km': km,
          'year': _yearController.text,
          'armored': _isArmored,
          'price': double.parse(
              _priceController.text.replaceAll('.', '').replaceAll(',', '.')),
          'description': _descriptionController.text,
          if (_carImageUrls.isNotEmpty) 'imageUrls': _carImageUrls,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carro atualizado com sucesso!')),
        );
        Navigator.pop(context,
            true); // Retorna true para indicar que o carro foi atualizado
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao editar carro: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Carro'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _editCar,
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
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownField(
                    label: 'Câmbio',
                    selectedValue: _selectedTransmission,
                    options: transmissions,
                    onChanged: (value) {
                      setState(() {
                        _selectedTransmission = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _yearController,
                    label: 'Ano',
                  ),
                  const SizedBox(height: 16),
                  ColorSelection(
                    colors: carColors,
                    selectedColor: _selectedColor,
                    onColorSelected: (color) {
                      setState(() {
                        _selectedColor = color;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  KmInputField(
                      label: 'Quilometragem',
                      controller: _kmController), // Usando KmInputField
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
                  PriceInputField(
                      label: 'Preço',
                      controller: _priceController), // Usando PriceInputField
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    label: 'Descrição',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  ImagePickerComponent(
                    carImages: _carImages,
                    carImageUrls: _carImageUrls, // URLs das imagens salvas
                    onPickImages: _pickImages,
                    onRemoveImage: _removeImage,
                    onRemoveImageUrl:
                        _removeImageUrl, // Remover URLs de imagens salvas
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
