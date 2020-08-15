import 'package:flutter/material.dart';

class BuscodeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(
            children: [
              Column(
                children: [
                  Text('Date and time', style: TextStyle(fontSize: 10)),
                ],
              ),
            ],
          )
        ],
      ),
    );
  }
}
