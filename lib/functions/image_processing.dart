import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';

List<String> readBuscode(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<num> img_1d = toBW(buscodeImage);
  img_1d = toBinaryColor(img_1d);

  img_1d = conv2d(img_1d, stride, height, width);
  img_1d = toBinaryColor(img_1d);

  List<List> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  splitedList = extractBuscode(splitedList);

  List<String> code = from1dToBuscode(splitedList[0], splitedList[1]);

  return code;
}

List<int> preProcessImage(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<int> img_1d;

  imglib.normalize(buscodeImage, 100, 255);
  imglib.adjustColor(buscodeImage, hue: 0.1);

  img_1d = extractBlue(buscodeImage);
  img_1d = adaptativeThresholds(img_1d, height, width);
  img_1d = conv2d(img_1d, stride, height, width);
  img_1d = toBinaryColor(img_1d);

  return img_1d;
}

List<String> altReadBuscode(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<int> img_1d = preProcessImage(buscodeImage);

  List<List> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  splitedList = extractBuscode(splitedList);

  List<String> code = from1dToBuscode(splitedList[0], splitedList[1]);

  return code;
}

List<List> extractBuscode(List<List> splitedList) {
  List fullList = splitedList[0];
  List<int> whiteSpacePosition = [];
  int counter = 0;
  for (int i = 0; i < fullList.length; i++) {
    if (fullList[i] > 254) {
      counter = counter + 1;
    } else {
      if (counter > fullList.length / 75) {
        whiteSpacePosition.add(i);
      }
      counter = 0;
    }
  }
  int start = 0;
  int finish = fullList.length - 1;
  for (var i = 0; i < whiteSpacePosition.length; i++) {
    if (whiteSpacePosition[i] < fullList.length / 2) {
      start = whiteSpacePosition[i];
    } else {
      finish = whiteSpacePosition[i] - fullList.length ~/ 75;
      break;
    }
  }
  return [
    fullList.sublist(start, finish),
    splitedList[1].sublist(start, finish)
  ];
}

List<List> splitList(img_1d, int height, int width) {
  List fullCalc = [];
  List upperCalc = [];
  List upperList = [];
  List fullList = [];

  for (var i = 0; i < width; i++) {
    fullCalc = [];
    upperCalc = [];
    for (var j = 0; j < height; j++) {
      if (j < height / 2) {
        upperCalc.add(img_1d[i + (width * j)]);
      }
      fullCalc.add(img_1d[i + (width * j)]);
    }
    fullList.add(fullCalc.reduce((a, b) => a + b) / fullCalc.length);
    upperList.add(upperCalc.reduce((a, b) => a + b) / upperCalc.length);
  }

  return [fullList, upperList];
}

List generateThresholds(List entryList) {
  return [75, 145, 215];
}

List<int> adaptativeThresholds(List<int> inputList, height, width,
    {buckets = 10}) {
  List<int> partialList;
  List<int> outputList = [];
  int maxLen;
  int bucketSize = width ~/ 10;
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

List<int> extractBlue(imglib.Image image) {
  List<int> blueVector = [];

  for (int i = 0; i < image.data.length; i++) {
    Color b = Color(image.data[i]);
    blueVector.add(b.blue);
  }

  return blueVector;
}

List<String> from1dToBuscode(List fullList, List upperList) {
  var w;
  var up;

  List thresholds = generateThresholds(fullList);

  List<String> result = [];
  List<int> positions = [];
  List<double> values = [];
  var wm = 255.0;
  var um = 255.0;

  for (var i = 0; i < fullList.length; i++) {
    w = fullList[i];
    up = upperList[i];

    wm = min(w, wm);
    um = min(up, um);

    if (w > 254) {
      if (wm < thresholds[0]) {
        result.add('F');
      } else if (wm < thresholds[1]) {
        positions.add(result.length);
        values.add(um);
        result.add('AD');
      } else if (wm < thresholds[2]) {
        result.add('T');
      }

      wm = 255.0;
      um = 255.0;
    }
  }

  if (values.length > 1) {
    var threshold =
        (values.reduce(max) - values.reduce(min)) / 2 + values.reduce(min);
    for (var i = 0; i < positions.length; i++) {
      if (values[i] > threshold) {
        result[positions[i]] = 'D';
      } else {
        result[positions[i]] = 'A';
      }
    }
  }
  return result;
}

List<num> toBW(
  imglib.Image img, {
  double redFilter = 0.2989,
  double greenFilter = 0.5870,
  double blueFilter = 0.1140,
}) {
  List<num> newList = [];

  var colorized;
  for (var i = 0; i < img.data.length; i++) {
    colorized = Color(img.data[i]);
    newList.add(colorized.red * redFilter +
        colorized.green * greenFilter +
        colorized.blue * blueFilter);
  }

  return newList;
}

List<int> toBinaryColor(List<num> img_1d, {int buffer = 20}) {
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

List conv2d(List img_1d, int stride, int height, int width) {
  List newList = [];
  List strideList;
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
