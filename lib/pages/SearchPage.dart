import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Pesquisar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.0,
          ),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60.0), // Altura da barra de pesquisa
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Pesquisar...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                contentPadding: EdgeInsets.zero,
              ),
              // Implemente a lógica de pesquisa aqui
              onChanged: (value) {
                // Aqui você pode atualizar o estado conforme o usuário digita na barra de pesquisa
                //temos de implementar um metodo para pesquisar
                //sempre que o user escrever alguma coisa
                //bonus: quando o utilizador fizer uma pesquisa, podemos mostrar as pesquisas recentes em baixo
                // X Antonio Semedo
                // X Hotel Onix
                // X Restaurante O Pescador
                //
                //estes resultados serao clicáveis serao guardados no storage do dispositivo
              },
            ),
          ),
        ),
      ),
      body: Center(
        child: Text("Tela Pesquisar"),
      ),
    );
  }
}
