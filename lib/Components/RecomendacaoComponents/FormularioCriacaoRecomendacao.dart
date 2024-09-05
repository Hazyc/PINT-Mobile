import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../LoginPageComponents/Botao.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../handlers/TokenHandler.dart';

class FormularioCriacaoRecomendacao extends StatefulWidget {
  @override
  _FormularioCriacaoRecomendacaoState createState() => _FormularioCriacaoRecomendacaoState();
}

class _FormularioCriacaoRecomendacaoState extends State<FormularioCriacaoRecomendacao> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _addressController = TextEditingController(); // Controlador para a morada
  Map<String, List<String>> areaParameters = {};
  double _serviceRating = 0;
  double _cleanlinessRating = 0;
  double _valueRating = 0;
  List<String> _images = [];
  File? _bannerImage;
  bool _isLoading = false;
  String? _selectedTag;
  String? _selectedSubarea;

  Map<String, List<String>> subareas = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAreasAndSubareas();
  }

  Future<void> fetchAreasAndSubareas() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    final areasResponse = await http.get(
      Uri.parse('https://backendpint-5wnf.onrender.com/areas/listarareasativas'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (areasResponse.statusCode == 200) {
      final List<dynamic> areasData = jsonDecode(areasResponse.body)['data'];
      Map<String, List<String>> tempAreaParameters = {};

      for (var area in areasData) {
        final areaName = area['NOME_AREA'];
        final areaId = area['ID_AREA'];
        List<String> parameters = [
          area['PARAMETRO_AVALIACAO_1'],
          area['PARAMETRO_AVALIACAO_2'],
          area['PARAMETRO_AVALIACAO_3']
        ];
        tempAreaParameters[areaName] = parameters;

        final subareasResponse = await http.get(
          Uri.parse('https://backendpint-5wnf.onrender.com/subareas/listarPorAreaAtivos/$areaId'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (subareasResponse.statusCode == 200) {
          final List<dynamic> subareasData = jsonDecode(subareasResponse.body)['data'];
          List<String> subareaNames = subareasData
              .map((subarea) => subarea['NOME_SUBAREA'].toString())
              .toList();

          setState(() {
            areaParameters = tempAreaParameters;
            subareas[areaName] = subareaNames;
          });
        }
      }
    } else {
      throw Exception('Failed to load areas');
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isLoading = true;
    });

    final ImagePicker _picker = ImagePicker();
    final List<XFile>? pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _images = pickedFiles.map((pickedFile) => pickedFile.path).toList();
      });

      for (var path in _images) {
        print('Picked image: $path');
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickBannerImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _bannerImage = File(pickedFile.path);
      });
    }
  }

  void _removeImage(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text('Confirmar remoção'),
          content: Text('Tem certeza de que deseja remover esta imagem?'),
          actions: [
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Remover', style: TextStyle(color: Colors.red)),
              onPressed: () {
                setState(() {
                  _images.removeAt(index);
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _saveReview() async {
  if (_locationController.text.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione o nome do local.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (_addressController.text.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione a morada.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (_commentController.text.isEmpty) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione um comentário.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (_serviceRating == 0 || _cleanlinessRating == 0 || _valueRating == 0) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione uma avaliação para todos os aspectos.'),
          backgroundColor: Colors.red,
        ),
      );
    }
    return;
  }

  if (mounted) {
    setState(() {
      _isLoading = true;
    });
  }

  try {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      return;
    }

    String? imageId;

    if (_bannerImage != null) {
      var uploadRequest = http.MultipartRequest(
        'POST',
        Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload'),
      );
      uploadRequest.headers['Authorization'] = 'Bearer $token';

      uploadRequest.files.add(await http.MultipartFile.fromPath(
        'imagem',
        _bannerImage!.path,
      ));

      final uploadResponse = await uploadRequest.send();

      if (uploadResponse.statusCode == 200) {
        var uploadResponseBody = await uploadResponse.stream.bytesToString();
        var uploadData = jsonDecode(uploadResponseBody)['data'];
        imageId = uploadData['ID_IMAGEM'].toString(); // Converte para String
      } else {
        throw Exception('Failed to upload image');
      }
    }

    final response = await http.post(
      Uri.parse('https://backendpint-5wnf.onrender.com/recomendacoes/create'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'ID_IMAGEM': imageId,
        'NOME_SUBAREA': _selectedSubarea ?? '',
        'TITULO_RECOMENDACAO': _locationController.text,
        'DESCRICAO_RECOMENDACAO': _commentController.text,
        'MORADA_RECOMENDACAO': _addressController.text, // Adicionando a morada
      }),
    );

    if (response.statusCode == 200) {
      var recomendacaoData = jsonDecode(response.body)['data'];
      var idRecomendacao = recomendacaoData['ID_RECOMENDACAO'];

      final avaliacaoResponse = await http.post(
        Uri.parse('https://backendpint-5wnf.onrender.com/avaliacoes/create'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'ID_RECOMENDACAO': idRecomendacao,
          'AVALIACAO_PARAMETRO_1': _serviceRating,
          'AVALIACAO_PARAMETRO_2': _cleanlinessRating,
          'AVALIACAO_PARAMETRO_3': _valueRating,
        }),
      );

      if (avaliacaoResponse.statusCode != 200) {
        throw Exception('Failed to create evaluation');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recomendação salva com sucesso!'),
            backgroundColor: Colors.blue,
          ),
        );
        setState(() {
          _serviceRating = 0;
          _cleanlinessRating = 0;
          _valueRating = 0;
          _commentController.clear();
          _images.clear();
          _locationController.clear();
          _addressController.clear();
          _bannerImage = null;
          _isLoading = false;
        });
      }

      Navigator.pop(context);
    } else {
      throw Exception('Failed to create recommendation');
    }
  } catch (error) {
    print('Erro ao salvar recomendação: $error');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar recomendação.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }
}


  void _selectTag(String tag) {
    setState(() {
      _selectedTag = tag;
      _selectedSubarea = null;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _locationController.dispose();
    _addressController.dispose(); // Dispose do controlador da morada
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0DCAF0),
        centerTitle: true,
        title: Text(
          'Criação da Recomendação',
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
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(height: 16.0),
                          _buildTitle('Nome do Local'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Digite o nome do local aqui...',
                            controller: _locationController,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Adicionar Banner'),
                          SizedBox(height: 8.0),
                          _buildBannerImagePicker('Adicionar Banner'),
                          SizedBox(height: 16.0),
                          _buildTitle('Descrição'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Escreva a sua descrição do local...',
                            controller: _commentController,
                            maxLines: 5,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Morada'), // Adicionando o campo de morada
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Digite a morada aqui...',
                            controller: _addressController,
                          ),
                          SizedBox(height: 16.0),
                          _buildTitle('Área'),
                          SizedBox(height: 8.0),
                          _buildTagSelector(),
                          if (_selectedTag != null) ...[
                            SizedBox(height: 16.0),
                            _buildTitle('Sub-Área'),
                            SizedBox(height: 8.0),
                            _buildSubareaDropdown(),
                          ],
                          if (_selectedTag != null) ...[
                            SizedBox(height: 16.0),
                            _buildTitle('Rating'),
                            SizedBox(height: 8.0),
                            _buildRatingBarSection(),
                          ],
                          SizedBox(height: 30),
                          Container(
                            margin: EdgeInsets.only(bottom: 20.0),
                            child: MyButton(
                              onTap: _saveReview,
                              buttonText: 'Criar Recomendação',
                              leadingIcon: Icons.create,
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
    required TextEditingController controller,
    bool obscureText = false,
    int maxLines = 1,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          filled: true,
          fillColor: Colors.grey[200],
          contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
        ),
      ),
    );
  }

  Widget _buildBannerImagePicker(String label) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 25.0),
    child: GestureDetector(
      onTap: () => _pickBannerImage(ImageSource.gallery),
      child: Container(
        height: 300,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: _bannerImage == null
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
                    _bannerImage!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    ),
  );
}



  Widget _buildTagSelector() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    final tags = areaParameters.keys.toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Wrap(
        spacing: 8.0,
        runSpacing: 4.0,
        children: tags.map((tag) {
          final isSelected = _selectedTag == tag;
          return ChoiceChip(
            label: Text(tag),
            selected: isSelected,
            onSelected: (selected) {
              _selectTag(tag);
            },
            selectedColor: Colors.blue.shade200,
            backgroundColor: Colors.grey[200],
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubareaDropdown() {
    final subareasList = subareas[_selectedTag] ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      padding: EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          hint: Text('Selecione uma subárea'),
          value: _selectedSubarea,
          items: subareasList.map((subarea) {
            return DropdownMenuItem<String>(
              value: subarea,
              child: Text(subarea),
            );
          }).toList(),
          onChanged: (newValue) {
            setState(() {
              _selectedSubarea = newValue;
            });
          },
        ),
      ),
    );
  }

  Widget _buildRatingBarSection() {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<String> parameters = areaParameters[_selectedTag] ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (String parameter in parameters) ...[
          _buildTitleRatings(parameter),
          SizedBox(height: 8.0),
          _buildRatingBar(parameter, (rating) {
            setState(() {
              if (parameter == parameters[0]) {
                _serviceRating = rating;
              } else if (parameter == parameters[1]) {
                _cleanlinessRating = rating;
              } else if (parameter == parameters[2]) {
                _valueRating = rating;
              }
            });
          }),
          SizedBox(height: 15),
        ],
      ],
    );
  }

  Widget _buildTitleRatings(String title) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
        ),
      ),
    );
  }

  Widget _buildRatingBar(String title, Function(double) onRatingUpdate) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RatingBar.builder(
            initialRating: 0,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemPadding: EdgeInsets.symmetric(horizontal: 2.0),
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: onRatingUpdate,
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoButtons() {
    return Container(
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: MyButton(
              onTap: () => _pickImage(ImageSource.camera),
              buttonText: 'Câmera',
              leadingIcon: Icons.camera_alt,
            ),
          ),
          Expanded(
            flex: 1,
            child: MyButton(
              onTap: () => _pickImage(ImageSource.gallery),
              buttonText: 'Galeria',
              leadingIcon: Icons.photo,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_images.isEmpty) {
      return Center(
          child: Text('Nenhuma imagem adicionada',
              style: TextStyle(color: Colors.black)));
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
        ),
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.file(
                    File(_images[index]),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                child: GestureDetector(
                  onTap: () => _removeImage(index),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.remove_circle, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}