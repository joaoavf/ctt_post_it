import 'dart:io';
import 'dart:async';
import 'package:camera_tutorial/models/buscode_view.dart';
import 'package:camera_tutorial/models/exif.dart';
import 'package:path_provider/path_provider.dart';
import 'package:watcher/watcher.dart';
import 'package:image/image.dart' as imglib;

String directory;
List file = new List();

List getFilesList(folder) {
  final dir = Directory(folder);
  return dir.listSync(recursive: false).toList();
}

String cleanPath(String path) {
  path = path.substring(7, path.length - 1).replaceAll('\\', '/');
  return path;
}

imglib.Image readImage(path) {
  return imglib.readJpg(File(path).readAsBytesSync());
}

//Get the path to the directory where the images are saved.
Future<String> get localPath async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else if (Platform.isIOS) {
    directory = await getApplicationDocumentsDirectory();
  }
  final String path = directory.path;
  return path;
}

//Returns a list of Files contained in the directory where the images are saved.
Future<List> _getFiles() async {
  String path = await localPath;
  return Directory("$path").listSync();
}

//Reads and decodes the images metadata and returns a list of BuscodeViews.
Future<List<BuscodeView>> readStoredBuscodes() async {
  BuscodeView buscodeView;
  List<BuscodeView> listBuscodeView = [];
  List files = await _getFiles();
  for (var i = 0; i < files.length; i++) {
    String path = cleanPath(files[i].toString());
    print('path');
    print(path);
    imglib.Image image = readImage(path);
    buscodeView = readExifFile(image, path);
    listBuscodeView.add(buscodeView);
  }
  return listBuscodeView;
}

//Creates an Stream to watch for changes in the directory where the images are saved.
Future<Stream<WatchEvent>> fileEventStream() async {
  final Directory directory = await getExternalStorageDirectory();
  PollingDirectoryWatcher watcher = DirectoryWatcher(directory.path);
  return watcher.events;
}

void saveImage(imglib.Image img, String path) async {
  File(path)..writeAsBytesSync(imglib.encodeJpg(img));
}
