import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class _ImageFilePickerState extends State<ImageFilePicker> {
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    imageBytes = widget.initialImageBytes;
  }

  void onImagaPickingButtonPressed() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      setState(() {
        imageBytes = result.files.single.bytes;
      });

      widget.onFilePicked?.call(imageBytes!);
    }
  }

  Widget buildFilePickedWindow(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Stack(
        children: [
          Center(
            child: Image.memory(imageBytes!),
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: ElevatedButton.icon(
              onPressed: onImagaPickingButtonPressed,
              icon: Icon(Icons.image),
              label: Text('เลือกรูปภาพ'),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNoFilePickedWindow(BuildContext context) {
    return Container(
      color: Colors.grey,
      child: Center(
        child: ElevatedButton.icon(
          onPressed: onImagaPickingButtonPressed,
          icon: Icon(Icons.image),
          label: Text('เลือกรูปภาพ'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (imageBytes != null) return buildFilePickedWindow(context);
    return buildNoFilePickedWindow(context);
  }
}

/// The image file picker widget.
class ImageFilePicker extends StatefulWidget {
  /// Being triggered when the image file is already picked.
  final void Function(Uint8List imageBytes)? onFilePicked;
  final Uint8List? initialImageBytes;

  ImageFilePicker({
    Key? key,
    this.initialImageBytes,
    this.onFilePicked,
  }) : super(key: key);

  @override
  _ImageFilePickerState createState() => _ImageFilePickerState();
}
