import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../pages/HomePage.dart';
import '../pages/MapPage.dart';
import '../pages/ProfilePage.dart';
import '../pages/ListaGenerica.dart';
import '../pages/ListaForuns.dart';

class BarraDeNavegacao extends StatefulWidget {
  final int selectedIndex;

  const BarraDeNavegacao({Key? key, this.selectedIndex = 0}) : super(key: key);

  @override
  _BarraDeNavegacaoState createState() => _BarraDeNavegacaoState();
}

class _BarraDeNavegacaoState extends State<BarraDeNavegacao> {
  late int _selectedIndex;

  static List<Widget> _telas = [];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.selectedIndex; // Use o índice passado
    _telas = [
      HomePage(onItemTapped: _onItemTapped),
      ListaForuns(),
      ListaGenerica(),
      MapPage(),
      ProfilePage(),
    ];
  }

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
          Icon(Icons.forum, size: 30),
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
