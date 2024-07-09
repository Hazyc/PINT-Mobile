import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';

class FormularioCriacaoSubForum extends StatefulWidget {
  final String category;

  FormularioCriacaoSubForum({required this.category});

  @override
  _FormularioCriacaoSubForumState createState() => _FormularioCriacaoSubForumState();
}

class _FormularioCriacaoSubForumState extends State<FormularioCriacaoSubForum> {
  final _formKey = GlobalKey<FormState>();
  String _subForumName = '';
  DateTime? _dateTime = DateTime.now();
  String _description = '';
  File? _image;
  String? _subarea;

  final Map<String, List<String>> categoriesWithSubareas = {
    'Alojamento': ['Casas', 'Apartamentos', 'Hostel'],
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

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newSubForum = {
        'nome': _subForumName,
        'imagem': _image != null ? _image!.path : 'assets/default_image.png',
        'subarea': _subarea,
        'dataCriacao': DateFormat('dd/MM/yyyy HH:mm').format(_dateTime!),
        'descricao': _description,
      };
      Navigator.of(context).pop(newSubForum);
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
                  color: Color(0xFF0DCAF0),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Criação de Sub-Fórum',
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
                          _buildTitle('Nome do Sub-Fórum'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Insira o nome do sub-fórum',
                            onSaved: (value) => _subForumName = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira o nome do sub-fórum.'
                                : null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Adicionar Imagem'),
                          SizedBox(height: 8.0),
                          _buildImagePicker('Adicionar Imagem'),
                          SizedBox(height: 16.0),
                          _buildTitle('Sub-Área'),
                          SizedBox(height: 8.0),
                          _buildSubareaDropdown(widget.category),
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
                                  Icon(Icons.create, size: 20, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Criar Sub-Fórum',
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
                      Icon(Icons.add_a_photo, size: 30, color: Colors.grey[600]),
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

  Widget _buildSubareaDropdown(String category) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Selecione uma sub-área'),
          value: _subarea,
          items: categoriesWithSubareas[category]!.map((subarea) {
            return DropdownMenuItem<String>(
              value: subarea,
              child: Text(subarea),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _subarea = newValue;
            });
          },
        ),
      ),
    );
  }
}
