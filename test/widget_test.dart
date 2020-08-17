import 'dart:io';
import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:image/image.dart' as imglib;

void printFiles() {
  String folder = 'test/test_images';
  final dir = Directory(folder);
  final List files = dir.listSync(recursive: false).toList();
  for (var i = 0; i < files.length; i++) {
    String path = files[i].toString();
    path = path.substring(7, path.length - 1).replaceAll('\\', '/');
    String curDir = Directory.current.toString();
    curDir = curDir.substring(12, curDir.length - 1).replaceAll('\\', '/');
    path = curDir + '/' + path;
    imglib.Image img = readImage(path);
    print(path);
    print(readBuscode(img));
  }
}

imglib.Image readImage(path) {
  var intermediate = File(path).readAsBytesSync();
  var output = imglib.readJpg(intermediate);
  return output;
}

void main() {
  printFiles();
}
