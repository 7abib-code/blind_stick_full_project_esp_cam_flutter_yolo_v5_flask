import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ObjectController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    initTTS();
    getFirebaseData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;

  final ref = FirebaseDatabase.instance.ref('ObjectDetection').child('Object');
  String object = "";

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
    await _flutterTts.speak(object);
  }

  void setVoice(Map voice){
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  getFirebaseData()async{
    ref.onValue.listen((onData){
      object = onData.snapshot.value.toString().replaceAll('0: 480x640 ', " ");
    });
    playSound();
    update();
  }
}

