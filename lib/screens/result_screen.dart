import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';
import '../models/buscode_decoder.dart';
import 'package:camera_tutorial/components/bottom_navigation_bar.dart';

class ResultScreen extends StatelessWidget {
  final Buscode buscode;

  ResultScreen({Key key, @required this.buscode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            Column(
              children: [
                Text('Date'),
                Text(buscode.decoded.day),
              ],
            ),
            Column(
              children: [
                Text('Hour'),
                Text(buscode.decoded.hour),
              ],
            ),
            Column(
              children: [
                Text('Equipment Id'),
                Text(buscode.decoded.equipmentId),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
