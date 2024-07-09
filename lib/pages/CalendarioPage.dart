import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import '../models/Evento.dart';
import 'EventoView.dart';

class CalendarioPage extends StatefulWidget {
  final List<Evento> eventos;

  CalendarioPage({required this.eventos});

  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();

  Map<DateTime, List<Evento>> _eventosPorDia = {};

  @override
  void initState() {
    super.initState();
    _eventosPorDia = _groupEventosPorDia(widget.eventos);
  }

  Map<DateTime, List<Evento>> _groupEventosPorDia(List<Evento> eventos) {
    Map<DateTime, List<Evento>> dataMap = {};
    for (var evento in eventos) {
      try {
        DateTime eventDate = DateFormat('MMMM d, yyyy - h:mm a').parse(evento.dateTime);
        DateTime normalizedDate = DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (dataMap[normalizedDate] == null) {
          dataMap[normalizedDate] = [];
        }
        dataMap[normalizedDate]!.add(evento);
      } catch (e) {
        print('Erro ao analisar a data do evento: ${evento.dateTime}');
      }
    }
    return dataMap;
  }

  List<Evento> _getEventosParaDia(DateTime dia) {
    DateTime normalizedDate = DateTime(dia.year, dia.month, dia.day);
    return _eventosPorDia[normalizedDate] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário de Eventos'),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'pt_BR',
            firstDay: DateTime.utc(2021, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            eventLoader: _getEventosParaDia,
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _getEventosParaDia(_selectedDay).isNotEmpty
                ? ListView.builder(
                    itemCount: _getEventosParaDia(_selectedDay).length,
                    itemBuilder: (context, index) {
                      final evento = _getEventosParaDia(_selectedDay)[index];
                      return ListTile(
                        title: Text(evento.eventName),
                        subtitle: Text(evento.dateTime),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EventoView(
                                evento: evento,
                                onLike: () {},
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                : Center(child: Text('Nenhum evento para este dia.')),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(
    MaterialApp(
      locale: Locale('pt', 'BR'),
      supportedLocales: [
        const Locale('en', 'US'),
        const Locale('pt', 'BR'),
      ],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: CalendarioPage(
        eventos: [
          Evento(
            bannerImage: 'assets/night.jpg',
            eventName: 'Evento Esportivo',
            dateTime: 'July 14, 2024 - 6:00 PM',
            address: 'Avenida Principal, nº 100',
            category: 'Desporto',
            subcategory: 'Futebol',
            lastThreeAttendees: [
              'assets/user-1.png',
              'assets/user-2.png',
              'assets/user-3.png',
            ],
            description: 'Um evento esportivo para toda a família...',
          ),
          Evento(
            bannerImage: 'assets/concert.jpg',
            eventName: 'Concerto de Rock',
            dateTime: 'August 5, 2024 - 10:00 AM',
            address: 'Rua das Flores, nº 200',
            category: 'Música',
            subcategory: 'Rock',
            lastThreeAttendees: [
              'assets/user-4.png',
              'assets/user-5.png',
              'assets/user-6.png',
            ],
            description: 'Um concerto de rock imperdível...',
          ),
        ],
      ),
    ),
  );
}
