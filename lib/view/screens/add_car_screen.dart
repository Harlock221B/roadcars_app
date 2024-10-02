import 'package:flutter/material.dart';
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
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // Adicionado para autenticação
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  List<Uint8List> _carImages =
      []; // Usando Uint8List para armazenar dados binários das imagens
  List<String> _carImageUrls = [];

  Future<void> _pickImages() async {
    try {
      final ImagePicker picker = ImagePicker();
      final pickedImages = await picker.pickMultiImage();

      if (pickedImages != null) {
        List<Uint8List> imageBytesList = [];

        for (var image in pickedImages) {
          final Uint8List imageBytes =
              await image.readAsBytes(); // Usado para web
          imageBytesList.add(imageBytes);
        }

        setState(() {
          _carImages = imageBytesList;
        });
      }
    } catch (e) {
      // Tratamento de exceção ao pegar as imagens
      print('Erro ao selecionar imagens: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao selecionar imagens.')),
      );
    }
  }

Future<List<String>> _uploadCarImagesToStorage(String carId) async {
  List<String> downloadUrls = [];

  for (int i = 0; i < _carImages.length; i++) {
    try {
      // Referência do arquivo no Storage
      Reference storageRef = _storage.ref().child('carImages/$carId/$i.jpg');

      // Definir metadados com o tipo MIME adequado (image/jpeg)
      SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');

      // Upload da imagem com os metadados
      UploadTask uploadTask = storageRef.putData(_carImages[i], metadata);

      // Aguardar a conclusão do upload
      TaskSnapshot snapshot = await uploadTask;

      // Obter a URL de download da imagem
      String downloadUrl = await snapshot.ref.getDownloadURL();
      downloadUrls.add(downloadUrl);

    } catch (e) {
      // Tratamento de erro com contexto verificado
      print('Erro ao fazer upload da imagem: $e');
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
        );
      }
    }
  }

  return downloadUrls;
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
        // Adiciona os dados do carro ao Firestore
        DocumentReference carDoc = await _firestore.collection('cars').add({
          'brand': _brandController.text,
          'model': _modelController.text,
          'year': _yearController.text,
          'price': _priceController.text,
          'description': _descriptionController.text,
          'createdAt': FieldValue.serverTimestamp(),
          'userId': _auth.currentUser!.uid, // Salvar o ID do usuário logado
        });

        // Faz o upload das imagens para o Firebase Storage
        _carImageUrls = await _uploadCarImagesToStorage(carDoc.id);

        // Atualiza o documento com as URLs das imagens
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
        // Tratamento de exceção ao adicionar o carro
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
                  TextFormField(
                    controller: _brandController,
                    decoration: const InputDecoration(
                      labelText: 'Marca',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira a marca do carro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _modelController,
                    decoration: const InputDecoration(
                      labelText: 'Modelo',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o modelo do carro';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Ano',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, insira o ano do carro';
                      }
                      return null;
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
                        return 'Por favor, insira o preço do carro';
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
                  GestureDetector(
                    onTap: _pickImages,
                    child: SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _carImages.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _carImages.length) {
                            return CircleAvatar(
                              radius: 50,
                              child: const Icon(Icons.camera_alt, size: 50),
                            );
                          }
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: MemoryImage(_carImages[
                                  index]), // Exibindo a imagem da web
                            ),
                          );
                        },
                      ),
                    ),
                  ),
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
