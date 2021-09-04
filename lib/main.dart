import 'package:flutter/material.dart';
import 'src/devices/camera.dart';
import 'app.dart';

// ========== Initialization ========== //
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Run Camera.prepare() regardless of the current platform.
  try {
    await Camera.prepare();
  } catch (e) {}

  runApp(App());
}
