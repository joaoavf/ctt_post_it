import 'package:camera_tutorial/functions/image_processing.dart';
import 'package:flutter/material.dart';
import 'package:camera_tutorial/functions/buscode_processing.dart';
import 'package:image/image.dart' as imglib;

class Buscode {
  // Broad data
  List<String> code;
  imglib.Image image;
  List<int> integers;
  String bin;

  Map data;

  operator [](index) => data[index];

  // Specific Data
  String formatId;
  String issuerCode;
  String equipmentId;
  String itemPriority;

  // Time Related Data
  Map serialNumberMap;
  String hour;
  String month;
  String day;
  String minute;
  String serialNumber;

  String photoDate;
  String buscodeDate;

  // Other
  String trackingIndicator;
  bool valid;
  String idTag;
  bool success = false;

  Buscode({@required this.image}) {
    code = readBuscode(image);
    Map codeEval = evaluateCode(code);
    if (codeEval['is_valid'] == true) {
      integers = codeEval['code'];

      success = true;

      integers = integers.sublist(0, 2)
        ..addAll(integers.sublist(3, 10))
        ..addAll(integers.sublist(11, 13));

      bin = integers.map(to6Bin).reduce((a, b) => a + b);

      formatId = decodeFormatId(bin.substring(0, 4));
      issuerCode = issuerCodeConversion(bin.substring(4, 20));
      equipmentId = decodeEquipmentId(bin.substring(20, 32));
      itemPriority = decodeItemPriority(bin.substring(32, 34));

      serialNumberMap =
          processSerialNumber(bin.substring(34, 54) + bin.substring(56));

      month = serialNumberMap['month'];
      day = serialNumberMap['day'];
      hour = serialNumberMap['hour'];
      minute = serialNumberMap['minute'];
      serialNumber = serialNumberMap['serial'];

      trackingIndicator = decodeTrackingIndicator(bin.substring(54, 56));

      idTag = formatId +
          issuerCode +
          equipmentId +
          itemPriority +
          month +
          day +
          hour +
          minute +
          serialNumber +
          trackingIndicator;

      photoDate =
          DateTime.now().toString().replaceAll('-', ':').substring(0, 19);
      buscodeDate =
          '2000:' + month + ':' + day + ' ' + hour + ':0' + minute + ':00';

      data = {
        'formatId': formatId,
        'issuerCode': issuerCode,
        'equipmentId': equipmentId,
        'buscodeDate': buscodeDate,
        'photoDate': photoDate,
        'serialNumber': serialNumber,
        'itemPriority': itemPriority,
        'trackingIndicator': trackingIndicator,
      };
    }
  }
}
