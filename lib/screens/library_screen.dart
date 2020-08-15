import 'package:flutter/material.dart';
import 'package:camera_tutorial/widgets/bottom_navigation_bar.dart';
import 'package:camera_tutorial/widgets/buscode_card.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigation(),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 26, horizontal: 20),
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
      ),
    );
  }
}
