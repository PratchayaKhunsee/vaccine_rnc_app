import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '../../global.dart' as global;

class _State extends State<CameraCapturer> {
  CameraController controller;
  bool initialized = false;
  bool captured = false;
  DateTime timestamp;
  File file;
  String get path => '${global.Temp.directory.path}/__temp_camera_capturer__';
  String get tempFilePath => timestamp.toString().replaceAll(RegExp('\:'), '.');

  @override
  void initState() {
    controller = CameraController(
      widget.cameraSelection == CameraSelection.front
          ? global.Camera.front
          : global.Camera.back,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    controller.initialize().then((value) {
      Directory temp = Directory(path);
      if (!temp.existsSync()) temp.createSync(recursive: true);

      setState(() {
        initialized = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    Directory temp = Directory(path);
    if (temp.existsSync()) temp.deleteSync(recursive: true);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!initialized) {
      return Container(
        color: Color(0xff000000),
        child: Center(
          child: Text.rich(TextSpan(
            text: 'โปรดรอสักครู่',
            style: TextStyle(
              color: Color(0xffffffff),
            ),
          )),
        ),
      );
    }

    if (captured) {
      return Container(
        color: Color(0xff000000),
        child: Stack(
          children: [
            Center(
              child: Image.file(file),
            ),
            Positioned(
              bottom: 15,
              right: 15,
              child: FloatingActionButton(
                onPressed: () {
                  setState(() {
                    captured = false;
                    timestamp = null;
                    file = null;
                  });

                  widget.onUndo.call();
                },
                child: Icon(
                  Icons.undo,
                  size: 36,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // debugPrint('Waiting for a picture...');
    return Container(
      color: Color(0xff000000),
      child: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: CameraPreview(controller),
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              onPressed: () async {
                timestamp = DateTime.now();
                // debugPrint('$path/$tempFilePath');
                await controller.takePicture();

                setState(() {
                  file = File('$path/$tempFilePath');
                  captured = true;
                });

                widget.onCapture?.call(file);
              },
              backgroundColor: Colors.teal,
              child: Icon(
                Icons.camera_alt,
                size: 36,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum CameraSelection { front, back }

class CameraCapturer extends StatefulWidget {
  final CameraSelection cameraSelection;
  final void Function(File imageFile) onCapture;
  final void Function() onUndo;

  CameraCapturer({
    Key key,
    this.cameraSelection,
    this.onCapture,
    this.onUndo,
  }) : super(key: key);
  @override
  _State createState() => _State();
}
