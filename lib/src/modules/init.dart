import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as Http;
import '../../global.dart' as global;

// ============= Function =============== //

/// The asynchronous login authentication function
Future<bool> _authenticate() async {
  String token = await global.Authorization.get();
  if (token == null) return false;

  Http.Response res = await Http.post(
    global.VaccineDatabaseSource.uri('/login'),
    headers: {
      'Authorization': token,
    },
  );

  Map body = json.decode(res.body);
  return body['verified'] as bool;
}

Future<bool> _checkConnectivity(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();
  if (connectivityResult == ConnectivityResult.none) {
    // Display dialog "no internet"
    await showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('ไม่มีการเชื่อมต่ออินเทอร์เน็ต'),
        content: Text(
            'แอปพลิเคชันนี้ต้องการการเชื่อมต่ออินเทอร์เน็ต กรุณาทำการเชื่อมต่ออินเทอร์เน็ตแล้วลองใหม่อีกครั้ง'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('ปิดแอปพลิเคชัน'),
          ),
        ],
      ),
    );

    SystemNavigator.pop();
    return false;
  }

  return true;
}

/// The first page of the app.
///
/// * Contained nothing but a circular progress indicator.
/// * The background process attempts to do login authentication first,
///   then routing to another page.
class Init extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    MediaQueryData mediaQuery = MediaQuery.of(context);
    global.StatusBar.height = mediaQuery.padding.top;

    _checkConnectivity(context).then((connected) async {
      if (connected) {
        _authenticate().then((value) async {
          global.Temp.directory = await getTemporaryDirectory();
          Navigator.pushNamedAndRemoveUntil(
            context,
            value ? '/home' : '/login',
            (route) => false,
          );
        });
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: Color(0xffffffff),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * .5,
            height: MediaQuery.of(context).size.width * .5,
            child: CircularProgressIndicator(
              strokeWidth: 10,
            ),
          ),
        ],
      ),
    );
  }
}
