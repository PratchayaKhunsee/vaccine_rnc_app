library patient_selection_local;

import 'package:shared_preferences/shared_preferences.dart';

class PatientInfo {
  final int id;
  final String firstName;
  final String lastName;

  PatientInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
  });
}

enum PatientSelectionSection {
  certificate,
  record,
}

class PatientSelectionLocal {
  static SharedPreferences? _instance;

  static Future<SharedPreferences?> _getInstance() async {
    if (_instance == null) _instance = await SharedPreferences.getInstance();
    return _instance;
  }

  static String _determineSection(PatientSelectionSection section) {
    switch (section) {
      case PatientSelectionSection.certificate:
        return 'certificate';
      default:
        return 'record';
    }
  }

  static Future<bool> put(
    PatientSelectionSection section,
    PatientInfo patient,
  ) async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return false;
    String _section = _determineSection(section);

    bool x = await pref.setInt('$_section/id', patient.id);
    bool y = await pref.setString('$_section/firstname', patient.firstName);
    bool z = await pref.setString('$_section/lastname', patient.lastName);
    bool e = x && y && z;

    if (!e) {
      await remove(section);
      return false;
    }

    return true;
  }

  static Future<PatientInfo?> get(PatientSelectionSection section) async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return null;
    String _section = _determineSection(section);
    int? id = pref.getInt('$_section/id');
    String? firstName = pref.getString('$_section/firstname');
    String? lastName = pref.getString('$_section/lastname');
    if (id == null || firstName == null || lastName == null) return null;
    return PatientInfo(
      id: id,
      firstName: firstName,
      lastName: lastName,
    );
  }

  static Future<bool> remove(PatientSelectionSection section) async {
    SharedPreferences? pref = await _getInstance();
    if (pref == null) return false;
    String _section = _determineSection(section);
    await pref.remove('$_section/id');
    await pref.remove('$_section/firstname');
    await pref.remove('$_section/lastname');
    return true;
  }
}
