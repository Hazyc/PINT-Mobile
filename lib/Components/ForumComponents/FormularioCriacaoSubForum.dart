import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../handlers/TokenHandler.dart';
import 'dart:convert';

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

  Map<String, List<String>> categoriesWithSubareas = {};
  bool isLoadingSubareas = false;

  @override
  void initState() {
    super.initState();
    _fetchCategoriesAndSubareas();
  }

  Future<void> _fetchCategoriesAndSubareas() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      // Handle the case where the token is not available
      print('Token não encontrado');
      return;
    }

    final response = await http.get(
      Uri.parse('https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> areas = json.decode(response.body)['data'];
      for (var area in areas) {
        final subResponse = await http.get(
          Uri.parse('https://backendpint-5wnf.onrender.com/subareas/listarPorAreaAtivos/${area['ID_AREA']}'),
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
            categoriesWithSubareas[area['NOME_AREA']] = subareaNames;
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

  Future<int?> _uploadImage(File imageFile) async {
  TokenHandler tokenHandler = TokenHandler();
  final String? token = await tokenHandler.getToken();

  if (token == null) {
    // Handle the case where the token is not available
    print('Token não encontrado');
    return null; // Retornando null em caso de falha na obtenção do token
  }

  try {
    final url = Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload');
    final request = http.MultipartRequest('POST', url);

    request.files.add(await http.MultipartFile.fromPath('imagem', imageFile.path));
    request.headers.addAll({
      'Authorization': 'Bearer $token',
    });

    final response = await request.send();
    if (response.statusCode == 200) {
      final decodedResponse = json.decode(await response.stream.bytesToString());
      return decodedResponse['data']['ID_IMAGEM']; // Assumindo que o ID_IMAGEM é retornado na resposta
    } else {
      print('Erro ao fazer upload da imagem: ${response.statusCode}');
      print(await response.stream.bytesToString()); // Imprime o corpo da resposta para diagnóstico
      return null;
    }
  } catch (e) {
    print('Erro ao fazer upload da imagem: $e');
    return null;
  }
}


  void _saveForm() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      // Handle the case where the token is not available
      print('Token não encontrado');
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_subForumName.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor, adicione o nome do tópico.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_subarea == null || _subarea!.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor, adicione uma subárea.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_description.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Por favor, adicione uma descrição do tópico.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      int? imageId;
      if (_image != null) {
        imageId = await _uploadImage(_image!);
        if (imageId == null) {
          // Trate o erro de upload de imagem conforme necessário
          return;
        }
      }

      // Obter a data e hora atual
      DateTime dataCriacao = DateTime.now();

      final newSubForum = {
        'TITULO_TOPICO': _subForumName,
        'ID_IMAGEM': imageId,
        'SUBAREA': _subarea ?? '', // Usando um valor padrão se _subarea for nulo
        'DESCRICAO_TOPICO': _description,
      };

      final response = await http.post(
        Uri.parse('https://backendpint-5wnf.onrender.com/topicos/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: json.encode(newSubForum),
      );

    

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body)['data'];



        // Montar o objeto responseSubForum com os dados da resposta
        final responseSubForum = {
          'TITULO_TOPICO': responseData['TITULO_TOPICO'] ?? '', // Adicione um valor padrão se 'TITULO_TOPICO' for nulo
          'IMAGEM': responseData['IMAGEM']['NOME_IMAGEM'] ?? imageId, // Utilize imageId se 'ID_IMAGEM' não estiver presente na resposta
          'SUBAREA': _subarea ?? '', // Usando um valor padrão se _subarea for nulo
          'DESCRICAO_TOPICO': responseData['DESCRICAO_TOPICO'] ?? '', // Usando um valor padrão se _description for nulo
          'DATA_CRIACAO_TOPICO': responseData['DATA_CRIACAO_TOPICO'] ?? DateTime.now(), // Usando DateTime.now() como valor padrão se dataCriacao for nulo
        };

        Navigator.of(context).pop(responseSubForum);
      } else {
        print('Erro ao criar o tópico: ${response.statusCode}');
        // Trate o erro de criação do tópico conforme necessário
      }
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
                          _buildTitle('Descrição'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Insira a descrição do sub-fórum',
                            onSaved: (value) => _description = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira a descrição do sub-fórum.'
                                : null,
                            maxLines: 5,
                          ),
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
      child: isLoadingSubareas
          ? Center(child: CircularProgressIndicator())
          : DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                hint: Text('Selecione uma sub-área'),
                value: _subarea,
                items: categoriesWithSubareas[category]?.map((subarea) {
                  return DropdownMenuItem<String?>(
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