import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;
import 'dart:math';
import 'package:path_provider/path_provider.dart';

Future<String> get _localPath async {
  final directory = await getExternalStorageDirectory();
  return directory.path;
}

void saveImage(imglib.Image img) async {
  var date = new DateTime.now().toString();
  var dateParse = DateTime.parse(date).toString().replaceAll(':', '-');
  final path = await _localPath;
  File('$path/$dateParse.png')..writeAsBytesSync(imglib.encodePng(img));
}

List<String> readBuscode(imglib.Image busCodeImage, {bool primitive = true}) {
  saveImage(busCodeImage);
  var height = busCodeImage.height;
  var width = busCodeImage.width;
  var stride = 4;

  var img_1d = toBinary(busCodeImage);

  img_1d = conv2d(img_1d, stride, height, width);
  img_1d = toBinaryColor(img_1d);

  List<List> splitedList =
      splitList(img_1d, height - stride + 1, width - stride + 1);

  splitedList = extractBuscode(splitedList);

  List<String> code = from1dToBuscode(splitedList[0], splitedList[1]);

  List rotations = [0.25, -0.25, 0.5, -0.5];

  for (var i = 0; i < rotations.length; i++) {
    if (code.length != 75 && primitive) {
      code = readBuscode(imglib.copyRotate(busCodeImage, rotations[i]),
          primitive: false);
    }
  }

  return code;
}

List extractBuscode(List splitedList) {
  List fullList = splitedList[0];
  List whiteSpacePosition = [];
  int counter = 0;
  for (var i = 0; i < fullList.length; i++) {
    if (fullList[i] > 254) {
      counter = counter + 1;
    } else {
      if (counter > fullList.length / 75) {
        whiteSpacePosition.add([i]);
        counter = 0;
      }
    }
  }
  var start;
  var finish;
  for (var i = 0; i < whiteSpacePosition.length; i++) {
    if (whiteSpacePosition[i] < whiteSpacePosition.length / 2) {
      start = whiteSpacePosition[i];
    } else {
      finish = whiteSpacePosition[i];
      break;
    }
  }
  return [fullList.sublist(start, finish), splitedList[1].sublist(start, finish)];
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
  List tmpList = entryList.sublist(0); //copy List
  tmpList.sort();
  var whiteThreshold = tmpList[(tmpList.length ~/ 2)] * 0.98;
  var blackThreshold = tmpList[(tmpList.length ~/ 10)] * 1.1;
  var delta = whiteThreshold - blackThreshold;
  var fullThreshold = blackThreshold + delta * .5;
  var midThreshold = blackThreshold + delta * .96;

  List finalT = [midThreshold, fullThreshold];
  return finalT;
}

List<String> from1dToBuscode(List bottomList, List upperList) {
  var l;
  var up;

  List bThresholds = generateThresholds(bottomList);
  List uThresholds = generateThresholds(upperList);

  List<String> result = [];

  var lm = 255.0;
  var um = 255.0;

  for (var i = 0; i < bottomList.length; i++) {
    l = bottomList[i];
    up = upperList[i];

    lm = min(l, lm);
    um = min(up, um);

    if (l > 254 && up > 254) {
      if (lm < bThresholds[1] && um < uThresholds[1]) {
        result.add('F');
      } else if (lm < bThresholds[1] && um < uThresholds[0]) {
        result.add('D');
      } else if (lm < bThresholds[0] && um < uThresholds[1]) {
        result.add('A');
      } else if (lm < bThresholds[0] && um < uThresholds[0]) {
        result.add('T');
      }

      lm = 255.0;
      um = 255.0;
    }
  }
  return result;
}

List toBinary(imglib.Image img) {
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

List toBinaryColor(List img_1d, {int buffer = 20}) {
  List thresholdList = [];
  thresholdList = img_1d.sublist(0);
  thresholdList.sort();
  var threshold = thresholdList[(thresholdList.length ~/ 6)] + buffer;

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
