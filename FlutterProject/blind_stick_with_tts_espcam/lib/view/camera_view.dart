import 'package:blind_stick_with_tts_espcam/view/esp_cam_websocket.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:web_socket_channel/io.dart';

import '../controllers/scan_controller.dart';
import 'object_detection_esp32.dart';

class CameraView extends StatefulWidget {
   CameraView({super.key, required this.index});
  int index ;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  String? label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(Icons.camera),
        centerTitle: true,
        title: const Text(
          "Mobile Camera Blind Assistant",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      body:
      Column(
        children: [
            GetBuilder<ScanController>(
              init: ScanController(),

              builder: (controller) {
                if (widget.index == 0){
                  controller.dispose();
                }
                if (controller.isCameraInitialized.value) {
                    label = controller.label;
                  return Container(
                    padding: const EdgeInsets.all(9),
                    child: Column(
                      children: [
                        Stack(
                            children: [
                              CameraPreview(controller.cameraController),
                              Positioned(
                                top:  controller.y ,
                                right: controller.x,
                                child: Container(
                                  width: controller.w ,
                                  height:controller.x ,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green, width: 4.0),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                          color: Colors.white,
                                          child: Text("${controller.label}"),
                                      ),

                                    ],
                                  ),
                                ),
                              )
                            ]),
                        Container(
                          color: Colors.blue,
                          width: double.infinity,
                          height: 100,
                          child: Center(child: Text(
                                "Camera See: ${controller.label}", style: const TextStyle(color: Colors.white ,fontSize: 24),)),
                        )

                      ],
                    ));
                } else {
                  return const Center(child: Text("Loading Preview ....."));
                }
              }) ,


        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal,
        onTap: (val) {
          setState(() {
            widget.index = val;
           if(val ==0){
              widget.index = val;
              Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => RealTimeDataCamer(index: 0)),ModalRoute.withName(''),);
            }
          });
        },
        currentIndex: widget.index,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.control_camera),
            label: "ESP Camera",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
        ],
      ),
      // floatingActionButton: FloatingActionButton(enableFeedback: assine,onPressed: (){_flutterTts.speak("Camera See ${label!}");}, child: Icon(Icons.speaker_phone),),
    );
  }
}
