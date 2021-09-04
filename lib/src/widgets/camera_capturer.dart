library camera_capturer;

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../devices/camera.dart';

class _CameraCapturerState extends State<CameraCapturer> {
  Uint8List? imageBytes;
  CameraInstance? instance = Camera.back;

  @override
  void initState() {
    initializeCamera().whenComplete(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initializeCamera() async {
    await instance?.initialize();
  }

  Widget buildCameraNotFoundWindow(BuildContext context) {
    return Container(
      color: Color(0xff000000),
      child: Center(
        child: Text.rich(TextSpan(
          text: 'ไม่พบกล้อง',
          style: TextStyle(
            color: Color(0xffffffff),
          ),
        )),
      ),
    );
  }

  Widget buildBeforeInitializedWindow(BuildContext context) {
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

  Widget buildCameraPreviewWindow(BuildContext context) {
    return Container(
      color: Color(0xff000000),
      child: Stack(
        children: [
          Center(
            child: instance?.buildPreview(),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              onPressed: () async {
                imageBytes = await instance?.takePicture();
                setState(() {});
                widget.onImageCaptured?.call(imageBytes);
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

  Widget buildImageCapturedWindow(BuildContext context) {
    return Container(
      color: Color(0xff000000),
      child: Stack(
        children: [
          Center(
            child: Image.memory(imageBytes!),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  imageBytes = null;
                });

                widget.onUndo!();
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

  @override
  Widget build(BuildContext context) {
    if (instance == null) return buildCameraNotFoundWindow(context);
    if (!instance!.initialized) return buildBeforeInitializedWindow(context);
    if (imageBytes != null) return buildImageCapturedWindow(context);
    return buildCameraPreviewWindow(context);
  }
}

/// The camera capturer widget.
class CameraCapturer extends StatefulWidget {
  /// Being triggered when the camera image is captured.
  final void Function(Uint8List? imageBytes)? onImageCaptured;

  /// Being triggered when revert the camera state.
  final void Function()? onUndo;

  CameraCapturer({
    Key? key,
    this.onImageCaptured,
    this.onUndo,
  }) : super(key: key);
  @override
  _CameraCapturerState createState() => _CameraCapturerState();
}
