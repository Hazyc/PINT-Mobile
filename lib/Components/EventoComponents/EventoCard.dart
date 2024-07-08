import 'package:flutter/material.dart';
import '../../models/Evento.dart';
import '../../pages/EventoView.dart'; // Certifique-se de criar este widget para visualizar os detalhes do evento

class EventoCard extends StatelessWidget {
  final Evento evento;

  EventoCard({required this.evento});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventoView(
              evento: evento,
              onLike: () {
                print('Liked');
              },
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Image.asset(
                      evento.bannerImage,
                      height: 130, // Definindo a altura da imagem dentro do card
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Evento',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            evento.eventName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          evento.dateTime,
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_pin, color: Color(0xFF0DCAF0)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            evento.address,
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0DCAF0),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      evento.category,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      evento.description.length > 50
                          ? evento.description.substring(0, 50) + '...'
                          : evento.description,
                      style: TextStyle(fontSize: 14, color: Colors.black87),
                    ),
                    if (evento.description.length > 50)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventoView(
                                evento: evento,
                                onLike: () {
                                  print('Liked');
                                },
                              ),
                            ),
                          );
                        },
                        child: Text(
                          'ver mais...',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF0DCAF0),
                          ),
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
