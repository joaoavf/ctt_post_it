import 'package:camera_tutorial/functions/file_management.dart';
import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:camera_tutorial/widgets/buscode_card.dart';

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  bool _filesFetched;
  String directory;
  List<BuscodeView> _files = new List();

  void _getFiles() async {
    try {
      List<BuscodeView> _tmp = await readStoredBuscodes();
      setState(() {
        _files = _tmp;
        _filesFetched = true;
      });
    } catch (e) {
      print(e);
    }
  }

  void initState() {
    super.initState();
    _getFiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          AppBar(
            backgroundColor: Colors.white,
            elevation: 0.3,
            title: Text(
              'Buscode Library',
              style: TextStyle(color: Colors.black54),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black54),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
          ),
          Expanded(
            child: _filesFetched == true
                ? ListView.builder(
                    padding: EdgeInsets.only(bottom: 20),
                    itemCount: _files.isEmpty == true ? 1 : _files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _files.isEmpty == true
                          ? Center(child: Text('Your library is empty.'))
                          : BuscodeCard(
                              buscode: _files[index],
                            );
                    },
                  )
                : Center(
                    child: SpinKitWave(
                      color: Theme.of(context).primaryColor,
                      size: 30,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
