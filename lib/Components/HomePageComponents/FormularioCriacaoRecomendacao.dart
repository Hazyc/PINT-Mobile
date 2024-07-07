import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../providers/participation_provider.dart';
import '../models/review.dart';
import '../LoginPageComponents/Botao.dart';

class ReviewPage extends StatefulWidget {
  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  double _serviceRating = 0;
  double _cleanlinessRating = 0;
  double _valueRating = 0;
  List<String> _images = [];
  File? _bannerImage;
  bool _isLoading = false;
  String? _selectedTag;
  String? _selectedSubarea;

  final Map<String, List<String>> subareas = {
    'Alojamento': ['Hotel', 'Apartamento', 'Hostel'],
    'Desporto': ['Ginásio', 'Campo de Futebol', 'Piscina'],
    'Formação': ['Curso', 'Workshop', 'Palestra'],
    'Gastronomia': ['Restaurante', 'Café', 'Bar'],
    'Lazer': ['Parque', 'Cinema', 'Museu'],
    'Saúde': ['Hospital', 'Clínica', 'Veterinário'],
    'Transportes': ['Ônibus', 'Táxi', 'Metrô'],
  };

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

      // Log the image paths
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

  void _saveReview() {
    if (_locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione o nome do local.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_commentController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione um comentário.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_serviceRating == 0 || _cleanlinessRating == 0 || _valueRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, adicione uma avaliação para todos os aspectos.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final review = Review(
      description: _commentController.text,
      rating: _serviceRating,
      serviceRating: _serviceRating,
      cleanlinessRating: _cleanlinessRating,
      valueRating: _valueRating,
      images: _images,
      creator: 'CurrentUserId',
      imageURL: '',
      tags: [],
      title: _locationController.text,
    );

    print('Review saved with images: ${review.images}');

    Provider.of<ParticipationProvider>(context, listen: false).addReview(review);

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
      _bannerImage = null;
    });

    Navigator.pop(context);
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
    super.dispose();
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
                padding: EdgeInsets.only(top: 32.0, bottom: 8.0, left: 16.0, right: 16.0),
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
                      icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    Text(
                      'Criação da Recomendação',
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
                          if (_bannerImage != null) ...[
                            SizedBox(height: 8.0),
                            _buildBannerImagePreview(),
                          ],
                          SizedBox(height: 16.0),
                          _buildTitle('Descrição'),
                          SizedBox(height: 8.0),
                          _buildTextField(
                            hintText: 'Escreva a sua descrição do local...',
                            controller: _commentController,
                            maxLines: 5,
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
                          SizedBox(height: 16.0),
                          _buildTitle('Adicionar Fotos'),
                          SizedBox(height: 8.0),
                          _buildPhotoButtons(),
                          SizedBox(height: 20),
                          _buildImageGrid(),
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
        onTap: () => _pickImage(ImageSource.gallery),
        child: Container(
          height: 150,
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

  Widget _buildBannerImagePreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25.0),
      height: 150,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.file(
            _bannerImage!,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildTagSelector() {
    final tags = [
      'Alojamento', 'Desporto', 'Formação', 'Gastronomia', 'Lazer', 'Saúde', 'Transportes'
    ];

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedTag == 'Alojamento' || _selectedTag == 'Desporto') ...[
          _buildTitleRatings('Serviço'),
          SizedBox(height: 8.0),
          _buildRatingBar('Serviço', (rating) {
            setState(() {
              _serviceRating = rating;
            });
          }),
          SizedBox(height: 15),
        ],
        if (_selectedTag == 'Alojamento' || _selectedTag == 'Desporto' || _selectedTag == 'Formação') ...[
          _buildTitleRatings('Limpeza'),
          SizedBox(height: 8.0),
          _buildRatingBar('Limpeza', (rating) {
            setState(() {
              _cleanlinessRating = rating;
            });
          }),
          SizedBox(height: 15),
        ],
        _buildTitleRatings('Custo-benefício'),
        SizedBox(height: 8.0),
        _buildRatingBar('Custo-benefício', (rating) {
          setState(() {
            _valueRating = rating;
          });
        }),
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
      return Center(child: Text('Nenhuma imagem adicionada', style: TextStyle(color: Colors.black)));
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
