import 'dart:convert';
import 'dart:typed_data';

import 'package:camera_tutorial/data/exif_sample.dart';
import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter/material.dart';

class Exif {
  final List<Uint8List> bytes = sampleExif;
  final AsciiCodec codec = AsciiCodec();

  Exif({@required Buscode buscode}) {
    setFormatId(buscode.formatId);
    setIssuerCode(buscode.issuerCode);
    setEquipmentId(buscode.equipmentId);
    setBuscodeDate(buscode.buscodeDate);
    setPhotoDate(buscode.photoDate);
    setSerialNumber(buscode.serialNumber);
    setItemPriority(buscode.itemPriority);
    setTrackingIndicator(buscode.trackingIndicator);
  }

  void setBytes({String string, int start}) {
    List<int> numbers = codec.encode(string);
    for (var i = start; i < start + numbers.length; i++) {
      bytes[0][i] = numbers[i - start];
    }
  }

  void setFormatId(String formatId) {
    assert(formatId.length == 4);
    setBytes(string: formatId, start: 42);
  }

  void setIssuerCode(String issuerCode) {
    assert(issuerCode.length == 3);
    setBytes(string: issuerCode, start: 102);
  }

  void setTrackingIndicator(String trackingIndicator) {
    assert(trackingIndicator.length == 1);
    setBytes(string: trackingIndicator, start: 126);
  }

  void setEquipmentId(String equipmentId) {
    assert(equipmentId.length == 3);
    setBytes(string: equipmentId, start: 79);
  }

  void setBuscodeDate(String buscodeDate) {
    assert(buscodeDate.length == 19);
    setBytes(string: buscodeDate, start: 150);
  }

  void setPhotoDate(String photoDate) {
    assert(photoDate.length == 19);
    setBytes(string: photoDate, start: 130);
  }

  void setItemPriority(String itemPriority) {
    assert(itemPriority.length == 1);
    setBytes(string: itemPriority, start: 90);
  }

  void setSerialNumber(String serialNumber) {
    assert(serialNumber.length == 5);
    setBytes(string: serialNumber, start: 170);
  }
}
