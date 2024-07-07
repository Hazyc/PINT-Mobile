import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<Map<String, String>> items = [];
  List<Map<String, String>> publications = [
    {'title': 'Publicação 1', 'description': 'Descrição da Publicação 1'},
    {'title': 'Publicação 2', 'description': 'Descrição da Publicação 2'},
    {'title': 'Publicação 3', 'description': 'Descrição da Publicação 3'}
  ];
  List<Map<String, String>> events = [
    {'title': 'Evento 1', 'description': 'Descrição do Evento 1'},
    {'title': 'Evento 2', 'description': 'Descrição do Evento 2'},
    {'title': 'Evento 3', 'description': 'Descrição do Evento 3'}
  ];
  bool isPublicationsSelected = true;

  @override
  void initState() {
    super.initState();
    // Use Future.delayed to avoid calling setState directly in initState
    Future.delayed(Duration.zero, () {
      _showPublications();
    });
  }

  void _showPublications() {
    setState(() {
      isPublicationsSelected = true;
      items = publications;
    });
  }

  void _showEvents() {
    setState(() {
      isPublicationsSelected = false;
      items = events;
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
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Image.network(
                  'https://static.todamateria.com.br/upload/pa/is/paisagem-natural-og.jpg',
                  width: double.infinity,
                  height: 150.0,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 10.0,
                  right: 10.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 200, 200, 200),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(Icons.edit, color: Colors.white),
                      onPressed: () {
                        // Ação futura para mudar o banner
                      },
                    ),
                  ),
                ),
                Positioned(
                  top: 90.0,
                  left: MediaQuery.of(context).size.width / 2 - 60,
                  child: CircleAvatar(
                    radius: 60.0,
                    backgroundImage: NetworkImage(
                      'https://via.placeholder.com/120',
                    ),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt, size: 18.0),
                          onPressed: () {
                            // Ação futura para mudar a foto de perfil
                          },
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 60.0),
            const Text(
              'José',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
            SizedBox(height: 4.0),
            const Text(
              'Viseu | Programador',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 4.0),
            const Text(
              'Louco por futebol e natação',
              style: TextStyle(fontSize: 16.0, color: Colors.grey),
            ),
            SizedBox(height: 20.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _showPublications,
                  child: Text(
                    'Publicações',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: isPublicationsSelected ? FontWeight.bold : FontWeight.normal,
                      color: isPublicationsSelected ? Colors.black : Colors.grey,
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
                      fontWeight: !isPublicationsSelected ? FontWeight.bold : FontWeight.normal,
                      color: !isPublicationsSelected ? Colors.black : Colors.grey,
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15.0), // Cantos arredondados
                    ),
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            items[index]['title']!,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10.0),
                          Text(
                            items[index]['description']!,
                            style: TextStyle(
                              fontSize: 14.0,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
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
    );
  }
}
