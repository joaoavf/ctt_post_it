import 'package:flutter/material.dart';
import 'package:camera_tutorial/screens/camera_screen.dart';
import 'package:camera_tutorial/screens/library_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent-tab-view.dart';

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      screens: _screens(),
      items: _navBarItems(),
      confineInSafeArea: true,
      stateManagement: true,
      handleAndroidBackButtonPress: true,
      resizeToAvoidBottomInset: true,
      navBarStyle: NavBarStyle.style3,
      popAllScreensOnTapOfSelectedTab: true,
    );
  }

  List<Widget> _screens() {
    return [
      CameraScreen(),
      LibraryScreen(),
    ];
  }

  List<PersistentBottomNavBarItem> _navBarItems() {
    return [
      PersistentBottomNavBarItem(
        icon: Icon(Icons.camera),
        title: ("Scan"),
        activeColor: Color(0xffCE2B2F),
        inactiveColor: Colors.black38,
      ),
      PersistentBottomNavBarItem(
        icon: Icon(Icons.local_library),
        title: ("Library"),
        activeColor: Color(0xffCE2B2F),
        inactiveColor: Colors.black38,
      ),
    ];
  }
}
