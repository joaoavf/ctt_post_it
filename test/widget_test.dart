import 'dart:io';
import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:image/image.dart' as imglib;
import 'dart:developer';

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

void printFiles() {
  List files = getFilesList('test/test_images');
  for (var i = 0; i < files.length; i++) {
    String path = getPath(files[i].toString());
    imglib.Image image = readImage(path);
    print(path);
    print(readBuscode(image));
  }
}

Map firstBinaryMap = {};
Map convMap = {};
Map secondBinaryMap = {};
Map reducedFullListMap = {};
Map reducedUpperListMap = {};
Map codeMap = {};

void testReadBuscode(imglib.Image image, String path) {
  String rm = 'C:/Users/joaoa/AndroidStudioProjects/time_tracker_flutter_course/bus_code_reader/test/test_images/';
  path = path.substring(rm.length);
  var height = image.height;
  var width = image.width;
  var stride = 4;

  var img_1d = toBinary(image);

  assert(img_1d == firstBinaryMap[path]);

  img_1d = conv2d(img_1d, stride, height, width);

  assert(img_1d == convMap[path]);

  img_1d = toBinaryColor(img_1d);

  assert(img_1d == secondBinaryMap[path]);

  List<List> splitedList =
  splitList(img_1d, height - stride + 1, width - stride + 1);

  splitedList = extractBuscode(splitedList);

  assert(splitedList[0] == reducedFullListMap[path]);
  assert(splitedList[1] == reducedUpperListMap[path]);

  List<String> code = from1dToBuscode(splitedList[0], splitedList[1]);

  assert(code = codeMap[path]);

//  List rotations = [0.5, -0.5];
//
////  for (var i = 0; i < rotations.length; i++) {
//    if (code.length != 75 && primitive) {
//      code = readBuscode(imglib.copyRotate(image, rotations[i]),
//          primitive: false);
//    }
}

imglib.Image readImage(path) {
  return imglib.readJpg(File(path).readAsBytesSync());
}

void main() {
  printFiles();
}
