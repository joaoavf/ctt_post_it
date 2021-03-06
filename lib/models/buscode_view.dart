import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

// Unifies reading from image and reading from disk
class BuscodeView {
  String path;
  imglib.Image image;
  String day;
  String month;
  String hour;
  String minute;
  String buscodeDate;
  String equipmentId;
  String issuerCode;
  String formatId;
  String itemPriority;
  String serialNumber;
  String trackingIndicator;
  String idTag;

  BuscodeView(
      {@required this.image,
      @required this.path,
      @required this.buscodeDate,
      @required this.equipmentId,
      @required this.issuerCode,
      @required this.formatId,
      @required this.itemPriority,
      @required this.serialNumber,
      @required this.trackingIndicator}) {
    minute = buscodeDate.substring(15, 16);
    month = buscodeDate.substring(5, 7);
    day = buscodeDate.substring(8, 10);
    hour = buscodeDate.substring(11, 13);
    idTag = formatId +
        issuerCode +
        equipmentId +
        itemPriority +
        month +
        day +
        hour +
        minute +
        serialNumber +
        trackingIndicator;
    minute = minute + '0';
  }
}
