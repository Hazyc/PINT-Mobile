import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app_mobile/models/Evento.dart';
import '../../handlers/TokenHandler.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/Campo.dart';

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
  late DateTime? _selectedDateTime;
  late TextEditingController _dateTimeController;
  late String _address;
  late String _selectedCategory;
  late String _selectedSubcategory;
  late String _bannerImage;
  late int _bannerID;

  //formulario
  late bool ativoformulario;
  late String _nomeFormulario;
  List<Campo> _campos = []; //lista de campos do formulario que já existem
  bool _existeFormulatio = false;
  late TextEditingController _nomeFormularioController;
  Map<int, TextEditingController> _controladores =
      {}; //vai ser usado para os campos do formulario
  int id_formulario = 0;

  Map<String, List<String>> categoriesWithSubcategories = {};
  List<String> _categories = [];
  List<String> _subcategories = [];
  List<Map<String, String>> _albumImages =
      []; // Mantenha apenas esta declaração

  @override
  void initState() {
    super.initState();
    //parte do formulario
    _nomeFormularioController = TextEditingController();
    _title = widget.evento.eventName;
    _description = widget.evento.description;
    _selectedDateTime = DateTime.parse(widget.evento.dateTime);
    _dateTimeController = TextEditingController(
      text: DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!),
    );
    _address = widget.evento.address;
    _selectedCategory = widget.evento.category;
    _selectedSubcategory = widget.evento.subcategory;
    _bannerImage = widget.evento.bannerImage;
    _bannerID = widget.evento.bannerID;
    print('Banner ID: ${widget.evento.bannerID}');
    _fetchCategories();
    _fetchAlbumImages();
    _fetchformulario();
  }

  @override
  void dispose() {
    _dateTimeController.dispose();
    _controladores.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  int _proximoId = 0;

  void _adicionarCampo(String tipo) {
    setState(() {
      final controller = TextEditingController();
      _controladores[_proximoId] = controller;
      //parte de criaçao de um controller para cada campo

      _campos.add(Campo(
        id_campo: _proximoId++,
        nome_campo: '',
        tipo_campo: tipo,
        required_campo: false,
        novo: true,
      ));
    });
  }

  void _removerCampo(int id) async {
    final token = await TokenHandler().getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado')),
      );
      return;
    }

    if (_campos.any((campo) => campo.id_campo == id && campo.novo)) {
      setState(() {
        _campos.removeWhere((campo) => campo.id_campo == id);
        _controladores.remove(id);
      });
    } else if (_campos.any((campo) => campo.id_campo == id && !campo.novo)) {
      try {
        final response = await http.delete(
          Uri.parse('https://backendpint-5wnf.onrender.com/campo/delete/$id'),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (response.statusCode == 200) {
          setState(() {
            _campos.removeWhere((campo) => campo.id_campo == id);
            _controladores.remove(id);
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Erro ao remover campo: ${response.reasonPhrase}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao remover campo: ${e.toString()}')),
        );
      }
    }
  }

  void _atualizarCampo(
      int id, String tipo, String nome, bool required, bool newCampo) async {
    print("atualizando campo");
    setState(() {
      _campos.forEach((element) {
        if (element.id_campo == id && element.novo == newCampo) {
          element.tipo_campo = tipo;
          element.nome_campo = nome;
          element.required_campo = required;
          print('Campo atualizado');
        }
      });
    });
  }

  Future<void> _selectDateTime() async {
    DateTime currentDateTime = _selectedDateTime ?? DateTime.now();

    // Ajusta a data mínima para a data atual ou a data selecionada
    DateTime initialDate = currentDateTime.isBefore(DateTime.now())
        ? DateTime.now()
        : currentDateTime;

    // Seleção de Data
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime.now(), // Configura a data mínima para hoje
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      // Define a hora inicial como a hora atual
      TimeOfDay initialTime = TimeOfDay.now();

      // Seleção de Hora
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        // Cria o DateTime com a data e hora selecionadas
        DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (selectedDateTime.isBefore(DateTime.now())) {
          // Se a data e hora selecionadas forem anteriores à data e hora atuais, exibe uma mensagem de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'A data e hora selecionadas não podem ser anteriores ao momento atual.',
              ),
            ),
          );
        } else {
          setState(() {
            _selectedDateTime = selectedDateTime;
            _dateTimeController.text =
                DateFormat('dd/MM/yyyy HH:mm').format(_selectedDateTime!);
          });
        }
      }
    }
  }

  Future<void> _fetchformulario() async {
    final token = await TokenHandler().getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/formulario/getByIdEvento/${widget.evento.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      print(response.body);

      if (response.statusCode == 200 &&
          json.decode(response.body)['success'] == true) {
        setState(() {
          _nomeFormulario =
              json.decode(response.body)['data']['TITULO_FORMULARIO'] ?? '';
          id_formulario = json.decode(response.body)['data']['ID_FORMULARIO'];
          _existeFormulatio = true;
          ativoformulario =
              json.decode(response.body)['data']['ESTADO_FORMULARIO'];
        });

        try {
          final resposta = await http.get(
            Uri.parse(
                'https://backendpint-5wnf.onrender.com/campo/getByIdFormulario/${json.decode(response.body)['data']['ID_FORMULARIO']}'),
            headers: {'Authorization': 'Bearer $token'},
          );
          if (resposta.statusCode == 200) {
            setState(() {
              List<dynamic> campos = json.decode(resposta.body)['data'];
              _campos = campos.map((campo) => Campo.fromJson(campo)).toList();

              _campos.forEach((campo) {
                _controladores[campo.id_campo] =
                    TextEditingController(text: campo.nome_campo);
                campo.novo = false;
              });
            });
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao buscar campos: ${e.toString()}')),
          );
        }
      } else if (json.decode(response.body)['success'] == false) {
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao buscar formulário: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar formulário: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchCategories() async {
    final token = await TokenHandler().getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        List<dynamic> areas = json.decode(response.body)['data'];
        Map<String, List<String>> tempCategoriesWithSubcategories = {};

        for (var area in areas) {
          final subResponse = await http.get(
            Uri.parse(
                'https://backendpint-5wnf.onrender.com/subareas/listarPorAreaAtivos/${area['ID_AREA']}'),
            headers: {'Authorization': 'Bearer $token'},
          );

          if (subResponse.statusCode == 200) {
            List<dynamic> subareas = json.decode(subResponse.body)['data'];
            List<String> subareaNames = subareas
                .map((subarea) => subarea['NOME_SUBAREA'] as String)
                .toList();

            tempCategoriesWithSubcategories[area['NOME_AREA']] = subareaNames;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Erro ao buscar subcategorias para ${area['NOME_AREA']}: ${subResponse.reasonPhrase}')),
            );
          }
        }

        setState(() {
          categoriesWithSubcategories = tempCategoriesWithSubcategories;
          _categories = categoriesWithSubcategories.keys.toList();
          _subcategories = categoriesWithSubcategories[_selectedCategory] ?? [];
          _selectedSubcategory =
              _subcategories.contains(widget.evento.subcategory)
                  ? widget.evento.subcategory
                  : (_subcategories.isNotEmpty ? _subcategories[0] : '');
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Erro ao buscar categorias: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao buscar categorias: ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchAlbumImages() async {
    final token = await TokenHandler().getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/imagens/listarfotosalbumvisivel?ID_ALBUM=${widget.evento.albumID}'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> images = json.decode(response.body)['data'];
        setState(() {
          _albumImages = images
              .map((image) => {
                    'ID_IMAGEM': image['ID_IMAGEM']
                        .toString(), // Convertendo para String
                    'NOME_IMAGEM': image['NOME_IMAGEM']
                        as String, // Garantindo que é uma String
                  })
              .toList();
        });

        // Imprimir o ID de cada imagem no terminal
        for (var image in images) {
          print('ID da Imagem: ${image['ID_IMAGEM']}');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao buscar imagens do álbum: ${response.reasonPhrase}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Erro ao buscar imagens do álbum: ${e.toString()}')),
      );
    }
  }

  Future<void> _hideImage(String imageId) async {
    final token = await TokenHandler().getToken();

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token não encontrado')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/imagens/esconderImagem/$imageId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          _albumImages.removeWhere((image) => image['ID_IMAGEM'] == imageId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Imagem ocultada com sucesso!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao ocultar a imagem.')),
        );
      }
    } catch (error) {
      print('Erro ao ocultar imagem: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao ocultar imagem.')),
      );
    }
  }

  void _updateSubcategories(String category) {
    setState(() {
      _selectedCategory = category;
      _subcategories = categoriesWithSubcategories[category] ?? [];
      _selectedSubcategory = _subcategories.isNotEmpty ? _subcategories[0] : '';
    });
  }

  Future<void> _uploadBanner() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload'),
      );
      request.headers['Authorization'] = 'Bearer $token';

      request.files
          .add(await http.MultipartFile.fromPath('imagem', pickedFile.path));

      try {
        final response = await request.send();
        final responseData = await http.Response.fromStream(response);

        if (response.statusCode == 200) {
          final data = json.decode(responseData.body);

          if (data != null && data['data'] != null) {
            setState(() {
              _bannerID =
                  int.tryParse(data['data']['ID_IMAGEM'].toString()) ?? 0;
              _bannerImage = data['data']['NOME_IMAGEM'];
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Imagem do banner carregada com sucesso!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Erro: URL da imagem não encontrada na resposta.')),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'Erro ao fazer upload da imagem. Código ${response.statusCode}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao fazer upload da imagem: $error')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nenhuma imagem selecionada.')),
      );
    }
  }

  //falta alterar aqui para dar update ao formulario
  Future<void> _updateEvent() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save(); // Salva os valores dos campos

      try {
        final token = await TokenHandler().getToken();
        if (token == null || token.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Token de autenticação não encontrado.')),
          );
          return;
        }

        // Construa o corpo da solicitação com base na presença de _bannerID
        final Map<String, dynamic> body = {
          'TITULO_EVENTO': _title,
          'DESCRICAO_EVENTO': _description,
          'HORA_INICIO': _selectedDateTime!.toUtc().toIso8601String(),
          'MORADA_EVENTO': _address,
          'NOME_SUBAREA': _selectedSubcategory,
          'ID_IMAGEM': _bannerID,
        };

        print(
            'Corpo da requisição para atualizar o evento: ${jsonEncode(body)}');

        final uri = Uri.parse(
          'https://backendpint-5wnf.onrender.com/eventos/update/${widget.evento.id}',
        );

        final response = await http.put(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(body),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Evento atualizado com sucesso!')),
          );

          if (_existeFormulatio) {
            print(
                "FORMULARIO EXISTE------------------------------------------------------------------------------");
            print(_nomeFormulario);
            final corpo = {
              'TITULO_FORMULARIO': _nomeFormulario,
              'ESTADO_FORMULARIO': ativoformulario,
            };

            try {
              final repsosta = await http.put(
                  Uri.parse(
                      "https://backendpint-5wnf.onrender.com/formulario/update/${id_formulario}"),
                  headers: {
                    'Content-Type': 'application/json',
                    'Authorization': 'Bearer $token',
                  },
                  body: jsonEncode(corpo));

              if (repsosta.statusCode == 200) {
                print('Formulario atualizado com sucesso!');
                print(repsosta.body);
                print(
                    _campos[0].nome_campo); //está a dar print ao primeiro campo
                _campos.forEach((campo) async {
                  if (campo.novo) {
                    final corpo = {
                      'ID_FORMULARIO': id_formulario,
                      'TIPO_CAMPO': campo.tipo_campo,
                      'LABEL_CAMPO': campo.nome_campo,
                      'REQUIRED_CAMPO': campo.required_campo,
                    };
                    try {
                      final camponovoresposta = await http.post(
                          Uri.parse(
                              "https://backendpint-5wnf.onrender.com/campo/create"),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token',
                          },
                          body: jsonEncode(corpo));
                      if (camponovoresposta.statusCode == 201) {
                      } else {}
                    } catch (e) {
                      print('Erro ao adicionar campo novo: $e');
                    }
                  } else {
                    final corpo = {
                      'TIPO_CAMPO': campo.tipo_campo,
                      'LABEL_CAMPO': campo.nome_campo,
                      'REQUIRED_CAMPO': campo.required_campo,
                    };
                    try {
                      final campoeditresposta = await http.put(
                          Uri.parse(
                              "https://backendpint-5wnf.onrender.com/campo/update/${campo.id_campo}"),
                          headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer $token',
                          },
                          body: jsonEncode(corpo));
                      if (campoeditresposta.statusCode == 200) {
                        print("Campo editado com sucesso");
                        print(campoeditresposta.body);
                      } else {}
                    } catch (e) {
                      print('Erro ao atualizar campo antigo: $e');
                    }
                  }
                });
              } else {
                print('Erro ao atualizar formulario');
              }
            } catch (e) {
              print('Erro ao atualizar formulario: $e');
            }
          }

          Navigator.of(context).pop(); // Volta para a tela anterior
        } else {
          print("Erro ao atualizar evento: ${response.reasonPhrase}");
        }
      } catch (error) {
        print('Erro ao atualizar evento: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar evento.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DCAF0),
        centerTitle: true,
        title: Text(
          'Edição de Evento',
          style: TextStyle(
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
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
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 16.0),
                          _buildBanner(),
                          SizedBox(height: 16.0),
                          _buildTitle('Nome do Evento'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            initialValue: _title,
                            hintText: 'Insira o nome do evento',
                            onSaved: (value) => _title = value!,
                            validator: (value) => value == null || value.isEmpty
                                ? 'Por favor insira o nome do evento.'
                                : null,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Detalhes do Evento'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            initialValue: _description,
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
                            initialValue: _address,
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
                            'Insira a data e hora',
                            _dateTimeController.text,
                            _selectDateTime,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Categoria'),
                          SizedBox(height: 8.0),
                          _buildCategoryDropdown(),
                          if (_selectedCategory.isNotEmpty) ...[
                            SizedBox(height: 16.0),
                            _buildTitle('Subcategoria'),
                            SizedBox(height: 8.0),
                            _buildSubcategoryDropdown(),
                          ],
                          SizedBox(height: 16.0),
                          _buildTitle('Álbum de Imagens'),
                          SizedBox(height: 8.0),
                          _buildAlbumImages(),
                          SizedBox(height: 16.0),
                          if (_existeFormulatio) _buildFormulario(),
                          SizedBox(height: 16.0),
                          Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: ElevatedButton(
                              onPressed: _updateEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.save,
                                      size: 20, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Guardar as Alterações',
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

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GestureDetector(
        onTap: _uploadBanner, // Função para selecionar o banner
        child: Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: _bannerImage.isEmpty
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_photo_alternate,
                          size: 30, color: Colors.grey[600]),
                      SizedBox(height: 8),
                      Text('Alterar Banner',
                          style: TextStyle(color: Colors.grey[600])),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      _bannerImage,
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit
                          .cover, // Garante que a imagem cubra toda a área do Container
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumImages() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _albumImages.map((imageData) {
        return ListTile(
          leading: Image.network(
            imageData['NOME_IMAGEM']!,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
          title: Text('Imagem'),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _hideImage(imageData['ID_IMAGEM']!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
    String? initialValue,
  }) {
    return TextFormField(
      initialValue: initialValue,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget _buildDateTimePicker(
      String label, String dateTime, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AbsorbPointer(
        child: TextFormField(
          controller: _dateTimeController,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          ),
          validator: (value) => value == null || value.isEmpty
              ? 'Por favor selecione a data e hora.'
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      items: _categories.map((category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (newValue) {
        _updateSubcategories(newValue!);
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget _buildSubcategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedSubcategory,
      items: _subcategories.map((subcategory) {
        return DropdownMenuItem<String>(
          value: subcategory,
          child: Text(subcategory),
        );
      }).toList(),
      onChanged: (newValue) {
        setState(() {
          _selectedSubcategory = newValue!;
        });
      },
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      ),
    );
  }

  Widget _buildFormulario() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nome do Formulário: $_nomeFormulario',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _nomeFormularioController,
            decoration: InputDecoration(
              labelText: 'Nome do Formulário',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() {
                _nomeFormulario = value;
              });
            },
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _adicionarCampo("checkbox");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Adicionar Checkbox',
                style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 10),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _adicionarCampo("contagem");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text('Adicionar Contagem',
                style: TextStyle(color: Colors.white)),
          ),
          Column(
            children: _campos.map((campo) => _buildCampo(campo)).toList(),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              setState(() {
                ativoformulario = !ativoformulario;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: ativoformulario
                ? Text(
                    'Desativar Formulário',
                    style: TextStyle(color: Colors.white),
                  )
                : Text(
                    'Ativar Formulário',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampo(Campo campo) {
    // Verifique se o controlador já existe no mapa _controladores
    final controller = _controladores[campo.id_campo] ??
        TextEditingController(text: campo.nome_campo);

    // Se o controlador já existir, garanta que o texto inicial não seja reconfigurado desnecessariamente
    if (!_controladores.containsKey(campo.id_campo)) {
      _controladores[campo.id_campo] = controller;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Campo de ${campo.tipo_campo}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              SizedBox(width: 10),
              IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  // Remove o campo e limpa o controlador associado
                  setState(() {
                    _removerCampo(campo.id_campo);
                    _controladores.remove(campo.id_campo);
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Nome do Campo',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // Atualiza o campo quando o valor do TextField mudar
              _atualizarCampo(
                  campo.id_campo,
                  campo.tipo_campo,
                  value, // O valor atualizado do TextField
                  campo.required_campo,
                  campo.novo);
            },
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Obrigatório:',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              Checkbox(
                value: campo.required_campo,
                onChanged: (bool? newValue) {
                  _atualizarCampo(campo.id_campo, campo.tipo_campo,
                      campo.nome_campo, newValue!, campo.novo);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
