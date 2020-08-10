import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';

void read_buscode(imglib.Image img) {
  var height = img.height;
  var width = img.width;
  var stride = 4;

  var img_1d = to_binary(img);

  img_1d = conv2d(img_1d, stride, height, width);
  img_1d = toBinaryColor(img_1d);

  var splitedList = splitList(img_1d, height, width);
  var buscode = from_1d_to_buscode(splitedList[0], splitedList[1]);
  print(buscode);
  print(buscode.length);
  return buscode;
}

List splitList(summarized_1d, int height, int width) {
  List bottomCalc = [];
  List upperCalc = [];
  List upperList = [];
  List bottomList = [];

  for (var i = 0; i < width; i++) {
    bottomCalc = [];
    upperCalc = [];
    for (var j = 0; j < height; j++) {
      if (j < height / 2) {
        bottomCalc.add(summarized_1d[i + (width * j)]);
      } else {
        upperCalc.add(summarized_1d[i + (width * j)]);
      }
    }
    bottomList.add(bottomCalc.reduce((a, b) => a + b) / bottomCalc.length);
    upperList.add(upperCalc.reduce((a, b) => a + b) / upperCalc.length);
  }

  return [bottomList, upperList];
}

from_1d_to_buscode(List bottomList, List upperList) {
  var newListB = bottomList.sublist(0);
  newListB.sort();

  var delta;
  var l;
  var up;

  var threshold_whiteB = newListB[(newListB.length ~/ 5) * 4] * 0.98;
  var threshold_blackB = newListB[(newListB.length ~/ 9)] * 1.1;
  delta = threshold_whiteB - threshold_blackB;
  var threshold_black_30B = threshold_blackB + delta * .3;
  var threshold_black_75B = threshold_blackB + delta * .8;

  var newListU = upperList.sublist(0);
  newListB.sort();

  var threshold_whiteU = newListU[(newListU.length ~/ 5) * 4] * 0.98;
  var threshold_blackU = newListU[(newListB.length ~/ 9)] * 1.1;
  delta = threshold_whiteU - threshold_blackU;
  var threshold_black_30U = threshold_blackU + delta * .3;
  var threshold_black_75U = threshold_blackU + delta * .8;

  List result = [];

  var lm = 255.0;
  var um = 255.0;

  print('inside');
  print(bottomList.length);
  print(upperList.length);

  for (var i = 0; i < bottomList.length; i++) {
    l = bottomList[i];
    up = upperList[i];

    lm = min(l, lm);
    um = min(up, um);

    print(l);
    print(up);

    if (l > 254 && up > 254) {
      // TODO might be necessary to use conv here
      if (lm < threshold_black_30B && um < threshold_black_30U) {
        result.add('F');
      } else if (lm < threshold_black_30B && um < threshold_black_75U) {
        result.add('D');
      } else if (lm < threshold_black_75B && um < threshold_black_30U) {
        result.add('A');
      } else if (lm < threshold_black_75B && um < threshold_black_75U) {
        result.add('T');
      }

      lm = 255.0;
      um = 255.0;
    }
  }
  return result;
}

List to_binary(imglib.Image img) {
  List newList = [];

  var colorized;
  for (var i = 0; i < img.data.length; i++) {
    colorized = Color(img.data[i]);
    newList.add(colorized.red * 0.2989 +
        colorized.green * 0.5870 +
        colorized.blue * 0.1140);
  }


  return toBinaryColor(newList);
}

List toBinaryColor(List img_1d) {
  List thresholdList = [];
  thresholdList = img_1d.sublist(0);
  thresholdList.sort();
  var threshold = thresholdList[(thresholdList.length ~/ 5)];

  List newList = [];
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