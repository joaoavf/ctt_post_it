import 'dart:async';
import 'dart:ffi';
import 'dart:io';
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

Buscode pushScreen(mapVariables) {
  print('pushScreen');
  var planes = mapVariables['planes'];
  int height = mapVariables['height'];
  int width = mapVariables['width'];
  bool isAndroid = mapVariables['isAndroid'];
  String path = mapVariables['path'];

  imglib.Image img;

  if (planes == null) {
    return null;
  }

  if (isAndroid) {
    // Allocate memory for the 3 planes of the image
    Pointer<Uint8> p = allocate(count: planes[0].bytes.length);
    Pointer<Uint8> p1 = allocate(count: planes[1].bytes.length);
    Pointer<Uint8> p2 = allocate(count: planes[2].bytes.length);

    // Assign the planes data to the pointers of the image
    Uint8List pointerList = p.asTypedList(planes[0].bytes.length);
    Uint8List pointerList1 = p1.asTypedList(planes[1].bytes.length);
    Uint8List pointerList2 = p2.asTypedList(planes[2].bytes.length);
    pointerList.setRange(0, planes[0].bytes.length,
        planes[0].bytes.sublist(0, planes[0].bytes.length));
    pointerList1.setRange(0, planes[1].bytes.length,
        planes[1].bytes.sublist(0, planes[1].bytes.length));
    pointerList2.setRange(0, planes[2].bytes.length,
        planes[2].bytes.sublist(0, planes[2].bytes.length));

    // Call the convertImage function and convert the YUV to RGB
    Pointer<Uint32> imgP = conv(p, p1, p2, planes[1].bytesPerRow,
        planes[1].bytesPerPixel, planes[0].bytesPerRow, height);

    // Get the pointer of the data returned from the function to a List
    List imgData =
        imgP.asTypedList((planes[0].bytesPerRow * height));
    // Generate image from the converted data
    img = imglib.Image.fromBytes(height, planes[0].bytesPerRow, imgData);
    // Free the memory space allocated from the planes and the converted data
    free(p);
    free(p1);
    free(p2);
    free(imgP);
  } else {
    img = imglib.Image.fromBytes(
      width,
      height,
      planes[0].bytes,
      format: imglib.Format.bgra,
    );
  }

  if (img.height > img.width) {
    img = imglib.copyRotate(img, 90);
  }

  var horizOffset = 0;
  var vertOffset = (img.height) * 0.40 ~/ 1;
  width = img.width;
  height = (img.width) * 0.12 ~/ 1;

  img = imglib.copyCrop(img, horizOffset, vertOffset, width, height);

  Buscode buscode = Buscode(image: img, path: path);

  return buscode;
}
