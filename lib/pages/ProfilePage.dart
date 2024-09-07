import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:app_mobile/handlers/TokenHandler.dart';
import 'package:app_mobile/models/Evento.dart';
import 'package:app_mobile/models/Recomendacao.dart';
import 'package:app_mobile/pages/EventoView.dart';
import 'package:app_mobile/pages/RecomendacaoView.dart';
import '../models/Profile.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // Import the dart:async package

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> items = [];
  List<Map<String, dynamic>> recomendacoes = [];
  List<Map<String, dynamic>> events = [];
  bool isPublicationsSelected = true;
  File? _bannerImage;
  File? _avatarImage;
  String userName = '';
  String userDescription = '';
  String userEmail = '';
  String userContact = '';
  String userCity = '';
  String userAvatarUrl = '';
  String userBannerUrl = '';
  String userPreferredArea = '';
  TokenHandler tokenHandler = TokenHandler();
  Timer? _timer; // Declare a Timer variable

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _startPeriodicFetch();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  bool _isFetching = false;

  void _startPeriodicFetch() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) async {
      if (_isFetching) return;
      setState(() => _isFetching = true);
      try {
        // Adiciona a chamada para atualizar os dados do usuário
        await _fetchUserData();

        // Atualiza as publicações ou eventos conforme a seleção
        if (isPublicationsSelected) {
          print('Buscando publicações...');
          await _fetchPublications();
        } else {
          print('Buscando eventos...');
          await _fetchEvents();
        }
      } finally {
        setState(() => _isFetching = false);
      }
    });
  }

  Future<void> _fetchUserData() async {
    try {
      final String? token = await tokenHandler.getToken();

      if (token == null) {
        print('Token não encontrado');
        return;
      }

      print('Token encontrado: $token');

      final tokenResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/getbytoken'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (tokenResponse.statusCode == 200) {
        final userData = json.decode(tokenResponse.body)['data'];
        print('Dados do usuário recebidos: $userData');
        setState(() {
          userName = userData['NOME_UTILIZADOR'] ?? '';
          userDescription = userData['DESCRICAO_UTILIZADOR'] ?? '';
          userEmail = userData['EMAIL_UTILIZADOR'] ?? '';
          userContact = userData['CONTACTO_UTILIZADOR'] ?? '';
          userCity = userData['CIDADE']?['NOME_CIDADE'] ?? '';
          userAvatarUrl = userData['Perfil']?['NOME_IMAGEM'] ?? '';
          userBannerUrl = userData['Banner']?['NOME_IMAGEM'] ?? '';
          userPreferredArea = userData['AREA_PREFERENCIA'] ?? '';
        });
      } else {
        print(
            'Falha ao carregar dados do usuário: ${tokenResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar dados do usuário: $e');
    }
  }

  Future<void> _fetchPublications() async {
    try {
      final String? token = await tokenHandler.getToken();

      if (token == null) {
        print('Token não encontrado');
        return;
      }

      // Fazer a requisição para obter as recomendações do usuário
      final recomendacoesResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/recomendacoes/listarRecomendacoesPorUser'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (recomendacoesResponse.statusCode == 200) {
        List<Map<String, dynamic>> recomendacoesData =
            List<Map<String, dynamic>>.from(
                json.decode(recomendacoesResponse.body)['data']);
        // Para cada recomendação, buscar a média de avaliações
        for (var recomendacao in recomendacoesData) {
          try {
            final mediaResponse = await http.get(
              Uri.parse(
                  'https://backendpint-5wnf.onrender.com/avaliacoes/mediaAvaliacaoporRecomendacao/${recomendacao['ID_RECOMENDACAO']}'),
              headers: {'Authorization': 'Bearer $token'},
            );

            if (mediaResponse.statusCode == 200) {
              final mediaData = jsonDecode(mediaResponse.body)['data'];
              double media1 = mediaData['media1'].toDouble();
              double media2 = mediaData['media2'].toDouble();
              double media3 = mediaData['media3'].toDouble();
              double avaliacaoGeral = (media1 + media2 + media3) / 3;
              // Armazenar a avaliação geral na recomendação
              recomendacao['avaliacaoGeral'] =
                  double.parse(avaliacaoGeral.toStringAsFixed(1));
            } else {
              print(
                  'Falha ao buscar média de avaliação para recomendação ${recomendacao['ID_RECOMENDACAO']}');
            }
          } catch (error) {
            print(
                'Erro ao buscar média de avaliação para recomendação ${recomendacao['ID_RECOMENDACAO']}: $error');
          }
        }

        // Atualizar o estado com as recomendações e avaliações
        setState(() {
          recomendacoes = recomendacoesData;
          if (isPublicationsSelected) {
            _showRecomendacoes();
          }
        });
      } else {
        print(
            'Falha ao carregar publicações: ${recomendacoesResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar publicações: $e');
    }
  }

  Future<void> _fetchEvents() async {
    try {
      final String? token = await tokenHandler.getToken();

      if (token == null) {
        print('Token não encontrado');
        return;
      }

      print('Token encontrado: $token');

      final eventsResponse = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/eventos/listarPorUser'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('Status da resposta de eventos: ${eventsResponse.statusCode}');

      if (eventsResponse.statusCode == 200) {
        setState(() {
          events = List<Map<String, dynamic>>.from(
              json.decode(eventsResponse.body)['data']);
          if (!isPublicationsSelected) {
            print('Mostrando eventos...');
            _showEvents();
          }
        });
      } else {
        print('Falha ao carregar eventos: ${eventsResponse.statusCode}');
      }
    } catch (e) {
      print('Erro ao buscar eventos: $e');
    }
  }

  void _showRecomendacoes() {
    print('Mostrando recomendações...');
    setState(() {
      isPublicationsSelected = true;
      items.clear();
      for (var recomendacao in recomendacoes) {
        items.add({
          'title': recomendacao['TITULO_RECOMENDACAO'].toString(),
          'description': recomendacao['DESCRICAO_RECOMENDACAO'].toString(),
          'imageUrl': recomendacao['IMAGEM']?['NOME_IMAGEM']?.toString() ?? '',
          'recomendacaoId': recomendacao['ID_RECOMENDACAO'].toString(),
        });
      }
    });
  }

  void _showEvents() {
    print('Mostrando eventos...');
    setState(() {
      isPublicationsSelected = false;
      items.clear();
      for (var event in events) {
        items.add({
          'title': event['TITULO_EVENTO'].toString(),
          'description': event['DESCRICAO_EVENTO'].toString(),
          'imageUrl': event['IMAGEM']?['NOME_IMAGEM']?.toString() ?? '',
          'eventId': event['ID_EVENTO'].toString(),
        });
      }
    });
  }

  Future<void> _pickImage(ImageSource source, bool isBanner) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);

      if (pickedFile != null) {
        setState(() {
          if (isBanner) {
            _bannerImage = File(pickedFile.path);
          } else {
            _avatarImage = File(pickedFile.path);
          }
        });

        final request = http.MultipartRequest(
          'POST',
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/utilizadores/uploadImagem'),
        );
        request.headers['Authorization'] =
            'Bearer ${await tokenHandler.getToken()}';
        request.files
            .add(await http.MultipartFile.fromPath('image', pickedFile.path));

        final response = await request.send();

        if (response.statusCode == 200) {
          print('Imagem carregada com sucesso');
        } else {
          print('Falha ao carregar imagem: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
    }
  }

  Future<void> _uploadImage(File imageFile, String type) async {
  try {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://backendpint-5wnf.onrender.com/imagens/upload'),
    );
    request.files.add(
      await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        filename: '${type}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      ),
    );
    var res = await request.send();

    // Adicione este trecho para garantir que a resposta seja decodificada corretamente
    var response = await http.Response.fromStream(res);
    var decodedResponse = jsonDecode(response.body); // <-- Aqui você obtém o Map ou List

    if (res.statusCode == 200) {
      print('Upload de $type bem-sucedido');
      _fetchUserData(); // Atualiza os dados após o upload
    } else {
      print('Falha no upload de $type: ${res.statusCode}');
    }
  } catch (e) {
    print('Erro ao enviar imagem: $e');
  }
}

  void _navigateToEventoView(Map<String, dynamic> event) {
    Evento evento = Evento(
        id: event['ID_EVENTO'] ?? 0,
        albumID: event['ID_ALBUM'] ?? '',
        bannerImage: event['IMAGEM']['NOME_IMAGEM'] ?? '',
        eventName: event['TITULO_EVENTO'] ?? '',
        dateTime: event['DATA_HORA_INICIO_EVENTO'] ?? '',
        address: event['MORADA_EVENTO'] ?? '',
        category: event['SUBAREA']['AREA']['NOME_AREA'] ?? '',
        subcategory: event['SUBAREA']['NOME_SUBAREA'] ?? '',
        lastThreeAttendees:
            List<String>.from(event['lastThreeAttendees'] ?? []),
        description: event['DESCRICAO_EVENTO'] ?? '',
        organizerId: event['ID_ORGANIZADOR'] ?? 0,
        bannerID: event['ID_IMAGEM'] ?? 0,
        estadoEvento: event['ATIVO_EVENTO'] ?? false);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventoView(evento: evento),
      ),
    );
  }

  void _navigateToRecomendacaoView(Map<String, dynamic> publication) {
    Recomendacao recomendacao = Recomendacao(
      idRecomendacao: publication['ID_RECOMENDACAO'],
      bannerImage: publication['IMAGEM']['NOME_IMAGEM'] ?? '',
      nomeLocal: publication['TITULO_RECOMENDACAO'] ?? '',
      endereco: publication['MORADA_RECOMENDACAO'] ?? '',
      avaliacaoGeral: (publication['avaliacaoGeral'] ?? 0.0).toDouble(),
      descricao: publication['DESCRICAO_RECOMENDACAO'] ?? '',
      categoria: publication['SUBAREA']['AREA']['NOME_AREA'] ?? '',
      subcategoria: publication['SUBAREA']['NOME_SUBAREA'] ?? '',
      idAlbum: publication['ID_ALBUM'] ?? '',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecomendacaoView(recomendacao: recomendacao),
      ),
    );
  }

  bool _isFetchingPublications = false;

  Future<void> _refreshData() async {
    if (_isFetchingPublications) return; // Evita chamadas repetidas

    setState(() {
      _isFetchingPublications = true;
    });

    await _fetchUserData();
    if (isPublicationsSelected) {
      await _fetchPublications();
    } else {
      await _fetchEvents();
    }

    setState(() {
      _isFetchingPublications = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Perfil',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              context.push('/edit-profile',
                  extra: EditProfileArguments(
                    bannerImageUrl: userBannerUrl,
                    avatarImageUrl: userAvatarUrl,
                    userName: userName,
                    userDescription: userDescription,
                    onSave: (newBanner, newAvatar, newName, newDescription,
                        newArea) {
                      setState(() {
                        userBannerUrl = newBanner;
                        userAvatarUrl = newAvatar;
                        userName = newName;
                        userDescription = newDescription;
                        userPreferredArea = newArea;
                      });
                    },
                  ));
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _bannerImage != null
                      ? Image.file(
                          _bannerImage!,
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        )
                      : Image.network(
                          userBannerUrl.isNotEmpty
                              ? userBannerUrl
                              : 'https://static.todamateria.com.br/upload/pa/is/paisagem-natural-og.jpg',
                          width: double.infinity,
                          height: 150.0,
                          fit: BoxFit.cover,
                        ),
                  Positioned(
                    top: 75.0,
                    left: MediaQuery.of(context).size.width / 2 - 80,
                    child: CircleAvatar(
                      radius: 80.0,
                      backgroundImage: _avatarImage != null
                          ? FileImage(_avatarImage!)
                          : userAvatarUrl.isNotEmpty
                              ? NetworkImage(userAvatarUrl)
                              : AssetImage(
                                      'assets/images/placeholder_image.png')
                                  as ImageProvider,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 90.0),
              Text(
                userName,
                style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
              SizedBox(height: 4.0),
              Text(
                '$userCity | $userDescription',
                style: TextStyle(fontSize: 16.0, color: Colors.grey),
              ),
              SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: _showRecomendacoes,
                    child: Text(
                      'Recomendações',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: isPublicationsSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color:
                            isPublicationsSelected ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  TextButton(
                    onPressed: _showEvents,
                    child: Text(
                      'Eventos',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: !isPublicationsSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: !isPublicationsSelected
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (isPublicationsSelected) {
                        _navigateToRecomendacaoView(
                            recomendacoes[index]); // Navegar para recomendação
                      } else {
                        _navigateToEventoView(
                            events[index]); // Navegar para evento
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 16.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        elevation: 5.0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15.0),
                                topRight: Radius.circular(15.0),
                              ),
                              child: items[index]['imageUrl']!.isNotEmpty
                                  ? Image.network(
                                      items[index]['imageUrl']!,
                                      width: double.infinity,
                                      height: 150.0,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          width: double.infinity,
                                          height: 150.0,
                                          color: Colors.grey,
                                          child: Icon(Icons.broken_image,
                                              size: 50.0, color: Colors.white),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: double.infinity,
                                      height: 150.0,
                                      color: Colors.grey,
                                      child: Icon(Icons.image,
                                          size: 50.0, color: Colors.white),
                                    ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    items[index]['title']!,
                                    style: TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10.0),
                                  Text(
                                    items[index]['description']!,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black54,
                                    ),
                                    textAlign: TextAlign.left,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
