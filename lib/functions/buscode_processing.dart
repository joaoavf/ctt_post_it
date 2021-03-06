import 'package:camera_tutorial/data/buscode_maps.dart';
import 'package:camera_tutorial/functions/reed_solomon.dart';

// First 13 digits are the original message, next 12 are correction numbers.
reorderRS(List<int> integers) {
  return integers.sublist(0, 10)
    ..addAll(integers.sublist(22, 25))
    ..addAll(integers.sublist(10, 22));
}

String to6Bin(int integerInput) {
  String binary = integerInput.toRadixString(2);
  return '0' * (6 - binary.length) + '$binary';
}

String decodeFormatId(String formatId) {
  var position = int.parse(formatId, radix: 2);
  return 'J18' + 'ABCDEFGHIJKLMNOPQ'[position];
}

// Checks from which country is the code.
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

// Complete with leftmost zeros, as some of the fields require such technique
String fillZeros(String inputString, int stringLength) {
  return '0' * (stringLength - inputString.length) + inputString;
}

// Turns bits into date and serial number
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
    'minute': fillZeros(minute, 1),
    'serial': fillZeros(serial, 5)
  };
  return returnMap;
}

String decodeTrackingIndicator(String trackingIndicator) {
  return tracking_indicator_map[trackingIndicator];
}

// Rotate code in case the picture was taken upside down.
List<String> rotateCode(List code) {
  Map charMap = {'A': 'D', 'D': 'A', 'T': 'T', 'F': 'F'};
  List<String> newCode = [];
  for (var i = code.length - 1; i >= 0; i--) {
    newCode.add(charMap[code[i]]);
  }
  return newCode;
}

// Checks if it is a valid ReedSolomon code, returns null if not
Map evaluateCode(code, {isRotate = false}) {
  if (code.length != 75) {
    return {'is_valid': false};
  }
  List<int> integers = busToIntegers(code);
  List<int> reedSolomonMsg = reorderRS(integers);

  reedSolomonMsg[2] = 22; // Attribute Syncs to improve readability
  reedSolomonMsg[10] = 38;
  List<int> correctMsg = rsCorrectMessage(reedSolomonMsg);

  if (correctMsg == null) {
    if (!isRotate) {
      return evaluateCode(rotateCode(code), isRotate: true);
    } else {
      return {'is_valid': false};
    }
  } else {
    return {'is_valid': true, 'is_rotate': isRotate, 'code': correctMsg};
  }
}

// Converts triads of bars into integers (0 to 63)
List<int> busToIntegers(buscode) {
  List<int> output = [];
  for (var i = 0; i < buscode.length ~/ 3; i++) {
    var triad = buscode[i * 3] + buscode[i * 3 + 1] + buscode[i * 3 + 2];
    output.add(decoder[triad]);
  }
  return output;
}
