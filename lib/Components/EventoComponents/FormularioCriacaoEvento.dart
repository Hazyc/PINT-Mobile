import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../handlers/TokenHandler.dart';

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
  String? _subcategory;

  Map<String, List<String>> categoriesWithSubcategories = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      // Trate o caso em que o token não está disponível
      print('Token não encontrado');
      return;
    }

    final response = await http.get(
      Uri.parse('http://localhost:7000/areas/listarareasativas'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> areas = json.decode(response.body)['data'];
      for (var area in areas) {
        final subResponse = await http.get(
          Uri.parse(
              'http://localhost:7000/subareas/listarPorAreaAtivos/${area['ID_AREA']}'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );
        if (subResponse.statusCode == 200) {
          List<dynamic> subareas = json.decode(subResponse.body)['data'];
          List<String> subareaNames = subareas
              .map((subarea) => subarea['NOME_SUBAREA'] as String)
              .toList();
          setState(() {
            categoriesWithSubcategories[area['NOME_AREA']] = subareaNames;
          });
        }
      }
    } else {
      print('Erro ao buscar categorias');
    }
  }

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
            locale: Locale(
                'pt', 'BR'), // Configurar o seletor de hora para português
            child: child!,
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

  Future<void> _saveForm() async {
  TokenHandler tokenHandler = TokenHandler();
  final String? token =
      await tokenHandler.getToken(); // Obtenha o token de autenticação

  if (token == null) {
    // Trate o caso em que o token não está disponível
    print('Token não encontrado');
    return;
  }

  if (_formKey.currentState!.validate()) {
    _formKey.currentState!.save();

    try {
      String? imageId;
      
      // Upload da imagem do banner
      if (_image != null) {
        var uploadRequest = http.MultipartRequest(
          'POST',
          Uri.parse('http://localhost:7000/imagens/upload'),
        );
        uploadRequest.headers['Authorization'] = 'Bearer $token';

        var file = await http.MultipartFile.fromPath(
          'imagem',
          _image!.path,
        );
        uploadRequest.files.add(file);

        var uploadResponse = await uploadRequest.send();
        var uploadResponseString = await uploadResponse.stream.bytesToString();

        if (uploadResponse.statusCode == 200) {
          var jsonResponse = jsonDecode(uploadResponseString);
          imageId = jsonResponse['data']['ID_IMAGEM'];
        } else {
          _showErrorDialog('Falha ao fazer upload da imagem. Por favor, tente novamente.');
          return;
        }
      }

      // Montar o corpo da requisição para criar o evento
      final response = await http.post(
        Uri.parse('http://localhost:7000/eventos/create'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, dynamic>{
          'ID_IMAGEM': imageId,
          'CIDADE': 'Viseu',
          'NOME_SUBAREA': _subcategory ?? '',
          'TITULO_EVENTO': _eventName,
          'ALTITUDE_EVENTO': '',
          'LONGITUDE_EVENTO': '',
          'MORADA_EVENTO': _address,
          'DESCRICAO_EVENTO': _description,
          'HORA_INICIO': _dateTime!.toIso8601String(),
          'HORA_FIM': '',
        }),
      );


      if (response.statusCode == 200) {
         ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evento salvo com sucesso!'),
          backgroundColor: Colors.blue,
        ),
      );
      setState(() {
        _subcategory = '';
        _eventName = '';
        _address = '';
        _address = '';
        _description = '';
        _dateTime = null;
        _image = null;
      });

      Navigator.pop(context);
        //Navigator.of(context).pop();
      } else {
        _showErrorDialog('Falha ao criar evento. Por favor, tente novamente.');
      }
    } catch (error) {
      print('Erro: $error');
      _showErrorDialog('Ocorreu um erro. Por favor, tente novamente.');
    }
  }
}

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Erro'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Ok'),
            onPressed: () {
              Navigator.of(ctx).pop();
            },
          )
        ],
      ),
    );
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
              _subcategory = null; // Reset subcategory quando a categoria muda
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
          value: _subcategory,
          items:
              (categoriesWithSubcategories[_category] ?? []).map((subcategory) {
            return DropdownMenuItem<String>(
              value: subcategory,
              child: Text(subcategory),
            );
          }).toList(),
          onChanged: (newValue) {
            print(newValue);
            setState(() {
              _subcategory = newValue;
            });
          },
        ),
      ),
    );
  }
}