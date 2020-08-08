import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';

void read_buscode(imglib.Image img) {
  var summarized_1d = to_binary(img);
  var splitedList = splitList(summarized_1d, img.height, img.width);
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
  List row;

  for (var i = 0; i < width; i++) {
    row = summarized_1d.sublist(i * height, (i + 1) * height);
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

from_1d_to_buscode(List bottomList, upperList) {
  var newListB = bottomList.sublist(0);
  newListB.sort();
  var delta;
  var l;
  var up;
  var threshold_whiteB = newListB[500] * 0.98;
  var threshold_blackB = newListB[70] * 1.1;
  delta = threshold_whiteB - threshold_blackB;
  var threshold_black_30B = threshold_blackB + delta * .3;
  var threshold_black_75B = threshold_blackB + delta * .8;

  var newListU = bottomList.sublist(0);
  newListB.sort();

  var threshold_whiteU = newListU[500] * 0.98;
  var threshold_blackU = newListU[70] * 1.1;
  delta = threshold_whiteU - threshold_blackU;
  var threshold_black_30U = threshold_blackU + delta * .3;
  var threshold_black_75U = threshold_blackU + delta * .8;

  List result = [];

  var lm = 255.0;
  var um = 255.0;

  for (var i = 0; i < 670; i++) {
    l = bottomList[i];
    up = upperList[i];

    lm = min(l, lm);
    um = min(up, um);

    print(l);
    print(up);

    if (l > 240 && up > 240) {
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
  final int height = img.height;
  final int width = img.width;
  List newList = [];

  var colorized;
  for (var i = 0; i < img.data.length; i++) {
    colorized = Color(img.data[i]);
    newList.add((colorized.red + colorized.green + colorized.blue) / 3);
  }
  var threshold = newList[(newList.length ~/ 7)];
  print('threshold');
  print(threshold);

  return to_binary_color(newList, threshold);
}

List to_binary_color(List summarized_1d, double threshold) {
  List newList = [];
  for (var i = 0; i < summarized_1d.length; i++) {
    if (summarized_1d[i] < threshold) {
      newList.add(0);
    } else {
      newList.add(255);
    }
  }
  return newList;
}

processColors(meanRed, meanGreen, meanBlue) {
  return (meanRed + meanGreen + meanBlue) / 3;
}
