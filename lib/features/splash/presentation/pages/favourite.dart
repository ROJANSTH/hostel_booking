import 'package:flutter/material.dart';

class FavouriteScreen extends StatelessWidget {
  const FavouriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'I am Favourite Screen',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
        ),
      ),
    );
  }
}
