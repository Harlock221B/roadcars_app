import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Importação do Firebase Storage
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;
  List<String> _favoriteCars = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['displayName'] ?? '';
          _phoneController.text = userDoc['phone'] ?? '';
          _favoriteCars = List<String>.from(userDoc['favoriteCars'] ?? []);
          _profileImageUrl =
              userDoc['profileImageUrl']; // Carrega a URL da imagem do perfil
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (_profileImage != null) {
        // Faz o upload da imagem e obtém o URL
        _profileImageUrl =
            await _uploadImageToStorage(_profileImage!, user.uid);
      }

      // Atualiza os dados do perfil no Firestore
      await _firestore.collection('users').doc(user.uid).update({
        'displayName': _nameController.text,
        'phone': _phoneController.text,
        'favoriteCars': _favoriteCars,
        'profileImageUrl':
            _profileImageUrl, // Atualiza a URL da imagem do perfil
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  // Função para fazer upload da imagem no Firebase Storage
  Future<String> _uploadImageToStorage(File image, String userId) async {
    try {
      // Definir o caminho no storage
      Reference storageRef = _storage.ref().child('profileImages/$userId.jpg');

      // Upload da imagem
      UploadTask uploadTask = storageRef.putFile(image);

      // Esperar a conclusão do upload
      TaskSnapshot snapshot = await uploadTask;

      // Obter o download URL da imagem
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Erro ao fazer upload da imagem: $e');
      return '';
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  void _addFavoriteCar() {
    showDialog(
      context: context,
      builder: (context) {
        String newCar = '';
        return AlertDialog(
          title: Text('Adicionar Carro Favorito'),
          content: TextField(
            onChanged: (value) {
              newCar = value;
            },
            decoration: InputDecoration(hintText: 'Digite o nome do carro'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (newCar.isNotEmpty) {
                  setState(() {
                    _favoriteCars.add(newCar);
                  });
                }
                Navigator.pop(context);
              },
              child: Text('Adicionar'),
            ),
          ],
        );
      },
    );
  }

  void _removeFavoriteCar(String car) {
    setState(() {
      _favoriteCars.remove(car);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImageUrl != null
                      ? NetworkImage(_profileImageUrl!)
                      : null,
                  child: _profileImage == null && _profileImageUrl == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Carros Favoritos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ..._favoriteCars.map((car) => ListTile(
                  title: Text(car),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _removeFavoriteCar(car),
                  ),
                )),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addFavoriteCar,
              child: Text('Adicionar Carro Favorito'),
            ),
          ],
        ),
      ),
    );
  }
}
