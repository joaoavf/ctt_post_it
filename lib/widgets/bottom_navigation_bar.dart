import 'package:flutter/material.dart';

class BottomNavigation extends StatefulWidget {
  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      onTap: _onItemTapped,
      currentIndex: _selectedIndex,
      backgroundColor: Colors.white,
      selectedItemColor: Theme.of(context).primaryColor,
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          title: Text('Scan'),
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Search'))
      ],
    );
  }
}
