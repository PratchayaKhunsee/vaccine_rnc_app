library camera;

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

/// The error instance that representing the camera package unsupported problem
/// on web and desktop platform.
class CameraUnsupportedError extends Error implements UnsupportedError {
  @override
  String get message =>
      '[Camera] package is unsupported for camera devices on Web and Desktop platform.';
}

/// The camera instance that representing the connection of the camera device.
abstract class CameraInstance {
  /// Take a picture and the return [Future] instance that should give the [Uint8List] of the picture.
  Future<Uint8List> takePicture();

  /// Get the widget that represents the camera preview display.
  Widget buildPreview({
    Key key,
  });

  /// Initialize the camera instance before you can actually use this instance.
  Future<void> initialize();

  /// The state of camera being initialized
  bool get initialized;
}

/// The widget for displaying the camera preview.
class CameraPreview extends StatelessWidget {
  final CameraInstance _instance;

  CameraPreview(
    this._instance, {
    Key? key,
  }) : super(
          key: key,
        );

  @override
  Widget build(BuildContext context) {
    if (_instance is PhoneCamera) {
      return (_instance as PhoneCamera)._controller.buildPreview();
    }

    throw CameraUnsupportedError();
  }
}

/// The connection of phone's camera device
class PhoneCamera extends CameraInstance {
  final CameraDescription _description;
  final CameraController _controller;
  final _CameraInitialized _initialized;

  PhoneCamera(this._description)
      : _controller = CameraController(
          _description,
          ResolutionPreset.max,
        ),
        _initialized = _CameraInitialized();

  bool get initialized => _initialized.value;

  @override
  Future<Uint8List> takePicture() async {
    XFile picture = await _controller.takePicture();
    return await picture.readAsBytes();
  }

  @override
  Widget buildPreview({
    Key? key,
  }) =>
      CameraPreview(
        this,
        key: key,
      );

  @override
  Future<void> initialize() async {
    await _controller.initialize();
    _initialized.value = true;
  }
}

class _CameraInitialized {
  bool value = false;
}

/// The camera namespace class.
///
/// It contains the static methods for controlling the detectable camera devices.
class Camera {
  static final List<CameraInstance> _instance = [];

  /// Get the first front phone camera instance.
  static CameraInstance get front => _instance.firstWhere(
        (cam) =>
            cam is PhoneCamera &&
            cam._description.lensDirection == CameraLensDirection.front,
      );

  /// Get the first back phone camera instance.
  static CameraInstance get back => _instance.firstWhere(
        (cam) =>
            cam is PhoneCamera &&
            cam._description.lensDirection == CameraLensDirection.back,
      );

  /// Get the list of camera instance.
  static List<CameraInstance> get instances => _instance.toList();

  /// Prepare the camera instances.
  ///
  /// - For mobile phone, you should call this method before call [runApp].
  static Future<void> prepare() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS))
      throw CameraUnsupportedError();

    final cams = await availableCameras();

    _instance.addAll(cams.map<PhoneCamera>((e) => PhoneCamera(e)).toList());
  }
}
