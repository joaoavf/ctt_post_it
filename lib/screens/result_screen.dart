import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';
import 'package:camera_tutorial/components/bottom_navigation_bar.dart';
import 'package:camera_tutorial/components/result_card.dart';

class ResultScreen extends StatelessWidget {
  final Buscode buscode;
  ResultScreen({Key key, @required this.buscode}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF6F6F6),
      body: SafeArea(
        child: GridView.count(
          crossAxisCount: 2,
          children: [
            ItemResultCard(),
            ItemResultCard(),
            ItemResultCard(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(),
    );
  }
}
