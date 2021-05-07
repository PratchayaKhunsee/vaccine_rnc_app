import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:signature/signature.dart';
import '../../global.dart' as global;

class _State extends State<DrawingPad> {
  SignatureController controller;
  File file;
  DateTime timestamp;
  bool confirmed = false;
  String get path => '${global.Temp.directory.path}/__temp_drawing_pad__';
  String get tempFileName => timestamp.toString().replaceAll(RegExp('\:'), '.');

  @override
  void initState() {
    controller = SignatureController();
    Directory directory = Directory(path);
    directory.createSync(recursive: true);
    super.initState();
  }

  @override
  void dispose() {
    controller?.dispose();
    Directory directory = Directory(path);
    directory.deleteSync(recursive: true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (confirmed) {
      return Container(
        child: Stack(
          children: [
            Center(
              child: Image.file(file),
            ),
            Positioned(
              top: 15,
              left: 15,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    confirmed = false;
                    file = null;
                  });
                },
                icon: Icon(Icons.edit),
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.circular(8),
                // ),
                label: Text('แก้ไข'),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      child: Stack(
        children: [
          Container(
            child: Row(
              children: [
                Signature(
                  controller: controller,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 15,
            right: 15,
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    controller.clear();
                    widget.onClear?.call();
                  },
                  icon: Icon(
                    Icons.delete,
                  ),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  label: Text('ล้างหน้าจอ'),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    Uint8List fixedBytes = await controller.toPngBytes();
                    List<int> arrayBytes = fixedBytes.toList();
                    timestamp = DateTime.now();
                    file = File('$path/$tempFileName');
                    await file.writeAsBytes(arrayBytes);
                    setState(() {
                      confirmed = true;
                    });

                    widget.onConfirmed?.call(file);
                  },
                  icon: Icon(
                    Icons.done,
                  ),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(8),
                  // ),
                  label: Text('ยืนยัน'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DrawingPad extends StatefulWidget {
  final void Function() onClear;
  final void Function(File file) onConfirmed;

  const DrawingPad({
    Key key,
    this.onClear,
    this.onConfirmed,
  }) : super(key: key);
  @override
  _State createState() => _State();
}
