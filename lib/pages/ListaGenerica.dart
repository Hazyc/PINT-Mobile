import 'package:flutter/material.dart';
import '../Components/RecomendacaoComponents/RecomendacaoCard.dart';
import '../Components/EventoComponents/EventoCard.dart';
import '../models/Recomendacao.dart';
import '../models/Evento.dart';
import '../Components/EventoComponents/FormularioCriacaoEvento.dart';

class ListaGenerica extends StatefulWidget {
  final String initialSelectedArea;

  ListaGenerica({this.initialSelectedArea = 'Todos'});

  @override
  _ListaGenericaState createState() => _ListaGenericaState();
}

class _ListaGenericaState extends State<ListaGenerica> {
  List<String> areas = [
    'Todos',
    'Alojamento',
    'Desporto',
    'Formação',
    'Gastronomia',
    'Lazer',
    'Saúde',
    'Transportes'
  ];

  String? selectedArea;

  List<Recomendacao> recomendacoes = [
    Recomendacao(
      bannerImage: 'assets/alojamento.jpg',
      nomeLocal: 'St. Regis Bora Bora',
      endereco: 'Rua das Eiras, nº 28 3525-515',
      avaliacaoGeral: 4.5,
      descricao: 'Bora Bora is an island...',
      categoria: 'Alojamento',
      subcategoria: 'Hotel',
    ),
    Recomendacao(
      bannerImage: 'assets/desporto.jpg',
      nomeLocal: 'Complexo Desportivo',
      endereco: 'Avenida Principal, nº 100',
      avaliacaoGeral: 4.0,
      descricao: 'Um ótimo lugar para esportes...',
      categoria: 'Desporto',
      subcategoria: 'Ginásio',
    ),
    // Adicione mais recomendações estáticas aqui
  ];

  List<Evento> eventos = [
  Evento(
    bannerImage: 'assets/night.jpg',
    eventName: 'Evento Esportivo',
    dateTime: '2024-07-14 18:00', // Certifique-se de que a data esteja no formato yyyy-MM-dd
    address: 'Avenida Principal, nº 100',
    category: 'Desporto',
    subcategory: 'Futebol',
    lastThreeAttendees: [
      'assets/user-1.png',
      'assets/user-2.png',
      'assets/user-3.png',
    ],
    description: 'Um evento esportivo para toda a família...',
  ),
  Evento(
    bannerImage: 'assets/day.jpg',
    eventName: 'Gastronomia Expo',
    dateTime: '2024-08-05 10:00', // Certifique-se de que a data esteja no formato yyyy-MM-dd
    address: 'Rua das Eiras, nº 28',
    category: 'Gastronomia',
    subcategory: 'Comida',
    lastThreeAttendees: [
      'assets/user-1.png',
      'assets/user-2.png',
      'assets/user-3.png',
    ],
    description: 'Uma exposição de gastronomia com os melhores chefs...',
  ),
  // Adicione mais eventos estáticos aqui
];


  bool showRecommendations = true;
  bool showEvents = true;

  @override
  void initState() {
    super.initState();
    selectedArea = widget.initialSelectedArea;
  }

  List<dynamic> get filteredItems {
    List<dynamic> filteredList = [];
    
    if (showRecommendations) {
      filteredList.addAll(recomendacoes.where((item) =>
          selectedArea == 'Todos' || item.categoria == selectedArea));
    }
    
    if (showEvents) {
      filteredList.addAll(eventos.where((item) =>
          selectedArea == 'Todos' || item.category == selectedArea));
    }

    return filteredList;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Filtrar"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CheckboxListTile(
                title: Text("Recomendações"),
                value: showRecommendations,
                onChanged: (bool? value) {
                  setState(() {
                    showRecommendations = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
              CheckboxListTile(
                title: Text("Eventos"),
                value: showEvents,
                onChanged: (bool? value) {
                  setState(() {
                    showEvents = value!;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showCreateOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Criar Evento'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormularioCriacaoEvento()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.recommend),
              title: Text('Criar Recomendação'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FormularioCriacaoEvento()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Eventos/Recomendações',
          style: TextStyle(color: Colors.white, fontSize: 24.0),
        ),
        backgroundColor: const Color(0xFF0DCAF0),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: areas.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedArea = areas[index];
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                    margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
                    decoration: BoxDecoration(
                      color: selectedArea == areas[index] ? Color(0xFF0DCAF0) : Colors.white,
                      borderRadius: BorderRadius.circular(20.0),
                      border: Border.all(color: Color(0xFF0DCAF0)),
                    ),
                    child: Center(
                      child: Text(
                        areas[index],
                        style: TextStyle(
                          color: selectedArea == areas[index] ? Colors.white : Color(0xFF0DCAF0),
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                final item = filteredItems[index];
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: item is Recomendacao
                      ? RecomendacaoCard(recomendacao: item)
                      : EventoCard(evento: item),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateOptions,
        child: Icon(Icons.add),
        backgroundColor: const Color(0xFF0DCAF0),
      ),
    );
  }
}
