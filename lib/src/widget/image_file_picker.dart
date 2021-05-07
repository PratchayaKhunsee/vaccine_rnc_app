import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:file_picker/file_picker.dart';

class _State extends State<ImageFilePicker> {
  File file;

  @override
  Widget build(BuildContext context) {
    if (file != null) {
      return Container(
        child: Stack(
          children: [
            Center(
              child: Image.file(file),
            ),
            Positioned(
              bottom: 15,
              child: Container(
                width: MediaQuery.of(context).size.width,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        FilePickerResult result =
                            await FilePicker.platform.pickFiles(
                          type: FileType.image,
                        );

                        if (result != null) {
                          setState(() {
                            file = File(result.files.single.path);
                          });
                        }

                        widget.onFilePicked?.call(file);
                      },
                      icon: Icon(Icons.image),
                      label: Text('เลือกรูปภาพ'),
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(8),
                      // ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      child: Center(
        child: ElevatedButton.icon(
          onPressed: () async {
            FilePickerResult result = await FilePicker.platform.pickFiles(
              type: FileType.image,
            );

            if (result != null) {
              setState(() {
                file = File(result.files.single.path);
              });

              widget.onFilePicked?.call(file);
            }
          },
          icon: Icon(Icons.image),
          label: Text('เลือกรูปภาพ'),
          // shape: RoundedRectangleBorder(
          //   borderRadius: BorderRadius.circular(8),
          // ),
        ),
      ),
    );
  }
}

class ImageFilePicker extends StatefulWidget {
  final void Function(File file) onFilePicked;

  const ImageFilePicker({
    Key key,
    this.onFilePicked,
  }) : super(key: key);

  @override
  _State createState() => _State();
}
