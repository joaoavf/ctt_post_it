import 'dart:io';
import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:camera_tutorial/models/buscode.dart';
import 'package:camera_tutorial/models/exif.dart';
import 'package:camera_tutorial/functions/galois_field.dart';
import 'package:camera_tutorial/functions/reed_solomon.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as imglib;
import 'dart:convert';
import 'dart:typed_data';

/// Exif data stored with an image.
class ExifData {
  static const CAMERA_MAKE = 0x010F; // string
  static const CAMERA_MODEL = 0x0110; // string
  static const DATE_TIME = 0x0132; // string
  static const ORIENTATION = 0x0112; // int

  List<Uint8List> rawData;
  Map<int, dynamic> data;

  ExifData() : data = <int, dynamic>{};

  ExifData.from(ExifData other)
      : data = (other == null)
            ? <int, dynamic>{}
            : Map<int, dynamic>.from(other.data) {
    if (other != null && other.rawData != null) {
      rawData = List<Uint8List>(other.rawData.length);
      for (var i = 0; i < other.rawData.length; ++i) {
        rawData[i] = other.rawData[i].sublist(0);
      }
    }
  }

  bool get hasRawData => rawData != null && rawData.isNotEmpty;

  bool get hasOrientation => data.containsKey(ORIENTATION);

  int get orientation => data[ORIENTATION] as int;

  set orientation(int value) => data[ORIENTATION] = value;
}

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
    print(testReadBuscode(image, path));
    Buscode(image: image);
  }
}

Map firstBinaryMap =
    json.decode(File('test/maps/firstBinaryMap.json').readAsStringSync());
Map convMap = json.decode(File('test/maps/convMap.json').readAsStringSync());
Map secondBinaryMap =
    json.decode(File('test/maps/secondBinaryMap.json').readAsStringSync());
Map reducedFullListMap =
    json.decode(File('test/maps/reducedFullListMap.json').readAsStringSync());
Map reducedUpperListMap =
    json.decode(File('test/maps/reducedUpperListMap.json').readAsStringSync());
Map codeMap = json.decode(File('test/maps/codeMap.json').readAsStringSync());

List testReadBuscode(imglib.Image image, String path) {
  String rm =
      'C:/Users/joaoa/AndroidStudioProjects/time_tracker_flutter_course/bus_code_reader/test/test_images/';
  path = path.substring(rm.length);
  var height = image.height;
  var width = image.width;
  var stride = 4;

  var img_1d = toBW(image);

  img_1d = toBinaryColor(img_1d);

  img_1d = conv2d(img_1d, stride, height, width);

  img_1d = convMap[path];

  img_1d = toBinaryColor(img_1d);

  img_1d = secondBinaryMap[path];

  List<List> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  splitedList = extractBuscode(splitedList);

  List counters = [];

  var idealLen = reducedFullListMap[path].length;

  List<String> code = from1dToBuscode(splitedList[0], splitedList[1]);

  return code;
}

imglib.Image readImage(path) {
  return imglib.readJpg(File(path).readAsBytesSync());
}

void saveImage(imglib.Image img) async {
  final path = 'test/output_images';
  File('$path/sample.jpg')..writeAsBytesSync(imglib.encodeJpg(img));
}

void syncExif() async {
  print('1');
  AsciiCodec codec = AsciiCodec();
  print(codec.encode('J18C'));

  TestWidgetsFlutterBinding.ensureInitialized();
  print('2');
  final Uint8List imageData =
      File('test/output_images/flower.jpg').readAsBytesSync();

  var raw = imglib.readJpg(imageData).exif.rawData;

  final Uint8List imageData2 =
      File('test/test_images/photo_2020-08-14_20-02-06.jpg').readAsBytesSync();

  Buscode buscode = Buscode(image: imglib.readJpg(imageData2));
  print(buscode.serialNumber);
  print(buscode.serialNumberMap);
  Exif exifObject = Exif(buscode: buscode);

  var jpg = imglib.readJpg(imageData2);
  jpg.exif.rawData = exifObject.bytes;
  var w = raw[0];
  var y = w[0];
  var yy = w[1];
  File('test/output_images/sioux.jpg')..writeAsBytesSync(imglib.encodeJpg(jpg));

  //log(raw.toList().toString());

  print('sioux');
  print(imglib
      .readJpg(File('test/output_images/sioux.jpg').readAsBytesSync())
      .exif
      .data);

}

printBlock(message_in, message) {
  bool isCode = false;
  for (int i = 0; i < message.length; i++) {
    if (i != 0) {
      stdout.write(" ");
    }
    if (i >= message_in.length && isCode == false) {
      isCode = true;
      stdout.write("\n");
    }
    stdout.write("$message");
  }
  print("");
}

testReedSolomon() {
  Stopwatch sw = new Stopwatch();
  sw.start();
  initTables();

  List<int> message_in = [8, 63, 22, 34, 17, 20, 61, 46, 23, 48, 38, 48, 43];
  int k = 12;
  List<int> msg = rsEncodeMessage(message_in, k);

  printBlock(message_in, msg);
  print("");

  msg[0] = 0;

  printBlock(message_in, msg);
  print("");

  msg = rsCorrectMessage(msg);

  printBlock(message_in, msg);

  sw.stop();
  print("time: ${sw.elapsed}");
}

void main() {
  List files = getFilesList('test/test_images');
  for (var i = 0; i < files.length; i++) {
    String path = getPath(files[i].toString());
    imglib.Image image = readImage(path);
    syncExif();

    imglib.Image transformedImage = readImage('test/output_images/sample.jpg');
  }
}
