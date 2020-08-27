import 'dart:async';
import 'package:camera_tutorial/functions/file_management.dart';
import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:camera_tutorial/models/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:camera_tutorial/widgets/buscode_card.dart';
import 'package:watcher/watcher.dart';
import 'package:image/image.dart' as imglib;

class LibraryScreen extends StatefulWidget {
  @override
  _LibraryScreenState createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  Stream<WatchEvent> _stream;
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
    _initStream();
  }

  _initStream() async {
    _stream = await fileEventStream();
    _stream.listen((fileEvent) {
      setState(() {
        if (fileEvent.type.toString() == 'remove') {
          for (var i = 0; i < _files.length; i++) {
            if (_files[i].path == fileEvent.path) {
              _files.removeAt(i);
            }
          }
        } else if (fileEvent.type.toString() == 'add') {
          imglib.Image image = readImage(fileEvent.path);
          BuscodeView view = readExifFile(image, fileEvent.path);
          _files.add(view);
        } else if (fileEvent.type.toString() == 'modify') {
          imglib.Image image = readImage(fileEvent.path);
          BuscodeView view = readExifFile(image, fileEvent.path);
          for (var i = 0; i < _files.length; i++) {
            if (_files[i].path == fileEvent.path) {
              _files[i] = view;
            }
          }
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.3,
        title: Text(
          'Buscode Library',
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              color: Colors.black87),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(Icons.camera),
        onPressed: () {
          Navigator.pushNamed(context, '/second');
        },
      ),
      body: Column(
        children: [
          Expanded(
            child: _filesFetched == true
                ? ListView.builder(
                    padding: EdgeInsets.only(bottom: 20),
                    itemCount: _files.isEmpty == true ? 1 : _files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return _files.isEmpty == true
                          ? Center(
                              child: Column(
                                children: [
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 40, bottom: 7),
                                    child: Image(
                                      height: 40,
                                      image: AssetImage(
                                          'lib/assets/cardboard.png'),
                                    ),
                                  ),
                                  Text('Your library is empty.'),
                                ],
                              ),
                            )
                          : BuscodeCard(
                              buscodeView: _files[index],
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
