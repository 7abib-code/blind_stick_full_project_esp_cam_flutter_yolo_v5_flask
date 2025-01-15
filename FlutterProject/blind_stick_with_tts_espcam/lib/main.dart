
import 'package:blind_stick_with_tts_espcam/firebase_options.dart';
import 'package:blind_stick_with_tts_espcam/nav_menu.dart';
import 'package:blind_stick_with_tts_espcam/nav_menu_test.dart';
import 'package:blind_stick_with_tts_espcam/view/camera_view.dart';
import 'package:blind_stick_with_tts_espcam/view/esp_cam_websocket.dart';
import 'package:blind_stick_with_tts_espcam/view/object_detection_esp32.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(// options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blind Stick',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home:
      // NavMenu()
      RealTimeDataCamer(index: 0)
      // EspCamWebsocket(channel: IOWebSocketChannel.connect('ws://192.168.43.224:8888'),),
      // EspCamWebsocket(channel: IOWebSocketChannel.connect("wss://s13927.blr1.piesocket.com/v3/1?api_key=qi4jkDSZcUSGngg1CRNOQBiOU2BozGMu6bqfocab&notify_self=1")),

    );
  }
}
class RealTimeData extends StatelessWidget {
   RealTimeData({super.key});
  final ref = FirebaseDatabase.instance.ref('ObjectDetection');
  String object ="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
      centerTitle: true,
      title: const Text(
        "Blind Stick",
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: Colors.teal,
    ),
      body:RealTimeDataCamer(index: 0,) ,
    );
  }
}



