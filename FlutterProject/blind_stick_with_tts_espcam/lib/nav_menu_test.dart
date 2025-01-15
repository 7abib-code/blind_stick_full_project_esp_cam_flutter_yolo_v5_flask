import 'package:blind_stick_with_tts_espcam/controllers/scan_controller.dart';
import 'package:blind_stick_with_tts_espcam/view/camera_view.dart';
import 'package:blind_stick_with_tts_espcam/view/esp_cam_websocket.dart';
import 'package:blind_stick_with_tts_espcam/view/object_detection_esp32.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
 class NavMenuTestest extends StatelessWidget {
   const NavMenuTestest({super.key});

   @override
   Widget build(BuildContext context) {
     return DefaultTabController(
       length: 2,
       child: Scaffold(
         appBar: AppBar(
           title: Text('Tab Navigation with Bottom Bar'),
         ),
         body: TabBarView(
           children: [
             CameraView(index: 0),
             RealTimeDataCamer(index: 0,),

           ],
         ),
         bottomNavigationBar: BottomNavigationBar(
           items: [
             BottomNavigationBarItem(
               icon: Icon(Icons.home),
               label: 'Home',
             ),
             BottomNavigationBarItem(
               icon: Icon(Icons.search),
               label: 'Search',
             ),
           ],
         ),
       ),
     );
   }
 }
