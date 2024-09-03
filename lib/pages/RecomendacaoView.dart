import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/Recomendacao.dart';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Components/ComentariosPageRecomendacao.dart';

class RecomendacaoView extends StatefulWidget {
  final Recomendacao recomendacao;

  RecomendacaoView({required this.recomendacao});

  @override
  _RecomendacaoViewState createState() => _RecomendacaoViewState();
}

class _RecomendacaoViewState extends State<RecomendacaoView> {
  bool isFavorite = false;
  List<String> additionalImages =
      []; // Adicionando imagens estáticas para teste visual
  List<String> avaliacaoParametros = [];
  double cleanlinessRating = 0;
  double serviceRating = 0;
  double locationRating = 0;
  List<String> albumImages = [];
  int displayedImageCount = 6;
  bool showAllImages = false;

  @override
  void initState() {
    super.initState();
    _requestPermission(Permission.storage);
    fetchAreaParameters();
    _loadAlbumImages();
    fetchExistingReview();
  }

  double? existingCleanlinessRating;
  double? existingServiceRating;
  double? existingLocationRating;

  Future<void> fetchExistingReview() async {
    final existingReview = await _getExistingReview();
    if (existingReview != null) {
      setState(() {
        existingCleanlinessRating =
            existingReview['AVALIACAO_PARAMETRO_1']?.toDouble();
        existingServiceRating =
            existingReview['AVALIACAO_PARAMETRO_2']?.toDouble();
        existingLocationRating =
            existingReview['AVALIACAO_PARAMETRO_3']?.toDouble();
      });
    }
  }

  void _showMoreImages() {
    setState(() {
      displayedImageCount = albumImages.length; // Mostra todas as imagens
      showAllImages = true;
    });
  }

  List<String> getDisplayedImages() {
    return albumImages.take(displayedImageCount).toList();
  }

  Future<void> _loadAlbumImages() async {
    try {
      // Obtendo o token
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      // Verificando o albumID
      final albumID = widget.recomendacao.idAlbum;
      print('Album ID: $albumID');
      if (albumID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID do álbum não encontrado.')),
        );
        return;
      }

      // Formando a URL
      final url = Uri.parse(
        'https://backendpint-5wnf.onrender.com/imagens/listarfotosalbum/${widget.recomendacao.idAlbum}',
      );

      print('Request URL: $url'); // Log da URL
      print('Token: $token'); // Log do token

      // Enviando a solicitação HTTP
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success']) {
          final List<dynamic> imageData = responseData['data'];

          setState(() {
            albumImages = imageData
                .map((image) => image['NOME_IMAGEM'] as String)
                .toList();
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Falha ao carregar as imagens: ${responseData['message'] ?? 'Desconhecido'}'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro ao carregar as imagens: ${response.statusCode}'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar as imagens: ${e.toString()}')),
      );
    }
  }

  Future<void> _uploadImage(XFile image) async {
    try {
      final token = await TokenHandler().getToken();
      if (token == null || token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Token de autenticação não encontrado.')),
        );
        return;
      }

      final albumID = widget.recomendacao.idAlbum
          ?.toString(); // Converte albumID para string
      if (albumID == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ID do álbum não encontrado.')),
        );
        return;
      }

      final uri =
          Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['ID_ALBUM'] = albumID
        ..files.add(await http.MultipartFile.fromPath('imagem', image.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      final Map<String, dynamic> responseData = json.decode(responseBody);

      if (response.statusCode == 200 && responseData['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fotos carregadas com sucesso!')),
        );
        // Atualize a lista de imagens após o upload
        _loadAlbumImages();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Erro ao carregar fotos: ${responseData['message'] ?? 'Desconhecido'}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar fotos: ${e.toString()}')),
      );
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
      final Uri uri = Uri.parse(
              'https://backendpint-5wnf.onrender.com/areas/listarPorNomeOuID')
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
    final existingReview = await _getExistingReview();
    final token = await TokenHandler().getToken();

    if (token == null || token.isEmpty) {
      print('Token não encontrado');
      return;
    }

    final Uri url;
    final Map<String, dynamic> body;

    if (existingReview != null) {
      // Atualizar avaliação existente
      url = Uri.parse(
          'https://backendpint-5wnf.onrender.com/avaliacoes/update/${existingReview['ID_AVALIACAO']}');
      body = {
        'AVALIACAO_PARAMETRO_1': cleanlinessRating,
        'AVALIACAO_PARAMETRO_2': serviceRating,
        'AVALIACAO_PARAMETRO_3': locationRating,
      };
    } else {
      // Criar nova avaliação
      url =
          Uri.parse('https://backendpint-5wnf.onrender.com/avaliacoes/create');
      body = {
        'AVALIACAO_PARAMETRO_1': cleanlinessRating,
        'AVALIACAO_PARAMETRO_2': serviceRating,
        'AVALIACAO_PARAMETRO_3': locationRating,
        'ID_RECOMENDACAO': widget.recomendacao.idRecomendacao,
      };
    }

    try {
      final response = await (existingReview != null
          ? http.put(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            )
          : http.post(
              url,
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(body),
            ));

      if (response.statusCode == 200) {
        print('Avaliação enviada com sucesso');
        // Aqui você pode lidar com a resposta da API conforme necessário
      } else {
        throw Exception('Falha ao enviar avaliação');
      }
    } catch (error) {
      print('Erro ao enviar avaliação: $error');
      // Tratar o erro conforme necessário
    }
  }

  Future<Map<String, dynamic>?> _getExistingReview() async {
    final token = await TokenHandler().getToken();

    if (token == null || token.isEmpty) {
      print('Token não encontrado');
      return null;
    }

    final url = Uri.parse(
        'https://backendpint-5wnf.onrender.com/avaliacoes/listarPorRecomendacaoEUser/${widget.recomendacao.idRecomendacao}');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> reviews = jsonDecode(response.body)['data'];
        if (reviews.isNotEmpty) {
          return reviews.first;
        }
      } else {
        throw Exception('Falha ao obter avaliação existente');
      }
    } catch (error) {
      print('Erro ao obter avaliação existente: $error');
      // Tratar o erro conforme necessário
    }

    return null;
  }

  Future<void> _pickFiles() async {
    final status = await Permission.photos.request();

    if (status.isGranted) {
      try {
        final result = await FilePicker.platform.pickFiles(
          allowMultiple: true,
          type: FileType.image,
        );

        if (result != null) {
          // Obtendo a lista de arquivos selecionados
          final List<PlatformFile> files = result.files;

          // Fazendo upload de cada imagem selecionada
          for (var file in files) {
            final image = XFile(file.path!);
            await _uploadImage(image); // Envia a imagem selecionada
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Imagens carregadas com sucesso!')),
          );
        } else {
          print("Nenhuma imagem selecionada.");
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erro ao selecionar imagens: ${e.toString()}')),
        );
      }
    } else if (status.isPermanentlyDenied) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Permissão de acesso às fotos foi permanentemente negada.'),
          action: SnackBarAction(
            label: 'Configurações',
            onPressed: () {
              openAppSettings(); // Abre as configurações do aplicativo
            },
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permissão de acesso às fotos foi negada.')),
      );
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
                initialRating: existingCleanlinessRating ?? 0,
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
                initialRating: existingServiceRating ?? 0,
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
                initialRating: existingLocationRating ?? 0,
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

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isGranted) {
      return;
    } else if (status.isPermanentlyDenied) {
      // Abre as configurações do aplicativo se a permissão for permanentemente negada
      await openAppSettings();
    }
  }

  void _showFullImage(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Imagem e outras UI
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.black.withOpacity(0.0),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Hero(
                          tag: imageUrl,
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey,
                                child: Center(
                                  child: Icon(Icons.error, color: Colors.red),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Toque para fechar',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMoreImagesModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        // Calcula as imagens restantes
        final remainingImages = albumImages.skip(displayedImageCount).toList();

        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Galeria de Fotos - Mais Imagens:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0,
                  ),
                  itemCount: remainingImages.length,
                  itemBuilder: (context, index) {
                    final imageUrl = remainingImages[index];
                    return GestureDetector(
                      onTap: () {
                        _showFullImage(imageUrl);
                      },
                      child: Hero(
                        tag: imageUrl,
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey,
                              child: Center(
                                child: Icon(Icons.error, color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
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
                  Text(
                    'Galeria de Fotos:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  if (albumImages.isNotEmpty)
                    Column(
                      children: [
                        GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 4.0,
                            mainAxisSpacing: 4.0,
                          ),
                          itemCount: getDisplayedImages().length,
                          itemBuilder: (context, index) {
                            final imageUrl = getDisplayedImages()[index];
                            return GestureDetector(
                              onTap: () {
                                _showFullImage(imageUrl);
                              },
                              child: Hero(
                                tag: imageUrl,
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey,
                                      child: Center(
                                        child: Icon(Icons.error,
                                            color: Colors.red),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                        if (!showAllImages &&
                            albumImages.length > displayedImageCount)
                          TextButton(
                            onPressed: _showMoreImagesModal,
                            child: Text(
                                'Ver mais (${albumImages.length - displayedImageCount} restantes)'),
                          ),
                      ],
                    )
                  else
                    Text('Nenhuma imagem disponível.'),
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
                              print('Forum do evento');
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
                                  builder: (context) => ComentariosPage(
                                    id: widget.recomendacao.idRecomendacao,
                                  ),
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
    final String encodedAddress = Uri.encodeComponent(address);
    final String url =
        'https://www.google.com/maps/search/?api=1&query=$encodedAddress';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Não foi possível abrir o Google Maps')),
      );
    }
  }
}
