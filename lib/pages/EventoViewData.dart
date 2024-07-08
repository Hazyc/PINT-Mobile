import 'package:flutter/material.dart';
import 'EventoView.dart'; // Certifique-se de ajustar o caminho conforme necessário
import '../models/Evento.dart';

void main() {
  runApp(MaterialApp(
    home: EventoViewData(),
  ));
}

class EventoViewData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Evento evento = Evento(
      bannerImage: 'assets/alojamento.jpg',
      eventName: 'St. Regis Bora Bora',
      dateTime: 'July 14, 2024 - 6:00 PM',
      address: 'Rua das Eiras, nº 28 3525-515',
      category: 'Alojamento',
      subcategory: 'Hotel',
      lastThreeAttendees: [
        'assets/user-1.png',
        'assets/user-2.png',
        'assets/user-3.png',
      ],
      description: 'Bora Bora is an island in the Leeward group of the Society Islands of French Polynesia, an overseas collectivity of France in the Pacific Ocean.',
    );

    return EventoView(
      evento: evento,
      onLike: () {
        print('Liked');
      },
    );
  }
}
