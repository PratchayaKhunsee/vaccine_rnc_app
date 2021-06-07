library app.global;

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as Http;
// import 'package:flutter/services.dart' show rootBundle;

/// The application key for communication.
// class AppKey {
//   static String _key;
//   static Future<String> get() async {
//     if (_key == null) {
//       _key = await rootBundle.loadString('assets/app.key');
//     }
//     return _key;
//   }
// }

set host(String str) {
  VaccineDatabaseSource.host = str;
}

String get host => VaccineDatabaseSource.host;

class Authorization {
  static Future<bool> put(String encoded) async {
    SharedPreferences pref = await LocalStorage.instance();
    bool c = await pref.setString('Authorization', 'JWT $encoded');
    return c;
  }

  static Future<bool> delete() async {
    SharedPreferences pref = await LocalStorage.instance();
    bool c = await pref.remove('Authorization');
    return c;
  }

  static Future<String> get() async {
    SharedPreferences pref = await LocalStorage.instance();
    String c = pref.getString('Authorization');
    return c;
  }
}

class VaccineDatabaseSource {
  static String host = 'https://vaccine-vnc-database.herokuapp.com';
  static Uri uri(String path) => Uri(
        host: 'vaccine-database.herokuapp.com',
        path: path,
        scheme: 'https',
      );

  /// Get user information.
  static Future<Map<String, dynamic>> getUserInfo() async {
    Http.Response res = await Http.get(
      uri('/user/view'),
      headers: {
        'Authorization': await Authorization.get(),
      },
    );

    if (res.statusCode != 200) {
      throw res.statusCode;
    }

    Map<String, dynamic> info = json.decode(res.body);
    return info;
  }

  /// Update user information
  static Future<Map<String, dynamic>> updateUserInfo(
      Map<String, dynamic> userInfo) async {
    Http.Response res = await Http.post(
      uri('/user/info/edit'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode(userInfo),
    );

    if (res.statusCode != 200) {
      throw res.statusCode;
    }

    var result = json.decode(res.body);
    return result;
  }

  /// Get all available patient for user.
  static Future<List<Map<String, dynamic>>> getAvailablePatient() async {
    Http.Response res = await Http.get(
      uri('/patient/view'),
      headers: {
        'Authorization': await Authorization.get(),
      },
    );

    var body = json.decode(res.body);
    List<Map<String, dynamic>> result = [];

    if (res.statusCode != 200) throw body;

    (body as List).forEach((element) {
      result.add(element as Map<String, dynamic>);
    });

    return result;
  }

  /// Create user's patient for accessing vaccine record.
  static Future<Map<String, dynamic>> createOwnPatient({
    @required String firstname,
    @required String lastname,
  }) async {
    var res = await Http.post(
      uri('/patient/create/self'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstname': firstname,
        'lastname': lastname,
      }),
    );

    Map<String, dynamic> body = json.decode(res.body);

    if (res.statusCode != 201) {
      throw body;
    }

    return body;
  }

  /// Get the selected vaccine record by patient identity.
  static Future<Map<String, dynamic>> viewRecord({
    @required int patientID,
  }) async {
    var res = await Http.post(
      uri('/record/view'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientID,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> createRecord({
    @required int patientID,
  }) async {
    var res = await Http.post(
      uri('/record/create'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientID,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 201) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> updateRecord(
      Map<String, dynamic> map) async {
    var res = await Http.post(
      uri('/record/edit'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode(map),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> createPatientAsChild({
    @required String firstname,
    @required String lastname,
    // @required int personId,
  }) async {
    var res = await Http.post(
      uri('/patient/create'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstname': firstname,
        'lastname': lastname,
        // 'person_id': personId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 201) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> updatePatient({
    @required String firstname,
    @required String lastname,
  }) async {
    var res = await Http.post(
      uri('/patient/edit'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'firstname': firstname,
        'lastname': lastname,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<bool> removePatient(int patientId) async {
    var res = await Http.post(
      uri('/patient/remove'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<List<Map<String, dynamic>>> viewCertification(
    int patientId,
  ) async {
    var res = await Http.post(
      uri('/certificate/view'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }
    List<Map<String, dynamic>> list = [];
    if (body is List) {
      body.forEach((element) {
        list.add(Map<String, dynamic>.from(element));
      });
    }
    return list;
  }

  static Future<dynamic> listCertification(
    int patientId,
  ) async {
    var res = await Http.post(
      uri('/certificate/list'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    switch (res.statusCode) {
      case 204:
        return <Map<String, dynamic>>[];
      case 200:
        break;
      case 400:
        throw json.decode(res.body);
    }

    var body = json.decode(res.body);

    List<Map<String, dynamic>> list = [];
    if (body is List) {
      body.forEach((element) {
        list.add(Map<String, dynamic>.from(element));
      });
    }
    return list;
  }

  static Future<Map<String, dynamic>> createCertification({
    @required int patientId,
    @required String against,
  }) async {
    var res = await Http.post(
      uri('/certificate/create'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
        'against': against,
      }),
    );
    var body = json.decode(res.body);
    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<List<String>> getAvailableVaccination(
    int patientId,
  ) async {
    var res = await Http.post(
      uri('/certificate/available'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    List<String> result = <String>[];
    if (body is List) {
      body.forEach((element) {
        result.add('$element');
      });
    }
    // debugPrint('$result');

    return result;
  }

  static Future<Map<String, dynamic>> viewCertificate(
      int certificateId, int patientId) async {
    var res = await Http.post(
      uri('/certificate/view'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
        'certificate_id': certificateId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> editCertificate(
    Map<String, dynamic> updatedCert,
  ) async {
    var res = await Http.post(
      uri('/certificate/edit'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode(updatedCert),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> getFullCertification({
    int patientId,
  }) async {
    var res = await Http.post(
      uri('/certificate/list/full'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    var result = {
      'header': <String, dynamic>{},
      'list': <Map<String, dynamic>>[],
    };

    if (body['header'] is Map) {
      (result['header'] as Map<String, dynamic>).addAll(body['header']);
    }

    if (body['list'] is List) {
      (result['list'] as List<Map<String, dynamic>>).addAll(
          (body['list'] as List<dynamic>)
              .map<Map<String, dynamic>>((e) => e)
              .toList());
    }

    return result;
  }

  static Future<Map<String, dynamic>> viewCertHeader(
    int patientId,
  ) async {
    var res = await Http.post(
      uri('/certificate/view/header'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'patient_id': patientId,
      }),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }

  static Future<Map<String, dynamic>> editCertHeader(
      {int patientId, Map<String, dynamic> editedMap}) async {
    Map<String, dynamic> requestBody = {'patient_id': patientId};
    requestBody.addAll(editedMap);

    // debugPrint('$requestBody');

    var res = await Http.post(
      uri('/certificate/edit/header'),
      headers: {
        'Authorization': await Authorization.get(),
        'Content-Type': 'application/json',
      },
      body: json.encode(requestBody),
    );

    var body = json.decode(res.body);

    if (res.statusCode != 200) {
      throw body;
    }

    return body;
  }
}

class LocalStorage {
  static SharedPreferences _pref;
  static Future<SharedPreferences> instance() async {
    if (_pref == null) _pref = await SharedPreferences.getInstance();
    return _pref;
  }
}

class Camera {
  // static CameraDescription description;
  static CameraDescription front;
  static CameraDescription back;
}

class StatusBar {
  static double height;
}

class Temp {
  static Directory directory;
}

class LoadingIcon {
  static Widget tiny() => SizedBox(
        width: 18,
        height: 18,
        child: CircularProgressIndicator(
          strokeWidth: 1,
        ),
      );
  static Widget small() => SizedBox(
        width: 32,
        height: 32,
        child: CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
  static Widget medium() => SizedBox(
        width: 64,
        height: 64,
        child: CircularProgressIndicator(
          strokeWidth: 5,
        ),
      );
  static Widget large() => SizedBox(
        width: 128,
        height: 128,
        child: CircularProgressIndicator(
          strokeWidth: 10,
        ),
      );
}
