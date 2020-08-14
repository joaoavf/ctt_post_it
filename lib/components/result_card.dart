import 'package:flutter/material.dart';
import 'package:camera_tutorial/models/buscode.dart';

class ItemResultCard extends StatelessWidget {
  final String title;
  final String buscodeInformation;

  ItemResultCard({this.title, this.buscodeInformation});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      alignment: Alignment.topLeft,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(2),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              title,
              style: TextStyle(fontSize: 14),
            ),
          ),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              buscodeInformation,
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 30),
            ),
          )
        ],
      ),
    );
  }
}
