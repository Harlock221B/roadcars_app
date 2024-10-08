import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Uint8List? _profileImage;
  String? _profileImageUrl;
  String? _displayName;
  String? _email;
  List<String> _favoritedCars = [];

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        setState(() {
          _profileImageUrl = userDoc['profileImageUrl'];
          _displayName = userDoc['displayName'];
          _email = userDoc['email'];
          _favoritedCars = List<String>.from(userDoc['favoritedCars']);
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      final Uint8List imageBytes = await pickedImage.readAsBytes();
      setState(() {
        _profileImage = imageBytes;
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    User? user = _auth.currentUser;
    if (user != null && _profileImage != null) {
      try {
        Reference storageRef =
            _storage.ref().child('profileImages/${user.uid}.jpg');
        UploadTask uploadTask = storageRef.putData(_profileImage!);
        TaskSnapshot snapshot = await uploadTask;
        String downloadUrl = await snapshot.ref.getDownloadURL();

        await _firestore.collection('users').doc(user.uid).update({
          'profileImageUrl': downloadUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Imagem de perfil atualizada com sucesso!')),
        );
        setState(() {
          _profileImageUrl = downloadUrl;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $e')),
        );
      }
    }
  }

  Widget _buildFavoritedCarsList() {
    return _favoritedCars.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Carros Favoritados',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _favoritedCars.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[200],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                _favoritedCars[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.car_rental, size: 50),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Car ${index + 1}',
                            style: const TextStyle(color: Colors.black87),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          )
        : const Text('Nenhum carro favoritado.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.only(left: 0, right: 0, top: 100, bottom: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  CircleAvatar(
                    radius: 70,
                    backgroundImage: _profileImage != null
                        ? MemoryImage(_profileImage!)
                        : (_profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : null),
                    backgroundColor: Colors.grey[300],
                    child: _profileImage == null && _profileImageUrl == null
                        ? const Icon(Icons.person, size: 70, color: Colors.grey)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black,
                        ),
                        child:
                            const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Text(
                _displayName ?? 'Nome do usuário',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _email ?? '',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _uploadProfileImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('Salvar Alterações',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
              const SizedBox(height: 30),
              _buildFavoritedCarsList(),
            ],
          ),
        ),
      ),
    );
  }
}
