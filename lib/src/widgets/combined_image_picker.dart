library combined_image_picker;

import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'camera_capturer.dart';
import 'image_file_picker.dart';
import 'drawing_pad.dart';

enum _CombinedImagePickerMode {
  drawingPad,
  cameraCapturer,
  imagePicker,
}

class _CombinedImagePickerValue {
  Uint8List? drawingPad;
  Uint8List? cameraCapturer;
  Uint8List? imagePicker;
  _CombinedImagePickerMode mode = _CombinedImagePickerMode.drawingPad;

  void set value(Uint8List? v) {
    switch (mode) {
      case _CombinedImagePickerMode.cameraCapturer:
        cameraCapturer = v;
        break;
      case _CombinedImagePickerMode.drawingPad:
        drawingPad = v;
        break;
      case _CombinedImagePickerMode.imagePicker:
        imagePicker = v;
        break;
    }
  }

  Uint8List? get value {
    switch (mode) {
      case _CombinedImagePickerMode.cameraCapturer:
        return cameraCapturer;
      case _CombinedImagePickerMode.drawingPad:
        return drawingPad;
      case _CombinedImagePickerMode.imagePicker:
        return imagePicker;
    }
  }
}

/// The widget for image picking in various ways.
class CombinedImagePicker extends StatelessWidget {
  final void Function(Uint8List imageBytes)? onPicked;
  final _CombinedImagePickerValue _imageBytes;

  CombinedImagePicker({
    Key? key,
    this.onPicked,
  })  : this._imageBytes = _CombinedImagePickerValue(),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle tabTextStyle = TextStyle(color: Colors.blue);
    DrawingPad drawingPad = DrawingPad(
      onClear: () {
        _imageBytes.drawingPad = null;
      },
    );

    List<Tab> tabs = [
      Tab(
        child: Text(
          'ใช้ภาพวาดลายเซ็น',
          style: tabTextStyle,
        ),
      ),
      Tab(
        child: Text(
          'ใช้ไฟล์รูปภาพ',
          style: tabTextStyle,
        ),
      ),
    ];
    List<Builder> tabViews = [
      Builder(
        builder: (context) => Container(
          padding: EdgeInsets.all(10),
          color: Colors.grey,
          child: drawingPad,
        ),
      ),
      Builder(
        builder: (context) => ImageFilePicker(
          initialImageBytes: _imageBytes.imagePicker,
          onFilePicked: (imageBytes) {
            _imageBytes.imagePicker = imageBytes;
          },
        ),
      ),
    ];
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      tabs.add(Tab(
        child: Text(
          'ใช้กล้องถ่ายภาพ',
          style: tabTextStyle,
        ),
      ));
      tabViews.add(Builder(
        builder: (context) => CameraCapturer(
          onImageCaptured: (imageBytes) {
            _imageBytes.cameraCapturer = imageBytes;
          },
          onUndo: () {
            _imageBytes.cameraCapturer = null;
          },
        ),
      ));
    }
    List<_CombinedImagePickerMode> modes = const <_CombinedImagePickerMode>[
      _CombinedImagePickerMode.drawingPad,
      _CombinedImagePickerMode.imagePicker,
      _CombinedImagePickerMode.cameraCapturer,
    ];

    void onImageSelectedPressed() async {
      Uint8List? result;

      switch (_imageBytes.mode) {
        case _CombinedImagePickerMode.drawingPad:
          result = await drawingPad.getImageBytes() ?? null;
          break;
        case _CombinedImagePickerMode.cameraCapturer:
          result = _imageBytes.cameraCapturer;
          break;
        case _CombinedImagePickerMode.imagePicker:
          result = _imageBytes.imagePicker;
          break;
      }

      if (result != null) {
        onPicked?.call(result);
        Navigator.of(context).pop();
      }
    }

    DefaultTabController controller = DefaultTabController(
      length: !kIsWeb ? 3 : 2,
      child: Material(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // The tab for choosing the image picking tools
            Container(
              child: TabBar(
                tabs: tabs,
                onTap: (index) {
                  _imageBytes.mode = modes[index];
                },
              ),
            ),
            // The field of image picking tools
            Expanded(
              child: TabBarView(
                children: tabViews,
              ),
            ),
            // The button for confirming the picked image.
            Padding(
              padding: EdgeInsets.all(10),
              child: ElevatedButton(
                onPressed: onImageSelectedPressed,
                child: Text('เลือก'),
              ),
            ),
          ],
        ),
      ),
    );

    return controller;
  }
}
