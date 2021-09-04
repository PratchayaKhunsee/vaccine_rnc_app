import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class _ImageBytesGetter {
  Future<Uint8List?> Function()? getter;
}

class _DrawingPadState extends State<DrawingPad> {
  SignatureController controller;
  _DrawingPadState()
      : controller = SignatureController(
          penStrokeWidth: 1.5,
        ),
        super();

  @override
  void initState() {
    super.initState();
    widget._getter.getter = () => controller.toPngBytes();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void onClearButtonPressed() {
    controller.clear();
    widget.onClear?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The main drawing pad canvas.
        Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Signature(
                controller: controller,
                backgroundColor: Colors.white,
              ),
            ],
          ),
        ),
        // The action button for controlling drawing pad canvas.
        Positioned(
          bottom: 10,
          right: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // The clearing drawing pad canvas button.
              ElevatedButton.icon(
                onPressed: onClearButtonPressed,
                icon: Icon(Icons.delete),
                label: Text('ล้างหน้าจอ'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The drawing pad canvas widget.
///
/// It was powered by [Signature] package.
class DrawingPad extends StatefulWidget {
  /// Being triggered when the user clear the canvas.
  final void Function()? onClear;

  /// Being triggered when the user confirm using the current canvas image.
  final void Function(Uint8List imageBytes)? onConfirmed;

  final _ImageBytesGetter _getter = _ImageBytesGetter();

  DrawingPad({
    Key? key,
    this.onClear,
    this.onConfirmed,
  }) : super(key: key);

  @override
  _DrawingPadState createState() => _DrawingPadState();

  Future<Uint8List?> getImageBytes() async {
    return _getter.getter?.call();
  }
}
