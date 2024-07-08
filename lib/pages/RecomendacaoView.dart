import 'package:flutter/material.dart';
import '../Components/geocoding_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'dart:io';
import '../models/Recomendacao.dart';
import '../pages/MapPage.dart';

class RecomendacaoView extends StatefulWidget {
  final Recomendacao recomendacao;
  final VoidCallback onLike;

  RecomendacaoView({required this.recomendacao, required this.onLike});

  @override
  _RecomendacaoViewState createState() => _RecomendacaoViewState();
}

class _RecomendacaoViewState extends State<RecomendacaoView> {
  bool isFavorite = false;
  List<String> additionalImages = [
    'assets/desporto.jpg',
    'assets/saúde.jpg',
    'assets/transportes.jpg',
    'assets/gastronomia.jpg',
  ]; // Adicionando imagens estáticas para teste visual

  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {
        double cleanlinessRating = 0;
        double serviceRating = 0;
        double locationRating = 0;

        return AlertDialog(
          title: Text('Deixar a sua avaliação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Limpeza'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  cleanlinessRating = rating;
                },
              ),
              SizedBox(height: 8),
              Text('Serviço'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  serviceRating = rating;
                },
              ),
              SizedBox(height: 8),
              Text('Localização'),
              RatingBar.builder(
                initialRating: 0,
                minRating: 0,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Colors.amber,
                ),
                onRatingUpdate: (rating) {
                  locationRating = rating;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Aqui você pode enviar os ratings para a API
                print(
                    "Limpeza: $cleanlinessRating, Serviço: $serviceRating, Localização: $locationRating");
                Navigator.of(context).pop();
              },
              child: Text('Enviar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickFiles() async {
    if (await _requestPermission(Permission.storage)) {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        setState(() {
          additionalImages.addAll(result.paths.whereType<String>());
        });
        // Aqui você pode lidar com os arquivos selecionados
        print(
            "Files picked: ${result.files.map((file) => file.name).join(", ")}");
      } else {
        // O usuário cancelou a seleção
        print("No files picked.");
      }
    } else {
      // Permissão negada
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Permissão de acesso ao armazenamento foi negada.')),
      );
    }
  }

  Future<bool> _requestPermission(Permission permission) async {
    if (await permission.isGranted) {
      return true;
    } else {
      var result = await permission.request();
      return result == PermissionStatus.granted;
    }
  }

  void _showImageDialog(String imagePath) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 200,
            height: 250,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _requestPermission(Permission.storage);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  child: Image.asset(
                    widget.recomendacao.bannerImage,
                    height: 350,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Color(0xFF0DCAF0)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      iconSize: 22,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.recomendacao.categoria,
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF0DCAF0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite ? Colors.red : Color(0xFF0DCAF0),
                      ),
                      onPressed: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },
                      iconSize: 20,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: IconButton(
                      icon: Icon(Icons.attach_file, color: Color(0xFF0DCAF0)),
                      onPressed: _pickFiles,
                      iconSize: 22,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recomendacao.nomeLocal,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () =>
                        _openMap(context, widget.recomendacao.endereco),
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Color(0xFF0DCAF0)),
                        SizedBox(width: 4),
                        Text(
                          widget.recomendacao.endereco,
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0DCAF0),
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Subcategoria: ${widget.recomendacao.subcategoria}', // Adicionando subcategoria
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Avaliação Geral:',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 8),
                      RatingBar.builder(
                        initialRating: widget.recomendacao.avaliacaoGeral,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemSize: 24,
                        ignoreGestures:
                            true, // Para não permitir alteração direta
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {},
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Descrição:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    widget.recomendacao.descricao,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  if (additionalImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Mais Imagens:',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Container(
                          height: 100, // Altura das imagens
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: additionalImages.length,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () =>
                                    _showImageDialog(additionalImages[index]),
                                child: Container(
                                  width: 100,
                                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image:
                                          AssetImage(additionalImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: _showRatingDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF0DCAF0), // Background color
                      ),
                      child: Text(
                        'Deixar a sua avaliação',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Center(
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 22,
                      child: IconButton(
                        icon: Icon(Icons.forum, color: Color(0xFF0DCAF0)),
                        onPressed: () {
                          // Redirecionar para o fórum da recomendação
                        },
                        iconSize: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openMap(BuildContext context, String address) async {
    final geocodingService = GeocodingService();
    final location = await geocodingService.getLatLngFromAddress(address);

    if (location != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapPage(targetLocation: location),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível obter a localização')),
      );
    }
  }
}
