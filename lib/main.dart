import 'package:camera_tutorial/screens/camera_screen.dart';
import 'package:camera_tutorial/screens/library_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
      debugShowCheckedModeBanner: false,
      title: 'Buscode Reader',
      theme: ThemeData(
        primaryColor: Color(0xffDE0025),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Color(0xffF6F6F6),
      ),
      routes: {
        '/': (context) => LibraryScreen(),
        '/second': (context) => CameraScreen(),
      },
    );
  }
}
