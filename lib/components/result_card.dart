import 'package:flutter/material.dart';
import 'package:camera_tutorial/models/buscode.dart';

class ItemResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(8),
      child: Column(
        children: [
          Text(
            'Date',
            style: TextStyle(fontSize: 14),
          ),
          Text(
            '16/06',
            style: TextStyle(fontSize: 30),
          )
        ],
      ),
    );
  }
}
