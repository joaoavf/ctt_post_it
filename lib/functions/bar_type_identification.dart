import 'dart:math';

List<String> identifyBars(List<num> fullList, List<num> upperList) {
  List tmp = barSeparation(fullList, upperList);
  List<int> results = tmp[0];
  List<int> positions = tmp[1];
  num unit = tmp[2];

  tmp = furtherBarSeparation(fullList, upperList, results, positions, unit);

  List<String> outputList = tmp[0];
  List<double> uList = tmp[1];
  outputList = rotationCalibration(outputList, uList);

  return outputList;
}

List barSeparation(List<num> fullList, List<num> upperList) {
  double umin = 255;
  double wmin = 255;
  int counter = 0;
  List<int> results = [];
  List<int> positions = [];

  int i;

  for (i = 0; i < fullList.length; i++) {
    wmin = min(wmin, fullList[i]);
    umin = min(umin, upperList[i]);

    if (fullList[i] > 230) {
      if (wmin < 230) {
        results.add(counter);
        positions.add(i);
        counter = 0;
      }
      wmin = 255;
      umin = 255;
    }
    counter++;
  }

  results.add(counter);
  positions.add(i);

  num unit = (fullList.length - counter) / 74;

  return [results, positions, unit];
}

furtherBarSeparation(List<num> fullList, List<num> upperList, List<int> results,
    List<int> positions, num unit) {
  unit = unit.toInt();
  List<String> outputList = [];

  int cMax;
  if (results.length < 50) {
    return [];
  }

  while (results.length < 75) {
    cMax = results.indexOf(results.reduce(max));

    results = results.sublist(0, cMax) +
        [results[cMax] - unit, unit] +
        results.sublist(cMax + 1);
    positions = positions.sublist(0, cMax) +
        [positions[cMax] - unit, positions[cMax]] +
        positions.sublist(cMax + 1);
  }
  int e;
  int s;
  double t;
  double u;

  List<double> uList = [];

  double minima = fullList.reduce(min);

  for (int i = 0; i < 75; i++) {
    e = positions[i];
    s = e - results[i];

    t = fullList.sublist(s, e).reduce(min);
    u = upperList.sublist(s, e).reduce(min);

    String temp = blackCalibration(t, minima);
    uList.add(u);
    outputList.add(temp);
  }
  return [outputList, uList];
}

List<String> rotationCalibration(List<String> outputList, List uList,
    {int buffer = 30}) {
  for (int i = 0; i < outputList.length; i++) {
    if (outputList[i] == 'AD') {
      if (i > 0) {
        compareBarHeight(outputList, uList,
            currentPos: i, shiftPos: i - 1, buffer: buffer);
      } else {
        outputList[i] = 'D';
        compareBarHeight(outputList, uList,
            currentPos: i, shiftPos: i + 1, buffer: buffer);
      }
    }
  }
  return outputList;
}

String blackCalibration(double t, double minima) {
  if (t < minima + 30) {
    return 'F';
  } else if (t < minima + 80) {
    return 'AD';
  } else {
    return 'T';
  }
}

compareBarHeight(outputList, uList, {currentPos, shiftPos, buffer}) {
  if (outputList[shiftPos] == 'T' || outputList[shiftPos] == 'D') {
    if ((uList[currentPos] - uList[shiftPos]).abs() < buffer) {
      outputList[currentPos] = 'D';
    } else {
      outputList[currentPos] = 'A';
    }
  } else if (outputList[shiftPos] == 'F' || outputList[shiftPos] == 'A') {
    if ((uList[currentPos] - uList[shiftPos]).abs() < buffer) {
      outputList[currentPos] = 'A';
    } else {
      outputList[currentPos] = 'D';
    }
  }
}
