import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

List<num> preProcessImage(imglib.Image buscodeImage) {
  var height = buscodeImage.height;
  var width = buscodeImage.width;
  var stride = 4;

  List<num> img_1d;

  imglib.normalize(buscodeImage, 100, 255);
  imglib.adjustColor(buscodeImage, hue: 0.1);

  img_1d = filterColors(buscodeImage);
  img_1d = adaptativeThresholds(img_1d, height, width);

  img_1d = invertColor(img_1d);

  img_1d = conv2d(img_1d, stride: stride, height: width, width: height);
  img_1d = threshold(img_1d);

  return img_1d;
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
    partialList = threshold(partialList, buffer: 10);
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


List<num> threshold(List<num> img_1d, {int buffer = 10}) {
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
