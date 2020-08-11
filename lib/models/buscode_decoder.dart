import 'package:camera_tutorial/functions/buscode_processing.dart';
import 'package:flutter/material.dart';

class DecodedBusCode {
  List code;
  List<int> integers;
  String bin;
  String main;

  String formatId;
  String issuerCode;
  String equipmentId;
  String itemPriority;

  Map serialNumberMap;
  String hour;
  String month;
  String day;
  String minute;
  String serialNumber;

  String trackingIndicator;
  bool valid;

  String fullCode;

  bool success = false;

  DecodedBusCode({@required this.code}) {
    if (code.length == 75) {
      success = true;
      integers = busToIntegers(code);
      print(integers);

      bin = integers.map(to6Bin).reduce((a, b) => a + b);
      print(bin);

      main = bin.substring(0, 12) +
          bin.substring(18, 60) +
          bin.substring(138, 150);
      print(main);

      formatId = decodeFormatId(main.substring(0, 4));
      print(formatId);

      issuerCode = issuerCodeConversion(main.substring(4, 20));
      print(issuerCode);

      equipmentId = decodeEquipmentId(main.substring(20, 32));
      print(equipmentId);

      itemPriority = decodeItemPriority(main.substring(32, 34));
      print(itemPriority);

      serialNumberMap =
          processSerialNumber(main.substring(34, 54) + main.substring(56));
      month = serialNumberMap['month'];
      day = serialNumberMap['day'];
      hour = serialNumberMap['hour'];
      minute = serialNumberMap['minute'];
      serialNumber = serialNumberMap['serial'];
      print(serialNumberMap);
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
