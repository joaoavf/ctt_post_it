import 'package:flutter/material.dart';
import 'package:camera_tutorial/widgets/buscode_card.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20, top: 10, right: 20, bottom: 20),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                BuscodeCard(),
                BuscodeCard(),
                BuscodeCard(),
                BuscodeCard(),
                BuscodeCard(),
              ],
            ),
          )
        ],
      ),
    );
  }
}
