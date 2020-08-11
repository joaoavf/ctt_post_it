import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:camera_tutorial/models/buscode_decoder.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

class Buscode {
  imglib.Image buscodeImage;
  List<String> code;
  DecodedBusCode decoded;

  Buscode({@required this.buscodeImage}) {
    code = readBuscode(buscodeImage);
    decoded = DecodedBusCode(code: code);
  }
}
