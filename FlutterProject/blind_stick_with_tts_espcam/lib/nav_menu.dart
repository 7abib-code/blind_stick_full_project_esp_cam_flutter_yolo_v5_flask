import 'package:blind_stick_with_tts_espcam/controllers/scan_controller.dart';
import 'package:blind_stick_with_tts_espcam/view/camera_view.dart';
import 'package:blind_stick_with_tts_espcam/view/esp_cam_websocket.dart';
import 'package:blind_stick_with_tts_espcam/view/object_detection_esp32.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';

class NavMenu extends StatefulWidget {
  const NavMenu({super.key});
  @override
  State<NavMenu> createState() => _NavMenuState();
}

class _NavMenuState extends State<NavMenu> {
  int currentindex =0 ;


  @override
  Widget build(BuildContext context) {

     List<Widget>? _screens =[
       RealTimeDataCamer(index: 0,),
       CameraView(index:  1,),
     ];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Blind Stick",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body: _screens[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
          onTap: (val) {
            setState(() {
              currentindex = val;
              _screens = [
                RealTimeDataCamer(index: val,),
                CameraView(index:  val,),
              ];
            });
          },
          currentIndex: currentindex,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.control_camera),
              label: "ESP Camera",
            ),
            BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
          ],
    ),
    );
  }
}
