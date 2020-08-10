import 'package:flutter/material.dart';

class BottomNavigation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xffCE2B2F),
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
