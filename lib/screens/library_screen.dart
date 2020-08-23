import 'package:camera_tutorial/functions/file_management.dart';
import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:flutter/material.dart';

import 'package:camera_tutorial/widgets/buscode_card.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with AutomaticKeepAliveClientMixin {
  String directory;
  List<BuscodeView> file = new List();

  void _getFiles() async {
    List<BuscodeView> _tmp = await readStoredBuscodes();
    setState(() {
      file = _tmp;
    });
    print(file);
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
                return Column(
                    children: file
                        .map((buscode) => BuscodeCard(
                              buscode: buscode,
                            ))
                        .toList());
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
