import 'dart:io';
import 'package:camera_tutorial/functions/new_image_processing.dart';
import 'package:image/image.dart' as imglib;

List getFilesList(folder) {
  final dir = Directory(folder);
  return dir.listSync(recursive: false).toList();
}

String getPath(String path) {
  path = path.substring(7, path.length - 1).replaceAll('\\', '/');
  String curDir = Directory.current.toString();
  curDir = curDir.substring(12, curDir.length - 1).replaceAll('\\', '/');
  path = curDir + '/' + path;
  return path;
}

imglib.Image readImage(path) {
  return imglib.readPng(File(path).readAsBytesSync());
}

void saveImage(imglib.Image img, String filename) async {
  final path = 'test/output_images';
  File('$path/$filename.jpg')..writeAsBytesSync(imglib.encodeJpg(img));
}

void main() {
  List files = getFilesList('test/test_images');
  for (var i = 0; i < 10; i++) {
    String path = getPath(files[i].toString());
    imglib.Image image = readImage(path);
    var code = altReadBuscode(image);
    print(code);

    path = path.substring(66, path.length - 4).replaceAll('\\', '/');
    print(path);
    saveImage(image, path + 'proc');
  }
}
