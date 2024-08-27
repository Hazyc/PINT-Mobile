import 'package:flutter/material.dart';
import 'package:app_mobile/models/Evento.dart';

class EditEventoPage extends StatefulWidget {
  final Evento evento;

  EditEventoPage({required this.evento});

  @override
  _EditEventoPageState createState() => _EditEventoPageState();
}

class _EditEventoPageState extends State<EditEventoPage> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late String _dateTime;
  late String _address;
  late String _category;
  late String _subcategory;

  @override
  void initState() {
    super.initState();
    _title = widget.evento.eventName;
    _description = widget.evento.description;
    _dateTime = widget.evento.dateTime;
    _address = widget.evento.address;
    _category = widget.evento.category;
    _subcategory = widget.evento.subcategory;
  }

  Future<void> _updateEvent() async {
    // Implementar a lógica de atualização do evento aqui
    // Enviar uma solicitação HTTP para atualizar o evento no backend
    print('Evento atualizado!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Evento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                initialValue: _title,
                decoration: InputDecoration(labelText: 'Título'),
                onSaved: (value) => _title = value!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Descrição'),
                onSaved: (value) => _description = value!,
              ),
              TextFormField(
                initialValue: _dateTime,
                decoration: InputDecoration(labelText: 'Data e Hora'),
                onSaved: (value) => _dateTime = value!,
              ),
              TextFormField(
                initialValue: _address,
                decoration: InputDecoration(labelText: 'Local'),
                onSaved: (value) => _address = value!,
              ),
              TextFormField(
                initialValue: _category,
                decoration: InputDecoration(labelText: 'Categoria'),
                onSaved: (value) => _category = value!,
              ),
              TextFormField(
                initialValue: _subcategory,
                decoration: InputDecoration(labelText: 'Subcategoria'),
                onSaved: (value) => _subcategory = value!,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _formKey.currentState?.save();
                  _updateEvent();
                },
                child: Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
