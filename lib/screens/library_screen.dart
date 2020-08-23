import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

import 'package:camera_tutorial/widgets/buscode_card.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin {
  String directory;
  List file = new List();

  void _getFiles() async {
    directory = (await getExternalStorageDirectory()).path;
    print(directory);
    setState(() {
      file = io.Directory("$directory").listSync();
    });
  }

  void initState() {
    super.initState();
    _getFiles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: file.length,
              itemBuilder: (BuildContext context, int index) {
                return Text(
                  file[index].toString(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
