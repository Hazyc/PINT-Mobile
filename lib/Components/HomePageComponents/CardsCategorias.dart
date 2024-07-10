import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final VoidCallback onTap; // Adicionado para passar a função de callback

  HomeCard({required this.imageAsset, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Chama a função de callback passada
      child: Container(
        width: 200,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  imageAsset,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            offset: Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.7),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
