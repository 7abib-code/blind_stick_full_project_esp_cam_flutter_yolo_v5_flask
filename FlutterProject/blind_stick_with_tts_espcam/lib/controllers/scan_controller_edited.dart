import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as img;

class ScanControllerEdited extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initTFLite();
    initTTS();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  late WebSocketChannel channel;
  var byets;

  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;
  bool assine = false;

  var h = 0.0;
  var x = 0.0;
  var y = 0.0;
  var w = 0.0;
  var label = "";

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );
  }

  objectDetector() async {
    var detector = await Tflite.runModelOnBinary(
        binary: byets,
        numResults: 6, // defaults to 5
        threshold: 0.05, // defaults to 0.1
        asynch: true // defaults to true
        );
    // if (detector != null) {
    //   var ourDetectedObject = detector.first;
    //   if ((ourDetectedObject['confidence'] * 100) > 45) {
    //     log("result is $detector");
    //     label = ourDetectedObject['label'].toString();
    //     h = ourDetectedObject['rect']['h'];
    //     w = ourDetectedObject['rect']['w'];
    //     x = ourDetectedObject['rect']['x'];
    //     y = ourDetectedObject['rect']['y'];
    //     update();
    //   }
    //   update();
    //
    // }else {
    //   log("No pbject");
    // }
    if (detector != null) {
      var ourDetectedObject = detector.first;
      if ((ourDetectedObject['confidence'] * 100) > 45) {
        log("result is $detector");
        if (ourDetectedObject["label"].toString().compareTo(label) != 0) {
          label = ourDetectedObject["label"].toString();
          await _flutterTts.speak("Camera See $label");
        }
        // // h = ourDetectedObject["rect"]["h"];
        // w = ourDetectedObject["rect"]["w"];
        // x = ourDetectedObject["rect"]["x"];
        // y = ourDetectedObject["rect"]["y"];
      }
      update();
    }
  }

  void initTTS() {
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> _voices = List<Map>.from(data);
        _voices =
            _voices.where((_voice) => _voice["name"].contains("en")).toList();
        print(_voices);
        _currentVoice == _voices.first;
        setVoice(_currentVoice!);
      } catch (e) {
        print(e);
      }
    });
  }

  void playSound() async {
    await _flutterTts.speak(label);
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  Uint8List imageToByteListFloat32(
      img.Image image, int inputSize, double mean, double std) {
    var convertedBytes = Float32List(1 * inputSize * inputSize * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = (img.getRed(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getGreen(pixel) - mean) / std;
        buffer[pixelIndex++] = (img.getBlue(pixel) - mean) / std;
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  Uint8List imageToByteListUint8(img.Image image, int inputSize) {
    var convertedBytes = Uint8List(1 * inputSize * inputSize * 3);
    var buffer = Uint8List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < inputSize; i++) {
      for (var j = 0; j < inputSize; j++) {
        var pixel = image.getPixel(j, i);
        buffer[pixelIndex++] = img.getRed(pixel);
        buffer[pixelIndex++] = img.getGreen(pixel);
        buffer[pixelIndex++] = img.getBlue(pixel);
      }
    }
    return convertedBytes.buffer.asUint8List();
  }

  static Future<img.Image> bytesToImage(Uint8List imgBytes) async {
    ui.Codec codec = await ui.instantiateImageCodec(imgBytes);
    ui.FrameInfo frame;
    try {
      frame = await codec.getNextFrame();
    } finally {
      codec.dispose();
    }
    return frame.image as img.Image;
  }
}
