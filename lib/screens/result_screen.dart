import 'package:flutter/material.dart';
import 'package:camera_tutorial/functions/buscode_decoder.dart';
import 'package:camera_tutorial/components/bottom_navigation_bar.dart';

class ResultScreen extends StatelessWidget {
  final DecodedBusCode decodedBusCode;
  ResultScreen({Key key, @required this.decodedBusCode}) : super(key: key);

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
                Text(decodedBusCode.day + '/' + decodedBusCode.month),
              ],
            ),
            Column(
              children: [
                Text('Hour'),
                Text(decodedBusCode.hour + ':' + decodedBusCode.minute),
              ],
            ),
            Column(
              children: [
                Text('Equipment Id'),
                Text(decodedBusCode.equipmentId),
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
