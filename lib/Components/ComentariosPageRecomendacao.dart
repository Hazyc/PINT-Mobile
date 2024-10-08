import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../handlers/TokenHandler.dart';

class ComentariosPage extends StatefulWidget {
  final int id;

  ComentariosPage({required this.id});

  @override
  _ComentariosPageState createState() => _ComentariosPageState();
}

class _ComentariosPageState extends State<ComentariosPage> {
  List<dynamic> comments = [];
  Map<String, dynamic>? userData;
  TokenHandler tokenHandler = TokenHandler();
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _reportController =
      TextEditingController(); // Controller para o motivo do report
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
    fetchComments();
  }

  Future<void> fetchUserData() async {
    try {
      final token = await tokenHandler.getToken();
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      final response = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/utilizadores/getByToken'),
        headers: {'x-access-token': 'Bearer $token'},
      );
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body)['data'];
        });
      } else {
        print('Failed to load user data. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchComments() async {
    try {
      final token = await tokenHandler.getToken();
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      print(widget.id);
      final response = await http.get(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/comentariosrecomendacaoutilizador/listarPorRecomendacaoVisiveis/${widget.id}'),
        headers: {'x-access-token': 'Bearer $token'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            comments = data['data'];
            _isLoading = false;
          });
        } else {
          print('Failed to load comments: ${data['message']}');
        }
      } else {
        print('Failed to load comments. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching comments: $e');
    }
  }

  Future<void> addComment() async {
    if (_commentController.text.isNotEmpty && userData != null) {
      try {
        final token = await tokenHandler.getToken();
        if (token == null) {
          print('Token is null. Please log in again.');
          return;
        }

        final response = await http.post(
          Uri.parse(
              'https://backendpint-5wnf.onrender.com/comentariosrecomendacaoutilizador/create'),
          headers: {
            'Content-Type': 'application/json',
            'x-access-token': 'Bearer $token',
          },
          body: json.encode({
            'ID_RECOMENDACAO': widget.id,
            'CONTEUDO_COMENTARIO': _commentController.text,
          }),
        );

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200) {
          setState(() {
            comments.add({
              'UTILIZADOR': {
                'Perfil': {
                  'NOME_IMAGEM': userData!['Perfil']['NOME_IMAGEM'] ?? ''
                },
                'NOME_UTILIZADOR': userData!['NOME_UTILIZADOR'] ?? ''
              },
              'COMENTARIO': {'CONTEUDO_COMENTARIO': _commentController.text},
              'LIKED': false, // Novo campo para controle de likes
            });
            _commentController.clear();
          });
        } else {
          print('Failed to add comment. Status code: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      } catch (e) {
        print('Error adding comment: $e');
      }
    }
  }

  void showDeleteConfirmationDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('Deseja realmente apagar este comentário?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                deleteComment(index);
                Navigator.of(context).pop();
              },
              child: Text('Apagar'),
            ),
          ],
        );
      },
    );
  }

  void deleteComment(int index) async {
    // Implement delete comment functionality here
    // Ensure you update the state and remove the comment from the list
  }

  void showReportDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Reportar Comentário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deseja realmente reportar este comentário?'),
              SizedBox(height: 10),
              TextField(
                controller: _reportController,
                decoration: InputDecoration(
                  hintText: 'Descreva o motivo do report',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
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
                reportComment(index);
                Navigator.of(context).pop();
              },
              child: Text('Reportar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> reportComment(int index) async {
    if (_reportController.text.isEmpty) {
      print('Motivo do report não pode ser vazio');
      return;
    }

    try {
      final token = await tokenHandler.getToken();
      if (token == null) {
        print('Token is null. Please log in again.');
        return;
      }

      final comment = comments[index];
      final response = await http.post(
        Uri.parse('https://backendpint-5wnf.onrender.com/reports/create'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': 'Bearer $token',
        },
        body: json.encode({
          'ID_COMENTARIO': comment['COMENTARIO']['ID_COMENTARIO'],
          'TITULO_REPORT':
              'Report de Comentário na Recomendação ${comment['RECOMENDACAO']['TITULO_RECOMENDACAO']}',
          'DESCRICAO_REPORT': _reportController.text,
        }),
      );

      print(comment['COMENTARIO']['ID_COMENTARIO']);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200 && responseBody['success'] == true) {
        print('Report enviado com sucesso.');
        _reportController.clear();
      } else {
        print('Falha ao enviar report: ${responseBody['message']}');
      }
    } catch (e) {
      print('Erro ao reportar comentário: $e');
    }
  }

  Future<void> toggleLike(int index) async {
    try {
      final comment = comments[index];
      final response = await http.post(
        Uri.parse(
            'https://backendpint-5wnf.onrender.com/avaliacoes/addOrUpdateLike'),
        headers: {
          'Content-Type': 'application/json',
          'x-access-token': 'Bearer ${await tokenHandler.getToken()}',
        },
        body: json.encode({
          'ID_COMENTARIO': comment['COMENTARIO']['ID_COMENTARIO'],
        }),
      );

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        if (responseBody['success']) {
          setState(() {
            comments[index]['LIKED'] = !comments[index]['LIKED'];
            comments[index]['LIKES_COUNT'] = responseBody['likesCount'];
          });
        } else {
          print('Failed to toggle like: ${responseBody['message']}');
        }
      } else {
        print('Failed to toggle like. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error toggling like: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comentários'),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
      body: Column(
        children: [
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final liked = comment['LIKED'] ?? false;
                      return GestureDetector(
                        onLongPress: () {
                          showDeleteConfirmationDialog(index);
                        },
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(comment['UTILIZADOR']
                                    ?['Perfil']?['NOME_IMAGEM'] ??
                                ''),
                          ),
                          title: Text(
                              comment['UTILIZADOR']?['NOME_UTILIZADOR'] ?? ''),
                          subtitle: Text(comment['COMENTARIO']
                                  ?['CONTEUDO_COMENTARIO'] ??
                              ''),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  liked
                                      ? Icons.thumb_up
                                      : Icons.thumb_up_alt_outlined,
                                  color: liked ? Colors.blue : null,
                                ),
                                onPressed: () {
                                  toggleLike(index);
                                },
                              ),
                              Text('${comment['LIKES_COUNT'] ?? 0}'),
                              IconButton(
                                icon: Icon(Icons.flag),
                                onPressed: () {
                                  showReportDialog(index);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escreva um comentário...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
