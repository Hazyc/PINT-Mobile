import 'package:flutter/material.dart';
import 'ChatPage.dart'; // Certifique-se de ajustar o caminho conforme necessário
import 'FormularioCriacaoSubForum.dart';
import 'package:intl/intl.dart';

class SubForumPage extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> subForuns;

  SubForumPage({required this.title, required this.subForuns});

  @override
  _SubForumPageState createState() => _SubForumPageState();
}

class _SubForumPageState extends State<SubForumPage> {
  late List<Map<String, dynamic>> subForuns;

  @override
  void initState() {
    super.initState();
    subForuns = widget.subForuns;
  }

  String _formatDate(String dateStr) {
    final dateTime = DateTime.parse(dateStr);
    final formatter = DateFormat('dd-MM-yyyy HH:mm');
    return formatter.format(dateTime);
  }

  void _addSubForum(Map<String, dynamic> newSubForum) {
    Map<String, dynamic> novoSubForum= {
      'nome': newSubForum['TITULO_TOPICO'],
      'imagem': newSubForum['IMAGEM'],
      'subarea': newSubForum['SUBAREA'],
      'dataCriacao': newSubForum['DATA_CRIACAO_TOPICO'],
    };
    setState(() {
      subForuns.add(novoSubForum);
    });

  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Sub-Fóruns de ${widget.title}',
        style: TextStyle(color: Colors.white, fontSize: 24.0),
      ),
      backgroundColor: const Color(0xFF0DCAF0),
      centerTitle: true,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    body: subForuns == null || subForuns.isEmpty
        ? Center(
            child: Text('Nenhum sub-fórum disponível.'),
          )
        : ListView.builder(
            itemCount: subForuns.length,
            itemBuilder: (context, index) {
              final subForum = subForuns[index];
              final imagemUrl = subForum['imagem'] as String?;
              final nome = subForum['nome'] as String?;
              final subarea = subForum['subarea'] as String?;
              final dataCriacao = subForum['dataCriacao'] as String?;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 5,
                child: ListTile(
                  leading: imagemUrl != null
                      ? Image.network(
                          imagemUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        )
                      : SizedBox.shrink(), // Retorna um espaço vazio se a imagemUrl for nula
                  title: nome != null
                      ? Text(
                          nome,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        )
                      : SizedBox.shrink(), // Retorna um espaço vazio se o nome for nulo
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sub-área: ${subarea ?? ''}'),
                      Text('Criado em: ${dataCriacao != null ? _formatDate(dataCriacao) : ''}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          title: nome!,
                          subForumId: '${widget.title}-$nome',
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
    floatingActionButton: FloatingActionButton(
      onPressed: () async {
        // Navegar para o formulário de criação de sub-fórum
        final newSubForum = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FormularioCriacaoSubForum(category: widget.title),
          ),
        );

        if (newSubForum != null) {
          _addSubForum(newSubForum);
        }
      },
      child: Icon(Icons.add),
      backgroundColor: const Color(0xFF0DCAF0),
    ),
  );
}

}
