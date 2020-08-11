import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import '../models/buscode_decoder.dart';
import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as imglib;

import '../models/buscode.dart';

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

imglib.Image img;

DecodedBusCode getBuscode() {
  CameraImage _savedImage;

  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  Convert conv;

  if (Platform.isAndroid) {
// Allocate memory for the 3 planes of the image
    Pointer<Uint8> p = allocate(count: _savedImage.planes[0].bytes.length);
    Pointer<Uint8> p1 = allocate(count: _savedImage.planes[1].bytes.length);
    Pointer<Uint8> p2 = allocate(count: _savedImage.planes[2].bytes.length);

// Assign the planes data to the pointers of the image
    Uint8List pointerList = p.asTypedList(_savedImage.planes[0].bytes.length);
    Uint8List pointerList1 = p1.asTypedList(_savedImage.planes[1].bytes.length);
    Uint8List pointerList2 = p2.asTypedList(_savedImage.planes[2].bytes.length);
    pointerList.setRange(
        0, _savedImage.planes[0].bytes.length, _savedImage.planes[0].bytes);
    pointerList1.setRange(
        0, _savedImage.planes[1].bytes.length, _savedImage.planes[1].bytes);
    pointerList2.setRange(
        0, _savedImage.planes[2].bytes.length, _savedImage.planes[2].bytes);

// Call the convertImage function and convert the YUV to RGB
    Pointer<Uint32> imgP = conv(
        p,
        p1,
        p2,
        _savedImage.planes[1].bytesPerRow,
        _savedImage.planes[1].bytesPerPixel,
        _savedImage.planes[0].bytesPerRow,
        _savedImage.height);

// Get the pointer of the data returned from the function to a List
    List imgData = imgP
        .asTypedList((_savedImage.planes[0].bytesPerRow * _savedImage.height));
// Generate image from the converted data
    img = imglib.Image.fromBytes(
        _savedImage.height, _savedImage.planes[0].bytesPerRow, imgData);

// Free the memory space allocated
// from the planes and the converted data
    free(p);
    free(p1);
    free(p2);
    free(imgP);
  } else if (Platform.isIOS) {
    img = imglib.Image.fromBytes(
      _savedImage.planes[0].bytesPerRow,
      _savedImage.height,
      _savedImage.planes[0].bytes,
      format: imglib.Format.bgra,
    );
  }

  if (img.height > img.width) {
    img = imglib.copyRotate(img, 90);
  }

  var horizOffset = 0;
  var vertOffset = (img.height) * 0.40 ~/ 1;
  var width = img.width;
  var height = (img.width) * 0.12 ~/ 1;

  img = imglib.copyCrop(img, horizOffset, vertOffset, width, height);

  List buscode = read_buscode(img);

  DecodedBusCode decodedBusCode = DecodedBusCode(buscode, img);

  return decodedBusCode;
}
