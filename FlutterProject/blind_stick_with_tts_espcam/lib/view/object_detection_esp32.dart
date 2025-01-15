import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';

class RealTimeDataCamer extends StatefulWidget {
  RealTimeDataCamer({super.key, required this.index});

  late int index;

  @override
  State<RealTimeDataCamer> createState() => _RealTimeDataCamerState();
}

class _RealTimeDataCamerState extends State<RealTimeDataCamer> {
  final ref = FirebaseDatabase.instance.ref('ObjectDetection');
  String object = "";
  final FlutterTts _flutterTts = FlutterTts();
  Map? _currentVoice;

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  @override
  void initState() {
    super.initState();
    initTTS();
  }

  void initTTS() {
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        voices = voices.where((voice) => voice["name"].contains("en")).toList();
        _currentVoice == voices.first;
        setVoice(_currentVoice!);
      } catch (e) {
        if (kDebugMode) {
          print(e);
        }
      }
    });
  }

  void playSound(String sound) async {
    await _flutterTts.speak(sound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.control_camera),
        centerTitle: true,
        title: const Text(
          "Blind Stick",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          Expanded(
              child: FirebaseAnimatedList(
                  query: ref,
                  itemBuilder: (context, snapshot, animation, index) {
                    if (index == 1) {
                      object = "";
                      _flutterTts.stop();
                    }
                    if (index.isEqual(0)) {
                      _flutterTts.speak(object).then((value) {
                        object = snapshot
                            .child('Object')
                            .value
                            .toString()
                            .replaceAll('0: 480x640 ', " ");
                      });
                    }

                    return Center(
                        child: Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.teal,
                          child: Center(
                            child: Text(
                              "Camera See: $object",
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 24),
                            ),
                          ),
                        ));
                  }))
        ],
      ),
      // bottomNavigationBar: BottomNavigationBar(
      //   selectedItemColor: Colors.teal,
      //   onTap: (val) {
      //     setState(() {
      //       widget.index = val;
      //       if (val == 1) {
      //         widget.index = val;
      //         Navigator.of(context).pushAndRemoveUntil(
      //           MaterialPageRoute(builder: (context) => CameraView(index: 1)),
      //           ModalRoute.withName('/'),
      //         );
      //       }
      //     });
      //   },
      //   currentIndex: widget.index,
      //   items: [
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.control_camera),
      //       label: "ESP Camera",
      //     ),
      //     BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
      //   ],
      // ),
    );
  }
}
