import 'dart:io';

import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:camera_tutorial/models/exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as imglib;

String directory;
List file = new List();

List getFilesList(folder) {
  final dir = Directory(folder);
  return dir.listSync(recursive: false).toList();
}

String getPath(String path) {
  path = path.substring(7, path.length - 1).replaceAll('\\', '/');
  return path;
}

imglib.Image readImage(path) {
  return imglib.readJpg(File(path).readAsBytesSync());
}

Future<List> _getFiles() async {
  directory = (await getExternalStorageDirectory()).path;
  return Directory("$directory").listSync();
}

Future<List<BuscodeView>> readStoredBuscodes() async {
  BuscodeView buscodeView;
  List<BuscodeView> listBuscodeView = [];
  List files = await _getFiles();
  for (var i = 0; i < files.length; i++) {
    String path = getPath(files[i].toString());
    imglib.Image image = readImage(path);
    buscodeView = readExifFile(image);
    listBuscodeView.add(buscodeView);
  }
  return listBuscodeView;
}
