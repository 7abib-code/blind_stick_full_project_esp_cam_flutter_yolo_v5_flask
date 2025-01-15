import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ScanController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initCamera();
    initTFLite();
    initTTS();
  }

  @override
  void dispose() {
    super.dispose();
    cameraController.dispose();
    _flutterTts.stop();
    _currentVoice = null;
  }

  late CameraController cameraController;
  late List<CameraDescription> cameras;
  var isCameraInitialized = false.obs;
  var cameraCount = 0;
  late WebSocketChannel channel;

  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;
  bool assine = false;

  var h =0.0;
  var x =0.0;
  var y =0.0;
  var w = 0.0;
  var label = "";


  initCamera() async {
    if (await Permission.camera.request().isGranted) {
      cameras = await availableCameras();
      cameraController =
          await CameraController(cameras[0], ResolutionPreset.max);
      await cameraController.initialize().then((value) {
          cameraController.startImageStream((image) {
            cameraCount ++;
            if(cameraCount %10 ==0) {
              cameraCount =0;
              objectDetector(image);
            }
            update();
          });
      });
      isCameraInitialized(true);
      update();
    } else {
      print("Premition Denied");
    }
  }
  void closeCameraAndStream() async {
    if (cameraController.value.isStreamingImages) {
      await cameraController.stopImageStream();
    }
    await cameraController.dispose();
    _currentVoice = null;
    _flutterTts.stop();
  }

  initTFLite() async {
    await Tflite.loadModel(
      model: "assets/model.tflite",
      labels: "assets/labels.txt",
      isAsset: true,
      numThreads: 1,
      useGpuDelegate: false,
    );

  }
  close_tflite(){
    Tflite.close();
  }



  objectDetector(CameraImage image) async {

    var detector = await Tflite.runModelOnFrame(
      bytesList: image.planes.map((e) {
        return e.bytes;
      }).toList(),
      asynch: true,
      imageHeight: image.height,
      imageWidth: image.width,
      imageMean: 127.5,
      imageStd: 127.5,
      numResults: 1,
      rotation: 90,
      threshold: 0.4,
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
        if(ourDetectedObject["label"].toString().compareTo(label) != 0){
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
  void initTTS(){
    _flutterTts.getVoices.then((data){
      try{
        List<Map> _voices = List<Map>.from(data);
        _voices = _voices.where((_voice)=> _voice["name"].contains("en")).toList();
        print(_voices);
          _currentVoice == _voices.first;
          setVoice(_currentVoice!);

      }catch(e){
        print(e);
      }

    });

  }

  void playSound()async{
    await _flutterTts.speak(label);
  }

  void setVoice(Map voice){
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }
}

