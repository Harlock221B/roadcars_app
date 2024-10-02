import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
          _profileImageUrl = userDoc['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      if (_profileImage != null) {
        _profileImageUrl =
            await _uploadImageToStorage(_profileImage!, user.uid);
      }

      await _firestore.collection('users').doc(user.uid).update({
        'displayName': _nameController.text,
        'phone': _phoneController.text,
        'favoriteCars': _favoriteCars,
        'profileImageUrl': _profileImageUrl,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil atualizado com sucesso!')),
      );
    }
  }

  Future<String> _uploadImageToStorage(File image, String userId) async {
    try {
      Reference storageRef = _storage.ref().child('profileImages/$userId.jpg');
      UploadTask uploadTask = storageRef.putFile(image);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
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
        // A imagem será exibida imediatamente no avatar quando selecionada
      });
    }
  }

  void _addFavoriteCar() {
    showDialog(
      context: context,
      builder: (context) {
        String newCar = '';
        return AlertDialog(
          title: const Text('Adicionar Carro Favorito'),
          content: TextField(
            onChanged: (value) {
              newCar = value;
            },
            decoration:
                const InputDecoration(hintText: 'Digite o nome do carro'),
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
              child: const Text('Adicionar'),
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

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateProfile,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout, // Botão de logout
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) // Exibe a imagem local
                      : (_profileImageUrl != null
                          ? NetworkImage(_profileImageUrl!) // Exibe a imagem do Firebase
                          : null),
                  child: _profileImage == null && _profileImageUrl == null
                      ? const Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 10,
                  child: InkWell(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black,
                      ),
                      child: const Icon(Icons.edit, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, 'Nome', Icons.person),
            const SizedBox(height: 20),
            _buildTextField(_phoneController, 'Telefone', Icons.phone,
                keyboardType: TextInputType.phone),
            const SizedBox(height: 20),
            _buildFavoriteCarsSection(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateProfile,
              child: const Text('Salvar Alterações'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildFavoriteCarsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Carros Favoritos',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: _addFavoriteCar,
            ),
          ],
        ),
        if (_favoriteCars.isEmpty)
          const Center(child: Text('Nenhum carro favorito adicionado')),
        for (String car in _favoriteCars)
          ListTile(
            title: Text(car),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _removeFavoriteCar(car),
            ),
          ),
      ],
    );
  }
}
