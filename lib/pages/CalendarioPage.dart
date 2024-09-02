import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/Evento.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'EventoView.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';

class CalendarioPage extends StatefulWidget {
  @override
  _CalendarioPageState createState() => _CalendarioPageState();
}

class _CalendarioPageState extends State<CalendarioPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  Map<DateTime, List<Evento>> _eventosPorDia = {};
  List<Evento> _eventos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEventos();
  }

  Future<void> _fetchEventos() async {
  TokenHandler tokenHandler = TokenHandler();
  try {
    final token = await tokenHandler.getToken();
    if (token == null) {
      _showError('Token is null. Please log in again.');
      return;
    }

    final response = await http.get(
      Uri.parse('https://backendpint-5wnf.onrender.com/listaparticipantes/getEventosByUtilizador'),
      headers: {'x-access-token': 'Bearer $token'},
    );
    print(response.body);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Verifica se a resposta contém dados e se a lista de eventos é válida
      if (data['success'] == true && data['data'] is List) {
        setState(() {
          _eventos = (data['data'] as List)
              .map((item) => Evento.fromJson(item['EVENTO']))
              .toList();
          _groupEventosPorDia();
          _isLoading = false;
        });
      } else if (data['success'] == true && data['data'] == null) {
        // Caso a lista de eventos seja nula, apenas defina _isLoading como falso
        setState(() {
          _eventos = [];
          _eventosPorDia = {};
          _isLoading = false;
        });
      } else {
        _showError('Failed to load events.');
      }
    } else {
      _showError('Failed to load events.');
    }
  } catch (e) {
    _showError('An error occurred: $e');
  }
}

  void _groupEventosPorDia() {
    Map<DateTime, List<Evento>> dataMap = {};
    for (var evento in _eventos) {
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

    setState(() {
      _eventosPorDia = dataMap;
    });
  }

  List<Evento> _getEventosParaDia(DateTime dia) {
    DateTime normalizedDate = DateTime(dia.year, dia.month, dia.day);
    return _eventosPorDia[normalizedDate] ?? [];
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendário de Eventos'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                            DateTime dateTime = DateTime.parse(evento.dateTime);
                            return ListTile(
                              leading: Image.network(
                                evento.bannerImage,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                              title: Text(evento.eventName),
                              subtitle: Text(
                                '${DateFormat('HH:mm').format(dateTime)} - ${evento.address} - ${evento.category}',
                              ),
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
