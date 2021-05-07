import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
//////
import 'global.dart' as global;
import 'src/modules/init.dart';
import 'src/modules/certificate.dart';
import 'src/modules/home.dart';
import 'src/modules/introduction.dart';
import 'src/modules/parenting.dart';
import 'src/modules/records.dart';
import 'src/modules/signup.dart';
import 'src/modules/user.dart';
import 'src/modules/login.dart';

/// The main widget named [MyApp].
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Init(),
        '/login': (context) => Login(),
        '/signup': (context) => SignUp(),
        '/home': (context) => Home(),
        '/intro': (context) => Introduction(),
        '/records': (context) => Records(),
        '/parenting': (context) => Parenting(),
        '/certificate': (context) => Certificate(),
        '/user': (context) => User()
      },
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'),
        Locale('th', 'TH'),
      ],
    );
  }
}

// ========== Initialization ========== //
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();
  // Get a specific camera from the list of available cameras.
  CameraDescription frontCamera;
  CameraDescription backCamera;
  cameras.forEach((cam) {
    if (cam.lensDirection == CameraLensDirection.front) {
      frontCamera = cam;
      return;
    }

    if (cam.lensDirection == CameraLensDirection.back) {
      backCamera = cam;
    }
  });
  // Setting saving camera to global instance
  global.Camera.front = frontCamera;
  global.Camera.back = backCamera;
  Intl.defaultLocale = 'th_TH';
  runApp(MyApp());
}
