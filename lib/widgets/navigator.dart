import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:camera_tutorial/screens/camera_screen.dart';
import 'package:camera_tutorial/screens/library_screen.dart';
import 'package:camera_tutorial/screens/result_screen.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // This navigator state will be used to navigate different pages
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Navigator(key: _navigatorKey, onGenerateRoute: generateRoute),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  Widget _bottomNavigationBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      selectedItemColor: Theme.of(context).primaryColor,
      type: BottomNavigationBarType.fixed,
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.camera),
          title: Text('Scan'),
        ),
        BottomNavigationBarItem(icon: Icon(Icons.search), title: Text('Search'))
      ],
      onTap: _onTap,
      currentIndex: _currentTabIndex,
    );
  }

  _onTap(int tabIndex) {
    switch (tabIndex) {
      case 0:
        _navigatorKey.currentState.pushReplacementNamed('Scan');
        break;
      case 1:
        _navigatorKey.currentState.pushReplacementNamed('Library');
        break;
    }
    setState(() {
      _currentTabIndex = tabIndex;
    });
  }

  Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case 'Scan':
        return MaterialPageRoute(builder: (context) => CameraScreen());
      case 'Library':
        return MaterialPageRoute(builder: (context) => LibraryScreen());
      case 'Result':
        return MaterialPageRoute(builder: (context) => ResultScreen());
      default:
        return MaterialPageRoute(builder: (context) => CameraScreen());
    }
  }
}
