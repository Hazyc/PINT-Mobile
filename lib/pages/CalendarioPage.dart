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
      DateTime eventDate = DateTime.parse(evento.dateTime);
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
  // Utilize a função _groupEventosPorDia para obter o mapa de eventos por dia
  Map<DateTime, List<Evento>> eventosPorDia = _groupEventosPorDia(widget.eventos);
  
  // Normaliza a data selecionada para buscar eventos
  DateTime normalizedDate = DateTime(dia.year, dia.month, dia.day);
  
  // Retorna os eventos para o dia selecionado, ou uma lista vazia se não houver eventos
  return eventosPorDia[normalizedDate] ?? [];
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text('Calendário de Eventos', style: TextStyle(color: Colors.white, fontSize: 24.0)),
      backgroundColor: const Color(0xFF0DCAF0),
      iconTheme: IconThemeData(color: Colors.white),
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
                    DateTime dateTime = DateTime.parse(evento.dateTime ?? ''); // Convertendo a String para DateTime
                    return ListTile(
                      title: Text(evento.eventName),
                      subtitle: Text(dateTime != null ? DateFormat('HH:mm').format(dateTime) : ''),
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

/*void main() {
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
      ),
    ),
  );
}*/
