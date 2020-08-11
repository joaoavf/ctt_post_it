import 'package:flutter/material.dart';

import '../data/buscode_maps.dart';

List<int> busToIntegers(buscode) {
  List<int> output = [];
  for (var i = 0; i < 25; i++) {
    var triad = buscode[i * 3] + buscode[i * 3 + 1] + buscode[i * 3 + 2];
    output.add(decoder[triad]);
  }
  return output;
}

String to6Bin(int integerInput) {
  String binary = integerInput.toRadixString(2);
  return '0' * (6 - binary.length) + '$binary';
}

String decodeFormatId(String formatId) {
  var position = int.parse(formatId, radix: 2);
  return 'J18' + 'ABCDEFGHIJKLMNOPQ'[position];
}

String issuerCodeConversion(String issuerCode) {
  int issuerCodeInt = int.parse(issuerCode, radix: 2);
  int l1 = issuerCodeInt ~/ 1600;
  int l2 = issuerCodeInt % 1600 ~/ 40;
  int l3 = issuerCodeInt % 1600 % 40;
  return issueCodeMap[l1] + issueCodeMap[l2] + issueCodeMap[l3];
}

String decodeEquipmentId(String equipmentId) {
  return int.parse(equipmentId, radix: 2).toRadixString(16);
}

String decodeItemPriority(String itemPriority) {
  return item_priority_map[itemPriority];
}

String fillZeros(String inputString, int stringLength) {
  return '0' * (stringLength - inputString.length) + inputString;
}

Map processSerialNumber(String serialNumberStr) {
  int serialNumber = int.parse(serialNumberStr, radix: 2);
  String serial = (serialNumber % 16384).toString();
  int datePart = serialNumber ~/ 16384;
  String month = (datePart ~/ 5120 + 1).toString();
  String day = (datePart % 5120 ~/ 160).toString();
  String hour = (datePart % 5120 % 160 ~/ 6).toString();
  String minute = (datePart % 5120 % 160 % 6).toString();
  Map returnMap = {
    'month': fillZeros(month, 2),
    'day': fillZeros(day, 2),
    'hour': fillZeros(hour, 2),
    'minute': fillZeros(minute, 2),
    'serial': fillZeros(serial, 5)
  };
  return returnMap;
}

String decodeTrackingIndicator(String trackingIndicator) {
  return tracking_indicator_map[trackingIndicator];
}

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
          serialNumber.toString();
    }
  }
}
