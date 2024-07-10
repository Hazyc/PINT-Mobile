import 'package:flutter/material.dart';
import '../Components/geocoding_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../models/Recomendacao.dart';
import '../pages/MapPage.dart';
import '../Components/ComentariosPageRecomendacao.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecomendacaoView extends StatefulWidget {
  final Recomendacao recomendacao;
  final VoidCallback onLike;

  RecomendacaoView({required this.recomendacao, required this.onLike});

  @override
  _RecomendacaoViewState createState() => _RecomendacaoViewState();
}

class _RecomendacaoViewState extends State<RecomendacaoView> {
  bool isFavorite = false;
  List<String> additionalImages = []; // Adicionando imagens estáticas para teste visual
  List<String> avaliacaoParametros = [];
  double cleanlinessRating = 0;
  double serviceRating = 0;
  double locationRating = 0;

  @override
  void initState() {
    super.initState();
    _requestPermission(Permission.storage);
    _loadAdditionalImages();
    fetchAreaParameters();
  }


Future<void> _loadAdditionalImages() async {
  TokenHandler tokenHandler = TokenHandler();
  final String? token = await tokenHandler.getToken();

  if (token == null) {
    print('Token não encontrado');
    return;
  }

  try {
    final Uri uri = Uri.parse('http://localhost:7000/imagens/listarfotosalbumvisivel')
      .replace(queryParameters: {
        'ID_ALBUM': widget.recomendacao.idAlbum.toString(),
      });

    final imagensResponse = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (imagensResponse.statusCode == 200) {
      final List<dynamic> imagensData = jsonDecode(imagensResponse.body)['data'];
      setState(() {
        additionalImages = imagensData
          .where((imagem) => imagem['NOME_IMAGEM'] != widget.recomendacao.bannerImage)
          .map((imagem) => imagem['NOME_IMAGEM'] as String)
    .toList();
});
    } else {
      throw Exception('Failed to load images');
    }
  } catch (error) {
    print('Erro ao carregar imagens: $error');
    // Tratar erro conforme necessário
  }
}

Future<void> fetchAreaParameters() async {
    TokenHandler tokenHandler = TokenHandler();
    final String? token = await tokenHandler.getToken();

    if (token == null) {
      print('Token não encontrado');
      return;
    }

    try {
      final Uri uri = Uri.parse('http://localhost:7000/areas/listarPorNomeOuID')
          .replace(queryParameters: {
            'NOME_AREA': widget.recomendacao.categoria,
          });

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> areasData = jsonDecode(response.body)['data'];

        if (areasData.isNotEmpty) {
          setState(() {
            avaliacaoParametros = [
              areasData[0]['PARAMETRO_AVALIACAO_1'],
              areasData[0]['PARAMETRO_AVALIACAO_2'],
              areasData[0]['PARAMETRO_AVALIACAO_3']
            ];
          });
        } else {
          throw Exception('No data available for evaluation parameters');
        }
      } else {
        throw Exception('Failed to fetch evaluation parameters');
      }
    } catch (error) {
      print('Erro ao buscar parâmetros de avaliação das áreas: $error');
      // Tratar erro conforme necessário
    }
  }

  Future<void> enviarAvaliacoesParaAPI() async {
  TokenHandler tokenHandler = TokenHandler();
  final String? token = await tokenHandler.getToken();

  if (token == null) {
    print('Token não encontrado');
    return;
  }

  try {
    final response = await http.post(
      Uri.parse('http://localhost:7000/avaliacoes/create'), // URL da sua API para enviar avaliações
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'AVALIACAO_PARAMETRO_1': cleanlinessRating,
        'AVALIACAO_PARAMETRO_2': serviceRating,
        'AVALIACAO_PARAMETRO_3': locationRating,
        'ID_RECOMENDACAO': widget.recomendacao.idRecomendacao,
      }),
    );

    if (response.statusCode == 200) {
      print('Avaliações enviadas com sucesso');
      // Aqui você pode lidar com a resposta da API conforme necessário
    } else {
      throw Exception('Falha ao enviar avaliações');
    }
  } catch (error) {
    print('Erro ao enviar avaliações: $error');
    // Tratar o erro conforme necessário
  }
}



  void _showRatingDialog() {
    showDialog(
      context: context,
      builder: (context) {


        return AlertDialog(
          title: Text('Deixar a sua avaliação'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(avaliacaoParametros[0]),
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
              Text(avaliacaoParametros[1]),
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
              Text(avaliacaoParametros[2]),
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
                enviarAvaliacoesParaAPI();
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
                  child: Image.network(
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
                        initialRating: widget.recomendacao.avaliacaoGeral ,
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
                                          NetworkImage(additionalImages[index]),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _showRatingDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Color(0xFF0DCAF0), // Background color
                          ),
                          child: Text(
                            'Deixar a sua avaliação',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: Color(0xFF0DCAF0),
                          radius: 22,
                          child: IconButton(
                            icon: Icon(Icons.forum, color: Colors.white),
                            onPressed: () {
                              // Redirecionar para o fórum da recomendação
                            },
                            iconSize: 22,
                          ),
                        ),
                        SizedBox(width: 16),
                        CircleAvatar(
                          backgroundColor: Color(0xFF0DCAF0),
                          radius: 22,
                          child: IconButton(
                            icon: Icon(Icons.comment, color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ComentariosPageRecomendacao(
                                      recomendacao: widget.recomendacao),
                                ),
                              );
                            },
                            iconSize: 22,
                          ),
                        ),
                      ],
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