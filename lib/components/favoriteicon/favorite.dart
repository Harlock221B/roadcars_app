import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FavoriteIcon extends StatefulWidget {
  final String carId;

  const FavoriteIcon({Key? key, required this.carId}) : super(key: key);

  @override
  _FavoriteIconState createState() => _FavoriteIconState();
}

class _FavoriteIconState extends State<FavoriteIcon> {
  bool isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite(); // Verifica se o carro já está favoritado
  }

  Future<void> _checkIfFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      List<dynamic> favoritedCars = userDoc['favoritedCars'] ?? [];
      if (favoritedCars.contains(widget.carId)) {
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      DocumentReference userDoc =
          FirebaseFirestore.instance.collection('users').doc(userId);
      if (isFavorite) {
        // Remove dos favoritos
        await userDoc.update({
          'favoritedCars': FieldValue.arrayRemove([widget.carId]),
        });
        setState(() {
          isFavorite = false;
        });
      } else {
        // Adiciona aos favoritos
        await userDoc.update({
          'favoritedCars': FieldValue.arrayUnion([widget.carId]),
        });
        setState(() {
          isFavorite = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : Colors.white,
        size: 30,
      ),
      onPressed: _toggleFavorite,
    );
  }
}
