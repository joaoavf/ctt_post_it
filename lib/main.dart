import 'package:camera_camera/camera_camera.dart';
import 'package:camera_tutorial/screens/result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/camera_screen.dart';
import 'screens/library_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Buscode Reader',
      theme: ThemeData(
        primaryColor: Color(0xffCE2B2F),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(0xffF6F6F6),
      ),
      home: LibraryScreen(),
    );
  }
}
