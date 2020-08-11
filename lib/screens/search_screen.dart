import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            child: Image(
              image: AssetImage('lib/assets/buscode'),
            ),
          ),
          GridView.count(crossAxisCount: 2)
        ],
      ),
    );
  }
}
