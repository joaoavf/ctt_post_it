import 'dart:io';
import 'package:camera_tutorial/functions/bar_type_identification.dart';
import 'package:camera_tutorial/functions/buscode_processing.dart';
import 'package:camera_tutorial/functions/reed_solomon.dart';
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
  print(path);
  return imglib.readJpg(File(path).readAsBytesSync());
}

void saveImage(imglib.Image img, String filename) async {
  final path = 'test/output_images';
  File('$path/$filename.jpg')..writeAsBytesSync(imglib.encodeJpg(img));
}

void main() {
  List files = getFilesList('test/test_images');
  for (var i = 0; i < files.length; i++) {
    String path = getPath(files[i].toString());
    imglib.Image image = readImage(path);

    var code = readBuscode(image);

    print(code);
    if (code.length == 75) {
      List<int> integers = busToIntegers(code);
      List<int> reedSolomonMsg = reorderRS(integers);
      print(reedSolomonMsg);
      integers = [];
      print(reedSolomonMsg.length);
      List<int> correctMsg = rsCorrectMessage(reedSolomonMsg);
      print('correctMsg');
      print(correctMsg);
    }


  }
}
