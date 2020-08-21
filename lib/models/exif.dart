import 'dart:convert';
import 'dart:typed_data';
import 'package:camera_tutorial/data/exif_sample.dart';
import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';

class Exif {
  final List<Uint8List> bytes = sampleExif;
  final AsciiCodec codec = AsciiCodec();

  Exif({@required Buscode buscode}) {
    buscodeExifMap.forEach((key, value) =>
        setBytes(
            string: buscode[key],
            start: value['start'],
            length: value['length']));
  }

  void setBytes({String string, int start, int length}) {
    assert(string.length == length);
    List<int> numbers = codec.encode(string);
    for (var i = start; i < start + length; i++) {
      bytes[0][i] = numbers[i - start];
    }
  }
}

readExifFile(List<int> bytes) {
  String decoded;
  Map newMap = {};
  buscodeExifMap.forEach((key, value) {
    decoded = readBytes(
        bytes: bytes, start: value['start'], length: value['length']);
    newMap[key] = decoded;
  });
  return newMap;
}


readBytes({List<int> bytes, int start, int length}) {
  final AsciiCodec codec = AsciiCodec();
  return codec.decode(bytes.sublist(start, start + length));
}
