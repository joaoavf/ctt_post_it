import 'dart:math';
import 'image_processing.dart';
import 'package:image/image.dart' as imglib;

// Most high level function to read bus codes.
List<String> readBuscode(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<num> img_1d = preProcessImage(buscodeImage);

  List<List<num>> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  List<num> fullList = splitedList[0];

  List<int> tmp = extractBuscode(fullList);

  int start = tmp[0];
  int finish = tmp[1];

  fullList = fullList.sublist(start, finish);
  List<num> upperList = splitedList[1].sublist(start, finish);

  List<String> code = identifyBars(fullList, upperList);

  return code;
}

// Trims whitespace from right and left.
List<int> extractBuscode(List<num> fullList, {threshold = 100}) {
  List<int> counters = [];
  List<int> positions = [];
  int counter = 0;

  int pos;
  for (pos = 0; pos < fullList.length; pos++)
    if (fullList[pos] > 230) {
      counter++;
    } else {
      if (counter > fullList.length / threshold || counters.length == 0) {
        counters.add(counter);
        positions.add(pos);
      }
      counter = 0;
    }
  if (counter > fullList.length / threshold) {
    counters.add(counter);
    positions.add(pos);
  }

  int start = 0;
  int finish = fullList.length;

  for (int i = 0; i < counters.length; i++) {
    if (positions[i] < fullList.length / 2) {
      start = positions[i];
    } else {
      finish = positions[i] - counters[i];
      break;
    }
  }
  return [start, finish];
}

// Returns bar type [A,D,T,F] from processed image
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

// Separate original image into blocks by vertical whitespace
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

// If less than 75 blocks, keeps splitting the largest remaining blocks.
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

// Useful for whenever the photo is tilted right or left to identify A or D
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

// Uses dynamic thresholds based on minima to select for [A,D,T,F]
String blackCalibration(double t, double minima) {
  if (t < minima + 30) {
    return 'F';
  } else if (t < minima + 80) {
    return 'AD';
  } else {
    return 'T';
  }
}

// Logic to decide whether A or D based on neighbor bar
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
