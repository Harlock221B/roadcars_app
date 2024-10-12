import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:roadcarsapp/components/vehicle/vehicle_card.dart';
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
  List<Map<String, dynamic>> _favoritedCarDetails = [];
  List<Map<String, dynamic>> _addedCarDetails = [];
  bool _isVendor = false; // Inicialização da condição de vendedor
  bool _isEditing = false;

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
          _isVendor = userDoc['isVendor'] ?? false;
        });
        _loadFavoritedCarDetails();
        _loadAddedCars(); // Carregar carros adicionados
      }
    }
  }

  Future<void> _loadFavoritedCarDetails() async {
    List<Map<String, dynamic>> carDetails = [];

    for (String carId in _favoritedCars) {
      try {
        DocumentSnapshot carDoc =
            await _firestore.collection('cars').doc(carId).get();

        if (carDoc.exists) {
          Map<String, dynamic> carData = carDoc.data() as Map<String, dynamic>;
          carData['id'] = carId;
          carDetails.add(carData);
        }
      } catch (e) {
        print(
            "Erro ao carregar detalhes do carro favoritado com ID $carId: $e");
      }
    }

    setState(() {
      _favoritedCarDetails = carDetails;
    });
  }

  // Função para carregar os carros que o usuário adicionou
  Future<void> _loadAddedCars() async {
    User? user = _auth.currentUser;
    if (user != null) {
      QuerySnapshot querySnapshot = await _firestore
          .collection('cars')
          .where('userId', isEqualTo: user.uid)
          .get();
      List<Map<String, dynamic>> addedCars = querySnapshot.docs
          .map((doc) => {...doc.data() as Map<String, dynamic>, 'id': doc.id})
          .toList();

      setState(() {
        _addedCarDetails = addedCars;
      });
    }
  }

  void _editProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25.0)),
      ),
      builder: (context) {
        String newDisplayName = _displayName ?? '';
        String newEmail = _email ?? '';

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Campo de nome
              TextField(
                decoration: InputDecoration(
                  labelText: 'Nome',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.person),
                ),
                onChanged: (value) {
                  newDisplayName = value;
                },
                controller: TextEditingController(text: _displayName),
              ),
              const SizedBox(height: 16),

              // Campo de e-mail
              TextField(
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email),
                ),
                onChanged: (value) {
                  newEmail = value;
                },
                controller: TextEditingController(text: _email),
              ),
              const SizedBox(height: 24),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await _saveProfile(newDisplayName, newEmail);
                      Navigator.of(context).pop();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Salvar',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile(String newDisplayName, String newEmail) async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Atualiza os dados do usuário no Firestore
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': newDisplayName,
          'email': newEmail,
        });

        // Atualiza o nome e o email no Firebase Authentication
        await user.updateDisplayName(newDisplayName);
        await user.updateEmail(newEmail);

        // Recarrega as informações do usuário
        await user.reload();

        setState(() {
          _displayName = newDisplayName;
          _email = newEmail;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar perfil: $e')),
        );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
              _editProfile(); // Chama a função de edição de perfil
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
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

              // Seção de Carros Favoritados
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Carros Favoritados',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _favoritedCarDetails.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _favoritedCarDetails.length,
                      itemBuilder: (context, index) {
                        final vehicle = _favoritedCarDetails[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10.0),
                          child: Material(
                            elevation: 8,
                            borderRadius: BorderRadius.circular(12),
                            child: VehicleCard(
                              carId: vehicle['id'],
                              vehicle: {
                                'brand': vehicle['brand'],
                                'model': vehicle['model'],
                                'year': vehicle['year'],
                                'price': vehicle['price'],
                                'km': vehicle['km'],
                                'fuel': vehicle['fuel'],
                                'transmission': vehicle['transmission'],
                                'description': vehicle['description'],
                                'imageUrls':
                                    vehicle['imageUrls'] as List<dynamic>,
                              },
                            ),
                          ),
                        );
                      },
                    )
                  : const Text(
                      'Você não favoritou nenhum carro ainda.',
                      style: TextStyle(color: Colors.grey),
                    ),
              const SizedBox(height: 30),

              if (_isVendor)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Carros que você está vendendo',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _addedCarDetails.isNotEmpty
                        ? ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _addedCarDetails.length,
                            itemBuilder: (context, index) {
                              final addedCar = _addedCarDetails[index];
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Material(
                                  elevation: 8,
                                  borderRadius: BorderRadius.circular(12),
                                  child: VehicleCard(
                                    carId: addedCar['id'],
                                    vehicle: {
                                      'brand': addedCar['brand'],
                                      'model': addedCar['model'],
                                      'year': addedCar['year'],
                                      'price': addedCar['price'],
                                      'description': addedCar['description'],
                                      'km': addedCar['km'],
                                      'fuel': addedCar['fuel'],
                                      'transmission': addedCar['transmission'],
                                      'imageUrls': addedCar['imageUrls']
                                          as List<dynamic>,
                                    },
                                  ),
                                ),
                              );
                            },
                          )
                        : const Text(
                            'Você não adicionou nenhum carro à venda.',
                            style: TextStyle(color: Colors.grey),
                          ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
