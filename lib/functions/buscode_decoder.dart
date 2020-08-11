Map decoder = {
  'FFF': 0,
  'FFA': 1,
  'FFD': 2,
  'FFT': 3,
  'FAF': 4,
  'FAA': 5,
  'FAD': 6,
  'FDF': 8,
  'FDA': 9,
  'FDD': 10,
  'FDT': 11,
  'FTF': 12,
  'FTA': 13,
  'FTD': 14,
  'FTT': 15,
  'AFF': 16,
  'AFA': 17,
  'AFD': 18,
  'AFT': 19,
  'AAF': 20,
  'AAA': 21,
  'AAD': 22,
  'AAT': 23,
  'ADF': 24,
  'ADA': 25,
  'ADD': 26,
  'ADT': 27,
  'ATF': 28,
  'ATA': 29,
  'ATD': 30,
  'ATT': 31,
  'DFF': 32,
  'DFA': 33,
  'DFD': 34,
  'DFT': 35,
  'DAF': 36,
  'DAA': 37,
  'DAD': 38,
  'DAT': 39,
  'DDF': 40,
  'DDA': 41,
  'DDD': 42,
  'DDT': 43,
  'DTF': 44,
  'DTA': 45,
  'DTD': 46,
  'DTT': 47,
  'TFF': 48,
  'TFA': 49,
  'TFD': 50,
  'TFT': 51,
  'TAF': 52,
  'TAA': 53,
  'TAD': 54,
  'TAT': 55,
  'TDF': 56,
  'TDA': 57,
  'TDD': 58,
  'TDT': 59,
  'TTF': 60,
  'TTA': 61,
  'TTD': 62,
  'TTT': 63
};

Map issue_code_map = {
  35: '0',
  34: '1',
  33: '2',
  32: '3',
  31: '4',
  30: '5',
  29: '6',
  28: '7',
  27: '8',
  26: '9',
  25: 'A',
  24: 'B',
  23: 'D',
  22: 'E',
  21: 'F',
  19: 'H',
  18: 'I',
  17: 'J',
  15: 'K',
  14: 'L',
  13: 'M',
  12: 'N',
  11: 'O',
  10: 'P',
  9: 'Q',
  8: 'R',
  7: 'S',
  6: 'T',
  5: 'U',
  4: 'V',
  3: 'W',
  2: 'X',
  1: 'Y',
  0: 'Z'
};

var item_priority_map = {'00': 'N', '01': 'L', '10': 'H', '11': 'U'};

var tracking_indicator_map = {'00': 'T', '01': 'F', '10': 'D', '11': 'N'};

List<int> bus_to_integers(buscode) {
  List<int> output = [];
  for (var i = 0; i < 25; i++) {
    var triad = buscode[i * 3] + buscode[i * 3 + 1] + buscode[i * 3 + 2];
    output.add(decoder[triad]);
  }
  return output;
}

String to_6bin(int integerInput) {
  String binary = integerInput.toRadixString(2);
  return '0' * (6 - binary.length) + '$binary';
}

String decode_format_id(String formatId) {
  var position = int.parse(formatId, radix: 2);
  return 'J18' + 'ABCDEFGHIJKLMNOPQ'[position];
}

String issuer_code_conversion(String issuerCode) {
  int issuerCodeInt = int.parse(issuerCode, radix: 2);
  int l1 = issuerCodeInt ~/ 1600;
  int l2 = issuerCodeInt % 1600 ~/ 40;
  int l3 = issuerCodeInt % 1600 % 40;
  return issue_code_map[l1] + issue_code_map[l2] + issue_code_map[l3];
}

String decodeEquipmentId(String equipmentId) {
  return int.parse(equipmentId, radix: 2).toRadixString(16);
}

String decodeItemPriority(String itemPriority) {
  return item_priority_map[itemPriority];
}

Map processSerialNumber(String serialNumberStr) {
  int serialNumber = int.parse(serialNumberStr, radix: 2);
  int serial = serialNumber % 16384;
  int datePart = serialNumber ~/ 16384;
  int month = datePart ~/ 5120;
  int day = datePart % 5120 ~/ 160;
  int hour = datePart % 5120 % 160 ~/ 6;
  int minute = datePart % 5120 % 160 % 6;
  Map returnMap = {
    'month': month,
    'day': day,
    'hour': hour,
    'minute': minute,
    'serial': serial
  };
  return returnMap;
}

String decodeTrackingIndicator(String trackingIndicator) {
  return tracking_indicator_map[trackingIndicator];
}

class DecodedBusCode {
  List buscode;
  List<int> integers;
  String bin;
  String main;

  String formatId;
  String issuerCode;
  String equipmentId;
  String itemPriority;

  Map serialNumberMap;
  int hour;
  int month;
  int day;
  int minute;
  int serialNumber;

  String trackingIndicator;
  bool valid;

  bool success = false;

  DecodedBusCode(this.buscode) {
    if (buscode.length == 75) {
      success = true;
      integers = bus_to_integers(buscode);
      print(integers);

      bin = integers.map(to_6bin).reduce((a, b) => a + b);
      print(bin);

      main = bin.substring(0, 12) +
          bin.substring(18, 60) +
          bin.substring(138, 150);
      print(main);

      formatId = decode_format_id(main.substring(0, 4));
      print(formatId);

      issuerCode = issuer_code_conversion(main.substring(4, 20));
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
    }
  }
}
