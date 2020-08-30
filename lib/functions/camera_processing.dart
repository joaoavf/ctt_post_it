import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:camera_tutorial/models/buscode.dart';
import 'package:ffi/ffi.dart';
import 'package:image/image.dart' as imglib;
import 'dart:typed_data';

class CustomTimer {
  Timer _timer;
  int start = 0;
  StreamController streamController;

  void startTimer() {
    const oneSec = Duration(milliseconds: 100);
    streamController = new StreamController<int>();
    _timer = Timer.periodic(oneSec, (Timer timer) {
      start++;
      streamController.sink.add(start);
      print('start value $start');
    });
  }

  void cancelTimer() {
    streamController.close();
    _timer.cancel();
  }
}

typedef convert_func = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, Int32, Int32, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(
    Pointer<Uint8>, Pointer<Uint8>, Pointer<Uint8>, int, int, int, int);

final DynamicLibrary convertImageLib = Platform.isAndroid
    ? DynamicLibrary.open("libconvertImage.so")
    : DynamicLibrary.process();

Convert conv = convertImageLib
    .lookup<NativeFunction<convert_func>>('convertImage')
    .asFunction<Convert>();

Buscode pushScreen(Map params) {
  CameraImage _savedImage = params['savedImage'];
  String _path = params['path'];
  imglib.Image img;
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

  int horizOffset = 0;
  int vertOffset = (img.height) * 0.40 ~/ 1;
  int width = img.width;
  int height = (img.width) * 0.12 ~/ 1;

  img = imglib.copyCrop(img, horizOffset, vertOffset, width, height);
  print('i');

  Buscode buscode = Buscode(image: img, path: _path);

  return buscode;
}
