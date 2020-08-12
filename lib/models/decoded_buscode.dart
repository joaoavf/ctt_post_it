import 'package:camera_tutorial/functions/buscode_processing.dart';
import 'package:flutter/material.dart';

class DecodedBuscode {
  // Broad data
  List code;
  List<int> integers;
  String bin;
  String main;

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

  // Other
  String trackingIndicator;
  bool valid;
  String fullCode;
  bool success = false;

  DecodedBuscode({@required this.code}) {
    if (code.length == 75) {
      success = true;
      integers = busToIntegers(code);

      bin = integers.map(to6Bin).reduce((a, b) => a + b);

      main = bin.substring(0, 12) +
          bin.substring(18, 60) +
          bin.substring(138, 150);

      formatId = decodeFormatId(main.substring(0, 4));
      issuerCode = issuerCodeConversion(main.substring(4, 20));
      equipmentId = decodeEquipmentId(main.substring(20, 32));
      itemPriority = decodeItemPriority(main.substring(32, 34));

      serialNumberMap =
          processSerialNumber(main.substring(34, 54) + main.substring(56));

      month = serialNumberMap['month'];
      day = serialNumberMap['day'];
      hour = serialNumberMap['hour'];
      minute = serialNumberMap['minute'];
      serialNumber = serialNumberMap['serial'];

      trackingIndicator = decodeTrackingIndicator(main.substring(54, 56));

      fullCode = formatId +
          issuerCode +
          equipmentId +
          itemPriority +
          month +
          day +
          hour +
          minute +
          serialNumber +
          trackingIndicator;
    }
  }
}
