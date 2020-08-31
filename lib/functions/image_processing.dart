import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';
import 'dart:developer' as d;

List<num> preProcessImage(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<num> img_1d;

  imglib.normalize(buscodeImage, 100, 255);
  imglib.adjustColor(buscodeImage, hue: 0.1);

  img_1d = filterColors(buscodeImage);

  img_1d = adaptativeThresholds(img_1d, height, width);

  img_1d = conv2d(img_1d, stride: stride, height: width, width: height);
  img_1d = toBinaryColor(img_1d);

  img_1d = invertColor(img_1d);

  img_1d = conv2d(img_1d, stride: stride, height: width - 3, width: height - 3);
  img_1d = toBinaryColor(img_1d, buffer: -10);

  return img_1d;
}

List<String> readBuscode(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 7;

  List<num> img_1d = preProcessImage(buscodeImage);

  List<List<num>> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  List<num> fullList = splitedList[0];

  List<int> tmp = newExtractBuscode(fullList);

  int start = tmp[0];
  int finish = tmp[1];

  fullList = fullList.sublist(start, finish);
  List<num> upperList = splitedList[1].sublist(start, finish);

  List<String> code = newFrom1dToBuscode(fullList, upperList);

  return code;
}

List<num> invertColor(List<num> img_1d) {
  List<num> outputList = [];
  for (int element in img_1d) {
    outputList.add(255 - element);
  }
  return outputList;
}

List<num> adaptativeThresholds(List<num> inputList, height, width,
    {buckets = 30}) {
  List<int> partialList;
  List<num> outputList = [];
  int maxLen;
  int bucketSize = width ~/ buckets;
  for (int f = 0; f < buckets; f++) {
    if (f == buckets - 1) {
      maxLen = width;
    } else {
      maxLen = bucketSize * (f + 1);
    }
    partialList = [];
    for (var i = bucketSize * f; i < maxLen; i++) {
      for (var j = 0; j < height; j++) {
        partialList.add(inputList[i + (width * j)]);
      }
    }
    partialList = toBinaryColor(partialList, buffer: 10);
    outputList.addAll(partialList);
  }
  return outputList;
}

List<num> filterColors(imglib.Image image) {
  List<num> filteredColors = [];
  Color color;
  int colorInt;

  for (int i = 0; i < image.data.length; i++) {
    color = Color(image.data[i]);
    colorInt = ((color.blue * 0.8) - (color.red * 0.4)).toInt();
    filteredColors.add(colorInt);
  }

  return filteredColors;
}

List<String> newFrom1dToBuscode(List<num> fullList, List<num> upperList) {
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
  print('vector length');
  print(positions.length);

  return processCollections(unit, upperList, fullList, results, positions);
}

List<String> processCollections(num unit, List<num> upperList,
    List<num> fullList, List<int> results, List<int> positions) {
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

  List uList = [];

  double minima = fullList.reduce(min);

  for (int i = 0; i < 75; i++) {
    e = positions[i];
    s = e - results[i];

    t = fullList.sublist(s, e).reduce(min);
    u = upperList.sublist(s, e).reduce(min);

    String temp = calc(t, minima);
    uList.add(u);

    outputList.add(temp);
  }

  int buffer = 30;

  for (int i = 0; i < outputList.length; i++) {
    if (outputList[i] == 'AD') {
      if (i > 0) {
        compare(outputList, uList, i, i - 1, buffer);
      } else {
        outputList[i] = 'D';
        compare(outputList, uList, i, i + 1, buffer);
      }
    }
  }

  return outputList;
}

String calc(double t, double minima) {
  if (t < minima + 30) {
    return 'F';
  } else if (t < minima + 80) {
    return 'AD';
  } else {
    return 'T';
  }
}

compare(outputList, uList, i, j, buffer) {
  if (outputList[j] == 'T' || outputList[j] == 'D') {
    if ((uList[i] - uList[j]).abs() < buffer) {
      outputList[i] = 'D';
    } else {
      outputList[i] = 'A';
    }
  } else if (outputList[j] == 'F' || outputList[j] == 'A') {
    if ((uList[i] - uList[j]).abs() < buffer) {
      outputList[i] = 'A';
    } else {
      outputList[i] = 'D';
    }
  }
}

List<num> toBinaryColor(List<num> img_1d, {int buffer = 10}) {
  List<num> thresholdList = [];
  thresholdList = img_1d.sublist(0);
  thresholdList.sort();
  var threshold = thresholdList[(thresholdList.length ~/ 6)] + buffer;

  List<int> newList = [];

  for (var i = 0; i < img_1d.length; i++) {
    if (img_1d[i] <= threshold) {
      newList.add(0);
    } else {
      newList.add(255);
    }
  }
  return newList;
}

List<num> conv2d(List<num> img_1d, {int stride, int height, int width}) {
  List<num> newList = [];
  List<num> strideList;
  for (var i = 0; i < (height - stride + 1); i++) {
    for (var j = 0; j < (width - stride + 1); j++) {
      strideList = [];
      for (var z = 0; z < stride; z++) {
        for (var y = 0; y < stride; y++) {
          strideList.add(img_1d[(j + y) + (i + z) * width]);
        }
      }

      newList.add(strideList.reduce((a, b) => a + b));
    }
  }
  return newList;
}

List<List<num>> splitList(img_1d, int height, int width) {
  List fullCalc = [];
  List upperCalc = [];
  List<num> upperList = [];
  List<num> fullList = [];

  for (var i = 0; i < width; i++) {
    fullCalc = [];
    upperCalc = [];
    for (var j = 0; j < height; j++) {
      if (j < height / 2) {
        upperCalc.add(img_1d[j + (height * i)]);
      }
      fullCalc.add(img_1d[j + (height * i)]);
    }
    fullList.add(fullCalc.reduce((a, b) => a + b) / fullCalc.length);
    upperList.add(upperCalc.reduce((a, b) => a + b) / upperCalc.length);
  }

  return [fullList, upperList];
}

List<int> newExtractBuscode(List<num> fullList, {threshold = 100}) {
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
