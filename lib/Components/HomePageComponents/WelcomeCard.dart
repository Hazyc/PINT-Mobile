import 'package:flutter/material.dart';

class WelcomeCard extends StatelessWidget {
  final String userName;

  const WelcomeCard({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Obter a hora atual
    DateTime now = DateTime.now();
    int hour = now.hour;

    // Determinar a saudação com base na hora
    String greeting = 'Boa noite'; // Padrão é Boa noite
    if (hour >= 0 && hour < 12) {
      greeting = 'Bom dia';
    } else if (hour >= 12 && hour < 18) {
      greeting = 'Boa tarde';
    }

    return Padding(
      padding: const EdgeInsets.all(8.0), // Espaçamento ao redor do card
      child: Container(
        width: double.infinity, // Ocupar a largura total
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.blue,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$greeting, $userName',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
