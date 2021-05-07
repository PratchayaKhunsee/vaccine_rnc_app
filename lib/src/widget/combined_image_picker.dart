import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'camera_capturer.dart';
import 'custom_button.dart';
import 'drawing_pad.dart';
import 'image_file_picker.dart';
import 'persistent_widget.dart';
import '../../global.dart' as global;

String getTempDirPath() =>
    '${global.Temp.directory.path}/__combined_image_picker__';
String getTempFilePath() => '${getTempDirPath()}/${DateTime.now().toLocal()}'
    .replaceAll(RegExp('\:'), '.');

class _FileProvider extends ChangeNotifier {
  final List<File> _files = <File>[];
  int _index = 0;

  _FileProvider({
    int size = 1,
  }) : super() {
    while (size > 0) {
      _files.add(null);
      --size;
    }
  }

  List<File> get files => _files;
  int get index => _index;
  File get selectedFile => _files[_index];
  void setFile(int index, File f) {
    _files[index] = f;
    notifyListeners();
  }

  void setIndex(int i) {
    _index = i;
    notifyListeners();
  }
}

class _ImageFileProvider extends ChangeNotifier {
  File _file;
  File get file => _file;
  void setFile(File file) {
    _file = file;
    notifyListeners();
  }

  void setFileFromBase64(String base64Context) async {
    if (base64Context == null) return;

    Directory dir = Directory(getTempDirPath());
    bool dirExist = await dir.exists();
    if (!dirExist) await dir.create(recursive: true);
    String path = getTempFilePath();
    File file = File(path);
    String fixedBase64 = base64Context.replaceAll(RegExp('(\r|\n|\r\n)'), '');
    await file.writeAsBytes(base64.decode(base64.normalize(fixedBase64)));
    _file = file;
    notifyListeners();
  }
}

class CombinedImagePicker extends PersistentWidget {
  final bool _isCameraClosed;
  final bool _isDrawingPadClosed;
  final bool _isFileUploaderClosed;
  final void Function(File imageFile) onImageChange;
  final _ImageFileProvider _image = _ImageFileProvider();

  CombinedImagePicker({
    String base64ToFile,
    bool isCameraClosed,
    bool isDrawingPadClosed,
    bool isFileUploaderClosed,
    this.onImageChange,
  })  : _isCameraClosed = isCameraClosed == true,
        _isDrawingPadClosed = isDrawingPadClosed == true,
        _isFileUploaderClosed = isFileUploaderClosed == true,
        super() {
    if (base64ToFile != null) {
      _image.setFileFromBase64(base64ToFile);
    }
  }

  Future _showPanel(BuildContext context) async {
    List<Widget> panel = [];
    List<Tab> tabs = [];
    int tempIndex = 0;
    bool confirmed = false;
    _FileProvider provider = _FileProvider(
      size: (!_isCameraClosed ? 1 : 0) +
          (!_isDrawingPadClosed ? 1 : 0) +
          (!_isFileUploaderClosed ? 1 : 0),
    );

    if (!_isCameraClosed) {
      int i = tempIndex++;

      panel.add(PersistentWidget(
        child: CameraCapturer(
          cameraSelection: CameraSelection.back,
          onCapture: (imageFile) {
            provider.setFile(i, imageFile);
          },
        ),
      ));
      tabs.add(Tab(
        text: 'ใช้กล้องถ่ายรูป',
      ));
    }

    if (!_isFileUploaderClosed) {
      int i = tempIndex++;

      panel.add(PersistentWidget(
        child: ImageFilePicker(
          onFilePicked: (file) {
            provider.setFile(i, file);
          },
        ),
      ));
      tabs.add(Tab(
        text: 'ใช้ไฟล์รูปภาพ',
      ));
    }

    if (!_isDrawingPadClosed) {
      int i = tempIndex++;

      panel.add(PersistentWidget(
        child: DrawingPad(
          onConfirmed: (file) {
            provider.setFile(i, file);
          },
          onClear: () {
            provider.setFile(i, null);
          },
        ),
      ));
      tabs.add(Tab(
        text: 'ใช้ภาพวาดมือ',
      ));
    }

    Widget bottomSheet = Container(
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: DefaultTabController(
              length: tempIndex,
              child: Container(
                child: Column(
                  children: [
                    TabBar(
                      tabs: tabs,
                      isScrollable: true,
                      labelColor: Theme.of(context).primaryColor,
                      onTap: (value) {
                        provider.setIndex(value);
                      },
                    ),
                    Expanded(
                      flex: 2,
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        children: panel,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          ChangeNotifierProvider.value(
            value: provider,
            builder: (context, child) => Consumer<_FileProvider>(
              builder: (context, value, child) => CustomButton(
                child: Text('เลือก'),
                onPressed: value.selectedFile != null
                    ? () {
                        confirmed = true;
                        Navigator.of(context).pop();
                      }
                    : null,
              ),
            ),
          ),
        ],
      ),
    );

    await showModalBottomSheet(
      context: context,
      builder: (context) => bottomSheet,
    );

    return confirmed ? provider.selectedFile : null;
  }

  File get imageFile => _image.file;
  void setImageByBase64(String base64) {
    _image.setFileFromBase64(base64);
  }

  @override
  Widget get child {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChangeNotifierProvider.value(
            value: _image,
            builder: (context, child) => Consumer<_ImageFileProvider>(
              builder: (context, image, child) => Builder(
                builder: (context) {
                  if (image.file == null) {
                    return AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        color: Color(0x6e000000),
                        child: Center(
                          child: Text(
                            'โปรดเลือกรูปภาพ',
                            textScaleFactor: 1.5,
                          ),
                        ),
                      ),
                    );
                  }

                  return Container(
                    child: Image.file(image.file),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5),
          ),
          Builder(
            builder: (context) => ElevatedButton(
              child: Text('เปลี่ยนรูปภาพ'),
              onPressed: () async {
                File imageFile = await _showPanel(context);
                if (imageFile != null) {
                  _image.setFile(imageFile);

                  onImageChange(imageFile);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
