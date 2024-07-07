import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../pages/HomePage.dart';
import '../pages/MapPage.dart';
import '../pages/ProfilePage.dart';
import '../pages/SearchPage.dart';
import '../pages/AddPage.dart';
import '../pages/EventoViewData.dart';
import '../pages/RecomendacaoViewData.dart';

class BarraDeNavegacao extends StatefulWidget {
  const BarraDeNavegacao({Key? key}) : super(key: key);

  @override
  _BarraDeNavegacaoState createState() => _BarraDeNavegacaoState();
}

class _BarraDeNavegacaoState extends State<BarraDeNavegacao> {
  int _selectedIndex = 0;

  static List<Widget> _telas = [
    HomePage(),
    SearchPage(),
    RecomendacaoViewData(),
    MapPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    print("Item Tapped: $index");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _telas,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        height: 50.0,
        items: <Widget>[
          Icon(Icons.home, size: 30),
          Icon(Icons.search, size: 30),
          Icon(Icons.local_activity, size: 30),
          Icon(Icons.map, size: 30),
          Icon(Icons.person, size: 30),
        ],
        color: Color(0xFF0DCAF0),
        buttonBackgroundColor: Colors.white,
        backgroundColor: _selectedIndex == 3 ? Colors.transparent : Colors.white,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: _onItemTapped,
        letIndexChange: (index) => true,
      ),
    );
  }
}
