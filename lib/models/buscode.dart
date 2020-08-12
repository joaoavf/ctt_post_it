import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:camera_tutorial/models/decoded_buscode.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class Buscode {
  imglib.Image buscodeImage;
  List<String> code;
  DecodedBuscode decoded;

  Buscode({@required this.buscodeImage}) {
    code = readBuscode(buscodeImage);
    decoded = DecodedBuscode(code: code);
  }
}
