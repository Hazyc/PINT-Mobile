import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../../handlers/TokenHandler.dart';
import '../../pages/MapPage.dart';
import '../../models/Campo.dart';

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
  String _city = 'Viseu'; // exemplo de cidade fixa
  String? _category;
  String? _subcategory;

  //dados de formulario

  String _nomeFormulario = ''; //TITULO_FORMULARIO
  List<Campo> campos = []; //CAMPOS
  bool _mostrarFormulario = false;
  late TextEditingController _nomeFormularioController;

  TextEditingController _locationController = TextEditingController();

  Map<String, List<String>> categoriesWithSubcategories = {};
  final Map<int, TextEditingController> _controladores = {};

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    _locationController.text = _address;
    _nomeFormularioController = TextEditingController(text: _nomeFormulario);
  }

  void dispose() {
    // Dispose todos os controladores quando o widget for descartado
    _controladores.values.forEach((controller) => controller.dispose());
    _nomeFormularioController.dispose();
    super.dispose();
  }

  //parte dos campos do formulario
  int _proximoId = 0;

  void _clearFormFields() {
    setState(() {
      _category = null;
      _subcategory = null;
      _eventName = '';
      _address = '';
      _description = '';
      _dateTime = null;
      _image = null;
    });
  }

  void _adicionarCampo(String tipo) {
    setState(() {
      final controller = TextEditingController();
      _controladores[_proximoId] = controller;

      campos.add(Campo(
          id_campo: _proximoId++,
          tipo_campo: tipo,
          nome_campo: '',
          required_campo: false));
      _proximoId++;
    });
  }

  void _removerCampo(int id) {
    setState(() {
      _controladores.remove(id)?.dispose();
      campos.removeWhere((element) => element.id_campo == id);
    });
  }

  void _atualizarCampo(int id, String tipo, String nome, bool required) {
    setState(() {
      campos.forEach((element) {
        if (element.id_campo == id) {
          element.tipo_campo = tipo;
          element.nome_campo = nome;
          element.required_campo = required;
          print('Campo atualizado');
        }
      });
    });
  }

  void _criarFormulario() {
    setState(() {
      _mostrarFormulario = !_mostrarFormulario;
      campos = [];
      _controladores.values.forEach((controller) => controller.dispose());
      _controladores.clear();
      _nomeFormularioController.text = '';
      _proximoId = 0;
    });
  }

  void _cancelarFormulario() {
    setState(() {
      _controladores.values.forEach((controller) => controller.dispose());
      _controladores.clear();
      _mostrarFormulario = !_mostrarFormulario;
      campos = [];
      _proximoId = 0;
      _nomeFormularioController.text = '';
    });
  }

  Future<void> _fetchCategories() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final response = await http.get(
      Uri.parse(
          'https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List<dynamic> areas = json.decode(response.body)['data'];
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
    DateTime now = DateTime.now();
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(2101),
      locale: Locale('pt', 'BR'),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(now),
        builder: (BuildContext context, Widget? child) {
          return Localizations.override(
            context: context,
            locale: Locale('pt', 'BR'),
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

        if (pickedDateTime.isBefore(now)) {
          _showErrorDialog('A data e hora selecionadas devem ser futuras.');
          return;
        }

        setState(() {
          _dateTime = pickedDateTime;
        });
      }
    }
  }

  Future<void> _saveForm() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        int? imageId;

        if (_image != null) {
          var uploadRequest = http.MultipartRequest(
            'POST',
            Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload'),
          );
          uploadRequest.headers['Authorization'] = 'Bearer $token';

          var file = await http.MultipartFile.fromPath('imagem', _image!.path);
          uploadRequest.files.add(file);

          var uploadResponse = await uploadRequest.send();
          var uploadResponseString =
              await uploadResponse.stream.bytesToString();

          if (uploadResponse.statusCode == 200) {
            var jsonResponse = jsonDecode(uploadResponseString);
            imageId = int.parse(jsonResponse['data']['ID_IMAGEM']);
          } else {
            _showErrorDialog(
                'Falha ao fazer upload da imagem. Por favor, tente novamente.');
            return;
          }
        }

        final response = await http.post(
          Uri.parse('https://backendpint-5wnf.onrender.com/eventos/create'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(<String, dynamic>{
            'ID_IMAGEM': imageId,
            'CIDADE': _city,
            'NOME_SUBAREA': _subcategory ?? '',
            'TITULO_EVENTO': _eventName,
            'MORADA_EVENTO': _address,
            'DESCRICAO_EVENTO': _description,
            'HORA_INICIO': _dateTime?.toIso8601String(),
            'HORA_FIM': null,
          }),
        );

        print(imageId);
        print(_city);
        print(_subcategory);
        print(_eventName);
        print(_address);
        print(_description);

        if (response.statusCode == 200) {
          print('Evento criado com sucesso');
          print(response.body);

          if (_mostrarFormulario) {
            try {
              final resposta = await http.post(
                Uri.parse(
                    'https://backendpint-5wnf.onrender.com/formulario/create'),
                headers: <String, String>{
                  'Content-Type': 'application/json; charset=UTF-8',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode(<String, dynamic>{
                  'TITULO_FORMULARIO': _nomeFormulario,
                  'ID_EVENTO': jsonDecode(response.body)['data']['ID_EVENTO'],
                }),
              );
              print("ola");
              if (resposta.statusCode == 201) {
                print('Formulário criado com sucesso');

                for (var campo in campos) {
                  print('Criando campo: ${campo}');
                  final respostaCampo = await http.post(
                    Uri.parse(
                        'https://backendpint-5wnf.onrender.com/campo/create'),
                    headers: <String, String>{
                      'Content-Type': 'application/json; charset=UTF-8',
                      'Authorization': 'Bearer $token',
                    },
                    body: jsonEncode(<String, dynamic>{
                      'ID_FORMULARIO': jsonDecode(resposta.body)['data']
                          ['ID_FORMULARIO'],
                      'TIPO_CAMPO': campo.tipo_campo,
                      'LABEL_CAMPO': campo.nome_campo,
                      'REQUIRED_CAMPO': campo.required_campo,
                    }),
                  );
                  if (respostaCampo.statusCode == 201) {
                    print('Campo criado com sucesso');
                  } else {
                    print('Erro ao criar campo');
                    _showErrorDialog(
                        'Ocorreu um erro. Por favor, tente novamente.');
                  }
                }
              } else {
                print('Erro ao criar formulário');
                _clearFormFields();
                _showErrorDialog(
                    'Ocorreu um erro. Por favor, tente novamente.');
              }
            } catch (error) {
              print("Erro ao criar formulário:");

              _clearFormFields();

              print('Erro: $error');
              _showErrorDialog('Ocorreu um erro. Por favor, tente novamente.');
            }
          }

          _clearFormFields();

          Navigator.pop(context);
        } else {
          _showErrorDialog(
              'Falha ao criar evento. Por favor, tente novamente.');
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

  void _openMapPage() async {
    final selectedAddress = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapPage(
          initialAddress: _address,
          onAddressSelected: (address) {
            setState(() {
              _address =
                  address; // Atualiza o campo de localização com o endereço selecionado
            });
            Navigator.pop(context, address); // Retorna o endereço selecionado
          },
        ),
      ),
    );

    if (selectedAddress != null) {
      setState(() {
        _address = selectedAddress; // Confirma a atualização do estado
      });
    }
  }

  Widget _buildLocationField() {
    return _buildTextField(
      hintText: 'Insira a localização do evento',
      onSaved: (value) => _address = value!,
      validator: (value) => value == null || value.isEmpty
          ? 'Por favor insira a localização do evento.'
          : null,
      suffixIcon: IconButton(
        icon: Icon(Icons.map, color: Colors.grey[600]),
        onPressed: () async {
          _openMapPage(); // Abre a página do mapa
        },
      ),
      controller: _locationController, // Usa o controlador definido na classe
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DCAF0),
        centerTitle: true,
        title: Text(
          'Criação de Evento',
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
                          _buildLocationField(),
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
                          if (_mostrarFormulario == false)
                            Container(
                              child: ElevatedButton(
                                onPressed: _criarFormulario,
                                child: Text('Criar Formulário'),
                              ),
                            ),
                          if (_mostrarFormulario == true)
                            Container(
                              child: ElevatedButton(
                                onPressed: _cancelarFormulario,
                                child: Text('Cancelar Formulário'),
                              ),
                            ),
                          SizedBox(height: 16.0),
                          if (_mostrarFormulario) _buildFormulario(),
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

  //campo de formulario

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
            child: Text('Adicionar Checkbox'),
          ),
          SizedBox(height: 10),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              _adicionarCampo("contagem");
            },
            child: Text('Adicionar Contagem'),
          ),
          Column(
            children: campos.map((campo) => _buildCampo(campo)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCampo(Campo campo) {
    // Certifique-se de criar um novo controlador somente quando o campo for criado
    // e não o recrie a cada reconstrução do widget.
    final controller = _controladores[campo.id_campo] ??
        TextEditingController(text: campo.nome_campo);

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
              _atualizarCampo(campo.id_campo, campo.tipo_campo, value,
                  campo.required_campo);
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
                      campo.nome_campo, newValue ?? false);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String hintText,
    required FormFieldSetter<String> onSaved,
    required FormFieldValidator<String> validator,
    int maxLines = 1,
    Widget? suffixIcon,
    TextEditingController? controller, // Adicione este parâmetro
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller, // E adicione aqui também
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          suffixIcon: suffixIcon,
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
          value: categoriesWithSubcategories.containsKey(_category)
              ? _category
              : null,
          isExpanded: true, // Adiciona flexibilidade ao dropdown
          items: categoriesWithSubcategories.keys.map((category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _category = newValue; // Define a nova categoria
              _subcategory = null; // Reseta a subcategoria
            });
          },
        ),
      ),
    );
  }

  Widget _buildSubcategoryDropdown() {
    final subcategories =
        _category != null ? categoriesWithSubcategories[_category] : [];

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
          value: subcategories!.contains(_subcategory) ? _subcategory : null,
          isExpanded: true, // Adiciona flexibilidade ao dropdown
          items: subcategories!.map((subcategory) {
            return DropdownMenuItem<String>(
              value: subcategory,
              child: Text(subcategory),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _subcategory = newValue; // Define a nova subcategoria
            });
          },
        ),
      ),
    );
  }
}
