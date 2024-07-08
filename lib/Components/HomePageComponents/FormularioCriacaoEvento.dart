import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../../models/Evento.dart';

class FormularioCriacaoEvento extends StatefulWidget {
  @override
  _FormularioCriacaoEventoState createState() =>
      _FormularioCriacaoEventoState();
}

class _FormularioCriacaoEventoState extends State<FormularioCriacaoEvento> {
  final _formKey = GlobalKey<FormState>();
  String _eventName = '';
  DateTime? _dateTime;
  String _description = '';
  File? _image;
  String _address = '';
  String? _category;
  String? _subcategoria;

  final Map<String, List<String>> categoriesWithSubcategories = {
    'Alojamento': ['Hotel', 'Apartamento', 'Hostel'],
    'Desporto': ['Ginásio', 'Campo de Futebol', 'Piscina'],
    'Formação': ['Curso', 'Workshop', 'Palestra'],
    'Gastronomia': ['Restaurante', 'Café', 'Bar'],
    'Lazer': ['Parque', 'Cinema', 'Museu'],
    'Saúde': ['Hospital', 'Clínica', 'Veterinário'],
    'Transportes': ['Ônibus', 'Táxi', 'Metrô'],
  };

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: Locale('pt', 'BR'), // Configurar o calendário para português
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
        builder: (BuildContext context, Widget? child) {
          return Localizations.override(
            context: context,
            locale: Locale('pt', 'BR'), // Configurar o seletor de hora para português
            child: child,
          );
        },
      );
      if (pickedTime != null) {
        final pickedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        setState(() {
          _dateTime = pickedDateTime;
        });
      }
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newEvent = Evento(
        bannerImage: _image!.path,
        eventName: _eventName,
        dateTime: DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(_dateTime!),
        address: _address,
        category: _category!,
        subcategory: _subcategoria!,
        lastThreeAttendees: [],
        description: _description,
      );
      // Aqui você pode adicionar lógica para salvar o evento
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/vetor_invertido.png',
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height * 0.2,
            ),
          ),
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                    top: 32.0, bottom: 8.0, left: 16.0, right: 16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon:
                          Icon(Icons.arrow_back, size: 30, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Criação de Evento',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 16.0),
                          _buildTitle('Nome do Evento'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Insira o nome do evento',
                            onSaved: (value) => _eventName = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira o nome do evento.'
                                : null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Adicionar Banner'),
                          SizedBox(height: 8.0),
                          _buildImagePicker('Adicionar Banner'),
                          SizedBox(height: 16.0),
                          _buildTitle('Detalhes do Evento'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Insira os detalhes do evento',
                            maxLines: 3,
                            onSaved: (value) => _description = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira os detalhes do evento.'
                                : null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Localização'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Insira a localização do evento',
                            onSaved: (value) => _address = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira a localização do evento.'
                                : null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Data e Hora do Evento'),
                          SizedBox(height: 8.0),
                          _buildDateTimePicker(
                              'Insira a data e hora', _dateTime, _pickDateTime),
                          SizedBox(height: 16.0),
                          _buildTitle('Categoria'),
                          SizedBox(height: 8.0),
                          _buildCategoryDropdown(),
                          if (_category != null) ...[
                            SizedBox(height: 16.0),
                            _buildTitle('Subcategoria'),
                            SizedBox(height: 8.0),
                            _buildSubcategoryDropdown(),
                          ],
                          SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: ElevatedButton(
                              onPressed: _saveForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.create,
                                      size: 20, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Criar Evento',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        maxLines: maxLines,
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  Widget _buildImagePicker(String label) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: () => _pickImage(ImageSource.gallery),
        child: Container(
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: _image == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo,
                          size: 30, color: Colors.grey[600]),
                      SizedBox(height: 8),
                      Text(label),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.file(
                      _image!,
                      height: 150,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker(
      String hintText, DateTime? dateTime, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: onTap,
        child: AbsorbPointer(
          child: TextFormField(
            decoration: InputDecoration(
              hintText: hintText,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(10),
              ),
              filled: true,
              fillColor: Colors.grey[200],
              suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
            ),
            controller: TextEditingController(
              text: dateTime == null
                  ? ''
                  : DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(dateTime),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Selecione uma categoria'),
          value: _category,
          items: categoriesWithSubcategories.keys.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _category = newValue;
              _subcategoria = null; // Reset subcategory when category changes
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryDropdown() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Selecione uma subcategoria'),
          value: _subcategoria,
          items: (categoriesWithSubcategories[_category] ?? []).map((subcategory) {
            return DropdownMenuItem<String>(
              value: subcategory,
              child: Text(subcategory),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _subcategoria = newValue;
            });
          },
        ),
      ),
    );
  }
}
