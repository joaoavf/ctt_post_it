import 'package:camera_tutorial/data/buscode_maps.dart'; // TODO change name

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

Map evaluateCode(List code) {
  if (code.length != 75) {
    return {'valid': false};
  } else {
    if (validateSyncs(code)) {
      return {'valid': true, 'code': code};
    } else {
      code = rotateCode(code);
      if (validateSyncs(code)) {
        return {'valid': true, 'code': code};
      } else {
        return {'valid': false};
      }
    }
  }
}

List rotateCode(List code) {
  Map charMap = {'A': 'D', 'D': 'A', 'T': 'T', 'F': 'F'};
  List newCode = [];
  for (var i = code.length - 1; i < code.length; i--) {
    newCode.add(charMap[code[i]]);
  }
  return newCode;
}

bool validateSyncs(code) {
  List<int> integers = busToIntegers(code);
  String bin = integers.map(to6Bin).reduce((a, b) => a + b);

  String leftSync = bin.substring(12, 18);
  String rightSync = bin.substring(bin.length - 18, bin.length - 12);

  int leftSyncInt = int.parse(leftSync, radix: 2);
  int rightSyncInt = int.parse(rightSync, radix: 2);
  return leftSyncInt != 22 || rightSyncInt != 38;
}

List<int> busToIntegers(buscode) {
  List<int> output = [];
  for (var i = 0; i < 25; i++) {
    var triad = buscode[i * 3] + buscode[i * 3 + 1] + buscode[i * 3 + 2];
    output.add(decoder[triad]);
  }
  return output;
}
