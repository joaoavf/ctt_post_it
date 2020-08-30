import 'dart:io';
import 'package:camera_tutorial/functions/file_management.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera_tutorial/models/buscode.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:camera/camera.dart';
import 'package:camera_tutorial/screens/result_screen.dart';

import '../functions/camera_processing.dart';

class CameraScreen extends StatefulWidget {
  CameraScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController _camera;
  bool _cameraInitialized = false;
  CameraImage _savedImage;
  String _path;
  bool _flashlightOn = true;
  bool _isProcessing = false;
  CustomTimer customTimer = new CustomTimer();

  @override
  void initState() {
    super.initState();
    _initializePath();
    _initializeCamera();

    customTimer.startTimer();
    customTimer.streamController.stream.listen((data) {
      if (!_isProcessing && _cameraInitialized && _savedImage != null) {
        _isProcessing = true;
        var planes = _savedImage.planes.sublist(0);
        print(_savedImage.planes[0].bytes.length);
        print(_savedImage.planes[0].bytes.length);
        print(_savedImage.planes[0].bytes.length);
        int height = _savedImage.height;
        int width = _savedImage.width;
        Map parameterMap = {
          'planes': planes,
          'height': height,
          'width': width,
          'isAndroid': Platform.isAndroid,
          'isIOS': Platform.isIOS,
          'path': _path
        };
        print(planes[0].bytes.length);
        print(height * width);
        Future<Buscode> buscode = compute(pushScreen, parameterMap);
        evaluateFutureBuscode(buscode);
      }
    });
  }

  void _initializePath() async {
    _path = await localPath;
  }

  void _initializeCamera() async {
    // Get list of cameras of the device
    try {
      List<CameraDescription> cameras = await availableCameras();
      // Create the CameraController
      _camera = CameraController(cameras[0], ResolutionPreset.veryHigh);
      _camera.initialize().then((_) async {
        // Start ImageStream
        await _camera.startImageStream(
            (CameraImage image) => _processCameraImage(image));
        setState(() {
          _cameraInitialized = true;
          _isProcessing = false;
          _camera.enableTorch();
        });
      });
    } catch (e) {
      print(e);
    }
  }

  void _processCameraImage(CameraImage image) async {
    setState(() {
      _savedImage = image;
    });
  }

  void _flashlightToggle(state) {
    setState(() {
      _flashlightOn = state;
    });
    if (_flashlightOn == true) {
      _camera.enableTorch();
    } else if (_flashlightOn == false) {
      _camera.disableTorch();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned.fill(
                child: (_cameraInitialized)
                    ? AspectRatio(
                        aspectRatio: _camera.value.aspectRatio,
                        child: CameraPreview(_camera),
                      )
                    : SpinKitWave(
                        color: Theme.of(context).primaryColor,
                        size: 30,
                      )),
            Positioned.fill(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.topLeft,
                      color: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        padding: EdgeInsets.all(20),
                        icon: _flashlightOn == false
                            ? Icon(
                                Icons.flash_off,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.flash_on,
                                color: Colors.white,
                              ),
                        onPressed: () {
                          _flashlightToggle(!_flashlightOn);
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.height * 0.12,
                  ),
                  Expanded(
                    child: Container(
                      alignment: Alignment.topRight,
                      color: Colors.black.withOpacity(0.5),
                      child: IconButton(
                        padding: EdgeInsets.all(20),
                        icon: Icon(
                          Icons.close,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _camera.dispose();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void evaluateFutureBuscode(Future<Buscode> futureBuscode) async {
    Buscode buscode = await futureBuscode;
    _isProcessing = false;
    if (buscode.success) {
      _flashlightToggle(false);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(buscodeView: buscode.view),
        ),
      );
    }
  }
}
