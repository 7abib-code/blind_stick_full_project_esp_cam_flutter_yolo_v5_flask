import 'dart:developer';
import 'dart:typed_data';

import 'package:blind_stick_with_tts_espcam/controllers/scan_controller.dart';
import 'package:blind_stick_with_tts_espcam/controllers/scan_controller_edited.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_mjpeg/flutter_mjpeg.dart';
import 'package:flutter_tflite/flutter_tflite.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:image/image.dart' as imageLibe;

class EspCamWebsocket extends StatefulWidget {
  const EspCamWebsocket({super.key,});

  // final WebSocketChannel channel;

  @override
  State<EspCamWebsocket> createState() => _EspCamWebsocketState();
}

class _EspCamWebsocketState extends State<EspCamWebsocket> {
  Uint8List? byte;

  WebSocketChannel channel =WebSocketChannel.connect(Uri.parse("ws://<YOUR SERVER IP>:<PORT>/ws")) ;
  final isRunning = true;
  FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;
  var label = "";
  var _globalKey = GlobalKey();
  var image ;

  @override
  void initState() {
    super.initState();
    WebSocketChannel.connect(Uri.parse("ws://<YOUR SERVER IP>:<PORT>/ws"));
    initTFLite();
    initTTS();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            StreamBuilder(
                stream: channel.stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  } else {
                    byte = snapshot.data;
                    return RepaintBoundary(
                        key: _globalKey,
                        child: Image.memory(
                          byte!,
                          gaplessPlayback: true,
                        ));
                    // return Image(image: MemoryImage(byte));
                    // return Center(child: Text("lol ${snapshot.data}",style:TextStyle(fontSize: 24, color: Colors.black) ,));
                  }
                }),
          ],
        ),
      ),
    );
  }


}
