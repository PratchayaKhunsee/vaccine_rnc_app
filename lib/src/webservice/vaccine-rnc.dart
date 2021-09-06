library vaccine_rnc_database;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:multipart_usage/multipart_usage.dart';

import '../localstorage/authorization.dart';
import '../errors.dart';
import '../utils.dart' as Utils;

import 'package:verbose_fetch/verbose_fetch.dart';

/// The instance of user information from HTTP response.
class UserInfoResult {
  final String firstName;
  final String lastName;
  final int gender;
  final int namePrefix;
  final String username;
  UserInfoResult(Map<String, dynamic> body)
      : firstName = body['firstname'],
        lastName = body['lastname'],
        gender = body['gender'],
        namePrefix = body['name_prefix'],
        username = body['username'];
}

/// The instance of patient information from HTTP response.
class PatientResult {
  final String firstName;
  final String lastName;
  final int id;

  PatientResult(Map<String, dynamic> body)
      : firstName = body['firstname'],
        lastName = body['lastname'],
        id = body['id'];
}

/// The instance of vaccine record result
class VaccineRecordResult {
  final int id;
  final DateTime? bcgFirst;
  final DateTime? hbFirst;
  final DateTime? hbSecond;
  final DateTime? opvEarlyFirst;
  final DateTime? opvEarlySecond;
  final DateTime? opvEarlyThird;
  final DateTime? dtpHbFirst;
  final DateTime? dtpHbSecond;
  final DateTime? dtpHbThird;
  final DateTime? ipvFirst;
  final DateTime? mmrFirst;
  final DateTime? mmrSecond;
  final DateTime? jeFirst;
  final DateTime? jeSecond;
  final DateTime? opvLaterFirst;
  final DateTime? opvLaterSecond;
  final DateTime? dtpFirst;
  final DateTime? dtpSecond;
  final DateTime? hpvFirst;
  final DateTime? dtFirst;

  VaccineRecordResult(Map<String, dynamic> record)
      : id = record['id'],
        bcgFirst = DateTime.tryParse(record['bcg_first'] ?? ''),
        hbFirst = DateTime.tryParse(record['hb_first'] ?? ''),
        hbSecond = DateTime.tryParse(record['hb_second'] ?? ''),
        opvEarlyFirst = DateTime.tryParse(record['opv_early_first'] ?? ''),
        opvEarlySecond = DateTime.tryParse(record['opv_early_second'] ?? ''),
        opvEarlyThird = DateTime.tryParse(record['opv_early_third'] ?? ''),
        dtpHbFirst = DateTime.tryParse(record['dtp_hb_first'] ?? ''),
        dtpHbSecond = DateTime.tryParse(record['dtp_hb_second'] ?? ''),
        dtpHbThird = DateTime.tryParse(record['dtp_hb_third'] ?? ''),
        ipvFirst = DateTime.tryParse(record['ipv_first'] ?? ''),
        mmrFirst = DateTime.tryParse(record['mmr_first'] ?? ''),
        mmrSecond = DateTime.tryParse(record['mmr_second'] ?? ''),
        jeFirst = DateTime.tryParse(record['je_first'] ?? ''),
        jeSecond = DateTime.tryParse(record['je_second'] ?? ''),
        opvLaterFirst = DateTime.tryParse(record['opv_later_first'] ?? ''),
        opvLaterSecond = DateTime.tryParse(record['opv_later_second'] ?? ''),
        dtpFirst = DateTime.tryParse(record['dtp_first'] ?? ''),
        dtpSecond = DateTime.tryParse(record['dtp_second'] ?? ''),
        hpvFirst = DateTime.tryParse(record['hpv_first'] ?? ''),
        dtFirst = DateTime.tryParse(record['dt_first'] ?? '');

  Map<String, DateTime?> toMap() => {
        'bcg_first': bcgFirst,
        'hb_first': hbFirst,
        'hb_second': hbSecond,
        'opv_early_first': opvEarlyFirst,
        'opv_early_second': opvEarlySecond,
        'opv_early_third': opvEarlyThird,
        'dtp_hb_first': dtpHbFirst,
        'dtp_hb_second': dtpHbSecond,
        'dtp_hb_third': dtpHbThird,
        'ipv_first': ipvFirst,
        'mmr_first': mmrFirst,
        'mmr_second': mmrSecond,
        'je_first': jeFirst,
        'je_second': jeSecond,
        'opv_later_first': opvLaterFirst,
        'opv_later_second': opvLaterSecond,
        'dtp_first': dtpFirst,
        'dtp_second': dtpSecond,
        'hpv_first': hpvFirst,
        'dt_first': dtFirst,
      };
}

class BreifyCertification {
  final int id;
  final String vaccineAgainst;

  BreifyCertification({
    required this.id,
    required this.vaccineAgainst,
  });
}

class BriefyVaccineCertificationResult {
  late final String? fullName;
  late final String? nationality;
  late final String? againstDescription;
  late final int sex;
  late final Uint8List? signature;
  late final DateTime? dateOfBirth;
  final List<BreifyCertification> certificateList = [];
  BriefyVaccineCertificationResult(List<FormDataField> entries) {
    for (var e in entries) {
      var value = e.tryJsonDecodeValue();

      switch (e.name) {
        case 'fullname_in_cert':
          fullName = value;
          break;
        case 'nationality':
          nationality = value;
          break;
        case 'against_description':
          againstDescription = value;
          break;
        case 'sex':
          sex = value;
          break;
        case 'date_of_birth':
          dateOfBirth = value is String ? DateTime.tryParse(value) : null;
          break;
        case 'signature':
          if (value is String) {
            signature = Uint8List.fromList(utf8.encode(value));
            break;
          }
          if (e is FileField) {
            signature = value as Uint8List;
            break;
          }

          signature = null;

          break;
        case 'certificate_list':
          try {
            List li = json.decode(utf8.decode(value, allowMalformed: true));

            List<BreifyCertification> c = [];

            for (var v in li) {
              if (v is Map<String, dynamic>) {
                c.add(BreifyCertification(
                  id: v['id'],
                  vaccineAgainst: v['vaccine_against'],
                ));
              }
            }

            certificateList.addAll(c);
          } catch (e) {}

          break;
      }
    }
  }
}

class _Cert {
  final int id;
  final String? vaccineAgainst;
  final String? vaccineName;
  final String? vaccineManufacturer;
  final String? vaccineBatchNumber;
  final DateTime? certifyFrom;
  final DateTime? certifyTo;
  final Uint8List? clinicianSignature;
  final String? clinicianProfStatus;
  final Uint8List? administringCentreStamp;

  _Cert({
    required this.id,
    this.vaccineAgainst,
    this.vaccineName,
    this.vaccineManufacturer,
    this.vaccineBatchNumber,
    this.certifyFrom,
    this.certifyTo,
    this.clinicianSignature,
    this.clinicianProfStatus,
    this.administringCentreStamp,
  });
}

class CertificationResult {
  final int id;
  final String? vaccineAgainst;
  final String? vaccineName;
  final String? vaccineManufacturer;
  final String? vaccineBatchNumber;
  final DateTime? certifyFrom;
  final DateTime? certifyTo;
  final Uint8List? clinicianSignature;
  final String? clinicianProfStatus;
  final Uint8List? administringCentreStamp;
  CertificationResult(_Cert c)
      : id = c.id,
        vaccineAgainst = c.vaccineAgainst,
        vaccineName = c.vaccineName,
        vaccineBatchNumber = c.vaccineBatchNumber,
        vaccineManufacturer = c.vaccineManufacturer,
        certifyFrom = c.certifyFrom,
        certifyTo = c.certifyTo,
        clinicianProfStatus = c.clinicianProfStatus,
        clinicianSignature = c.clinicianSignature,
        administringCentreStamp = c.administringCentreStamp;
}

class Certification {
  final int id;
  final String? vaccineAgainst;
  final String? vaccineName;
  final String? vaccineManufacturer;
  final String? vaccineBatchNumber;
  final DateTime? certifyFrom;
  final DateTime? certifyTo;
  final Uint8List? clinicianSignature;
  final String? clinicianProfStatus;
  final Uint8List? administringCentreStamp;
  Certification({
    required this.id,
    required this.vaccineAgainst,
    this.vaccineName,
    this.vaccineManufacturer,
    this.vaccineBatchNumber,
    this.certifyFrom,
    this.certifyTo,
    this.clinicianSignature,
    this.clinicianProfStatus,
    this.administringCentreStamp,
  });
}

class CompletedVaccineCertificationResult {
  late final String? fullName;
  late final String? nationality;
  late final String? againstDescription;
  late final int sex;
  late final Uint8List? signature;
  late final DateTime? dateOfBirth;
  final List<CertificationResult> certificateList = [];
  CompletedVaccineCertificationResult(List<FormDataField> entries) {
    for (var e in entries) {
      var value = e.tryJsonDecodeValue();

      switch (e.name) {
        case 'fullname_in_cert':
          fullName = value;
          break;
        case 'nationality':
          nationality = value;
          break;
        case 'against_description':
          againstDescription = value;
          break;
        case 'sex':
          sex = value;
          break;
        case 'date_of_birth':
          dateOfBirth = value is String ? DateTime.tryParse(value) : null;
          break;
        case 'signature':
          if (value is String) {
            signature = Uint8List.fromList(utf8.encode(value));
            break;
          }
          if (e is FileField) {
            signature = value as Uint8List;
            break;
          }

          signature = null;

          break;
        case 'certificate_list':
          if (value == null || value is! Uint8List) break;

          MultipartReader reader = MultipartReader(value);

          late int id;
          String? vaccineAgainst;
          String? vaccineName;
          String? vaccineManufacturer;
          String? vaccineBatchNumber;
          DateTime? certifyFrom;
          DateTime? certifyTo;
          Uint8List? clinicianSignature;
          String? clinicianProfStatus;
          Uint8List? administringCentreStamp;

          for (var e in reader.get()) {
            Uint8List value = e.value;
            String utf8String = utf8.decode(value, allowMalformed: true);
            dynamic jsonValue;
            bool isJsonConvertible = false;
            try {
              jsonValue = json.decode(utf8String);
              isJsonConvertible = true;
            } catch (err) {}

            switch (e.name) {
              case 'id':
                id = jsonValue;
                break;
              case 'vaccine_against':
                vaccineAgainst =
                    isJsonConvertible && jsonValue == null ? null : utf8String;
                break;
              case 'vaccine_name':
                vaccineName =
                    isJsonConvertible && jsonValue == null ? null : utf8String;
                break;
              case 'vaccine_manufacturer':
                vaccineManufacturer =
                    isJsonConvertible && jsonValue == null ? null : utf8String;
                break;
              case 'vaccine_batch_number':
                vaccineBatchNumber =
                    isJsonConvertible && jsonValue == null ? null : utf8String;
                break;
              case 'certify_from':
                certifyFrom = DateTime.tryParse(utf8String);
                break;
              case 'certify_to':
                certifyTo = DateTime.tryParse(utf8String);
                break;
              case 'clinician_prof_status':
                clinicianProfStatus =
                    isJsonConvertible && jsonValue == null ? null : utf8String;
                break;
              case 'clinician_signature':
                clinicianSignature =
                    isJsonConvertible && jsonValue == null ? null : value;
                break;
              case 'administring_centre_stamp':
                administringCentreStamp =
                    isJsonConvertible && jsonValue == null ? null : value;

                break;
            }
          }

          certificateList.add(CertificationResult(_Cert(
            id: id,
            vaccineName: vaccineName,
            vaccineBatchNumber: vaccineBatchNumber,
            vaccineManufacturer: vaccineManufacturer,
            vaccineAgainst: vaccineAgainst,
            certifyFrom: certifyFrom,
            certifyTo: certifyTo,
            clinicianProfStatus: clinicianProfStatus,
            clinicianSignature: clinicianSignature,
            administringCentreStamp: administringCentreStamp,
          )));
          break;
      }
    }
  }
}

/// The namespace class of the vaccine record and certificate
/// database management across the internet.
///
/// It can manipulate the vaccination and application's user account data
/// from the database through the RESTful web service.
/// The web service also have user's login authentication mechanism to
/// maintain the application user's authencity.
abstract class VaccineRNCDatabaseWS {
  /// The URL of vaccine record and certificate database web service.
  static final String host = 'vaccine-rnc-database.herokuapp.com';

  /// Create the [Uri] instance that locating to the vaccine record and certificate
  /// database web service.
  static Uri uri(String path) => Uri(
        host: host,
        path: path,
        scheme: 'https',
      );

  // / The reuseable [Http.Client] instance.
  // static Http.Client _client = Http.Client();

  /// Determine how the error should be represented by the [WebServiceResponseError] instance.
  static WebServiceResponseError _determineErrorFromBody(
    Map<String, dynamic> errorJson,
  ) {
    switch (errorJson['errorCode']) {
      case 9000:
        return UserNotFoundError();
      case 9001:
        return PasswordIncorrectError();
      case 9003:
        return UsernameExistError();
      case 1001:
        return UserInfoModifyingError();
      case 1002:
        return UserPasswordChangingError();
      case 2001:
        return RecordCreatingError();
      case 2002:
        return RecordModifyingError();
      case 3001:
        return PatientCreatingError();
      case 3002:
        return PatientSelfCreatingError();
      case 3003:
        return PatientModifyingError();
      case 4001:
        return CertificateCreatingError();
      case 4002:
        return CertificateModifyingError();
      case 4003:
        return CertificateHeaderModifyingError();
      default:
        return UnexpectedResponseError();
    }
  }

  /// Determine how the error should be represented by the [WebServiceResponseError] instance.
  static WebServiceResponseError _determineErrorFromStatus(int status) {
    switch (status) {
      case 400:
        return BadRequestError();
      case 401:
        return UnauthorizedError();
      default:
        return UnexpectedResponseError();
    }
  }

  /// Determine how the error instance should be thrown.
  static Error _determineError(dynamic e) {
    if (e is int) return _determineErrorFromStatus(e);
    if (e is Map<String, dynamic>) return _determineErrorFromBody(e);
    if (e is ClientError || e is WebServiceResponseError) return e;
    return UnknownError(e);
  }

  /// Evaluate the condition from the input value that it is expected to be a specific-type value
  /// and it is not an error-response [Map].
  ///
  /// Also, an optional callback from [next] parameter is used for evaluating the condition value.
  /// If there is no callback for [next] parameter, the evaluated value from the [next] parameter is always "true".
  static bool _isExpected<V>(
    dynamic e, {
    bool Function(V e)? next,
  }) {
    bool c = Utils.isExpected<V>(
      e,
      next: (x) =>
          !(x is Map<String, dynamic> &&
              x['errorName'] != null &&
              x['errorCode'] != null) &&
          (next != null ? next(x) : true),
    );

    return c;
  }

  /// Get the HTTP header.
  static String? _getHeader(Map<String, String> headers, String name) {
    for (MapEntry<String, String> e in headers.entries) {
      String matchCase = name.split('').map((e) {
        String upper = e.toUpperCase();
        String lower = e.toLowerCase();
        return upper == lower ? "$lower" : "($upper|$lower)";
      }).join('');
      if (e.key.contains(RegExp("^$matchCase"))) return e.value;
    }
    return null;
  }

  /// Even more  doing lazy HTTP request with [fetch] method.
  static Future<FetchResponse> _send({
    RequestBody? body,
    Map<String, String>? headers,
    RequestMethod method = RequestMethod.get,
    String pathname = '/',
  }) async {
    return await fetch(
      'https://$host$pathname',
      method: method,
      headers: headers,
      body: body,
      mode: RequestMode.cors,
    );
  }

  /// Doing HTTP POST request with JSON request body.
  static Future<FetchResponse> _postJson(
    String pathname,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) {
    return _send(
      method: RequestMethod.post,
      pathname: pathname,
      body: RequestBody.json(body),
      headers: headers,
    );
  }

  /// Doing HTTP POST request with the multipart form data body.
  static Future<FetchResponse> _postFormData(
    String pathName,
    List<FormDataField> body, {
    Map<String, String>? headers,
  }) {
    return _send(
      method: RequestMethod.post,
      pathname: pathName,
      body: RequestBody(
        type: RequestBodyType.formData,
        content: body,
      ),
      headers: headers,
    );
  }

  /// Doing HTTP GET request without body context.
  static Future<FetchResponse> _get(
    String pathname, {
    Map<String, String>? headers,
  }) {
    return _send(
      method: RequestMethod.get,
      pathname: pathname,
      headers: headers,
    );
  }

  /// Doing login authentication.
  ///
  /// It should return the [Future] of login authentication JSON Web Token.
  static Future<String> signup({
    int namePrefix = 0,
    int gender = 0,
    String firstname = '',
    String lastname = '',
    String username = '',
    String password = '',
  }) async {
    try {
      if (firstname.isEmpty ||
          lastname.isEmpty ||
          username.isEmpty ||
          password.isEmpty) throw FormValidationError();

      FetchResponse response = await _postJson(
        '/signup',
        {
          'firstname': firstname,
          'lastname': lastname,
          'gender': gender,
          'name_prefix': namePrefix,
          'username': username,
          'password': password,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => Utils.isExpected<String>(
          e['authorization'],
          next: (v) => v.isNotEmpty,
        ),
      )) throw converted;

      return converted['authorization'];
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Doing login authentication.
  ///
  /// It should return the [Future] of login authentication JSON Web Token.
  static Future<String> login({
    String username = '',
    String password = '',
  }) async {
    try {
      if (username.isEmpty || password.isEmpty) throw FormValidationError();

      FetchResponse response = await _postJson(
        '/login',
        {
          'username': username,
          'password': password,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();
      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => Utils.isExpected<String>(
          e['authorization'],
          next: (v) => v.isNotEmpty,
        ),
      )) throw converted ?? {};

      return converted!['authorization'];
    } catch (e) {
      print('$e');
      throw _determineError(e);
    }
  }

  /// Doing logging out.
  ///
  /// It should return the [Future] of an empty JSON object.
  static Future<void> logout() async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _get(
        '/logout',
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();
      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => converted.isEmpty,
      )) throw converted;

      return;
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Doing login authentication before using app.
  static Future<void> preLoginAuthentication() async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _postJson(
        '/login',
        {},
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => Utils.isExpected<bool>(
          e['authorization'],
          next: (v) => v,
        ),
      )) throw converted;

      return;
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get user information.
  static Future<UserInfoResult> getUserInfo() async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _get(
        '/user/view',
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String>(
              e['firstname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<String>(
              e['lastname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<int>(e['gender']) &&
            Utils.isExpected<int>(e['name_prefix']),
      )) throw converted;

      return UserInfoResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Edit user information.
  static Future<UserInfoResult> editUserInfo({
    String firstName = '',
    String lastName = '',
    int gender = 0,
    int namePrefix = 0,
  }) async {
    try {
      if (firstName.isEmpty || lastName.isEmpty) throw FormValidationError();

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/user/edit/info',
        {
          'firstname': firstName,
          'lastname': lastName,
          'gender': gender,
          'name_prefix': namePrefix,
        },
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String>(
              e['firstname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<String>(
              e['lastname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<int>(e['gender']) &&
            Utils.isExpected<int>(e['name_prefix']),
      )) throw converted;

      return UserInfoResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Edit user account.
  static Future<void> editUserAccount({
    String oldPassword = '',
    String newPassword = '',
  }) async {
    try {
      if (oldPassword.isEmpty || newPassword.isEmpty)
        throw FormValidationError();

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _postJson(
        '/user/edit/account',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => Utils.isExpected<bool>(
          e['success'],
          next: (x) => x,
        ),
      )) throw converted;
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get all available patient for user.
  static Future<List<PatientResult>> getAvailablePatient() async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _get(
        '/patient/view',
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<List>(converted)) throw converted;

      return (converted as List)
          .map<PatientResult>((e) => PatientResult(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Create a patient for a user.
  static Future<PatientResult> createPatientAsChild({
    String firstName = '',
    String lastName = '',
  }) async {
    try {
      if (firstName.isEmpty || lastName.isEmpty) throw FormValidationError();

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/patient/create',
        {
          'firstname': firstName,
          'lastname': lastName,
        },
        headers: {
          'Authorization': authorization,
        },
      );
      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String>(
              e['firstname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<String>(
              e['lastname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<int>(e['id']),
      )) throw converted;

      return PatientResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Edit user information.
  static Future<PatientResult> editPatient({
    required int id,
    required String firstName,
    required String lastName,
  }) async {
    try {
      if (firstName.isEmpty || lastName.isEmpty) throw FormValidationError();

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/patient/edit',
        {
          'patient_id': id,
          'firstname': firstName,
          'lastname': lastName,
        },
        headers: {
          'Authorization': authorization,
        },
      );
      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String>(
              e['firstname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<String>(
              e['lastname'],
              next: (x) => x.isNotEmpty,
            ) &&
            Utils.isExpected<int>(e['id']),
      )) throw converted;

      return PatientResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get all available patient for user.
  static Future<VaccineRecordResult> viewRecord({
    required int patientId,
  }) async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/record/view',
        {
          'patient_id': patientId,
        },
        headers: {
          'Authorization': authorization,
        },
      );

      // debugPrint("$response");

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String?>(e['bcg_first']) &&
            Utils.isExpected<String?>(e['hb_first']) &&
            Utils.isExpected<String?>(e['hb_second']) &&
            Utils.isExpected<String?>(e['opv_early_first']) &&
            Utils.isExpected<String?>(e['opv_early_second']) &&
            Utils.isExpected<String?>(e['opv_early_third']) &&
            Utils.isExpected<String?>(e['dtp_hb_first']) &&
            Utils.isExpected<String?>(e['dtp_hb_second']) &&
            Utils.isExpected<String?>(e['dtp_hb_third']) &&
            Utils.isExpected<String?>(e['ipv_first']) &&
            Utils.isExpected<String?>(e['mmr_first']) &&
            Utils.isExpected<String?>(e['mmr_second']) &&
            Utils.isExpected<String?>(e['je_first']) &&
            Utils.isExpected<String?>(e['je_second']) &&
            Utils.isExpected<String?>(e['opv_later_first']) &&
            Utils.isExpected<String?>(e['opv_later_second']) &&
            Utils.isExpected<String?>(e['dtp_first']) &&
            Utils.isExpected<String?>(e['dtp_second']) &&
            Utils.isExpected<String?>(e['hpv_first']) &&
            Utils.isExpected<String?>(e['dt_first']) &&
            Utils.isExpected<int>(e['id']),
      )) throw converted;

      return VaccineRecordResult(converted);
    } catch (e) {
      // debugPrint("$e");
      throw _determineError(e);
    }
  }

  /// Get all available patient for user.
  static Future<VaccineRecordResult> editRecord({
    required int vaccineRecordId,
    required Map<String, DateTime?> vaccineRecord,
  }) async {
    try {
      Map<String, dynamic> body = {
        'id': vaccineRecordId,
      };
      body.addAll(vaccineRecord.map((keyword, date) =>
          MapEntry<String, String?>(
              keyword, date == null ? null : date.toIso8601String())));

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/record/edit',
        body,
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) =>
            Utils.isExpected<String?>(e['bcg_first']) &&
            Utils.isExpected<String?>(e['hb_first']) &&
            Utils.isExpected<String?>(e['hb_second']) &&
            Utils.isExpected<String?>(e['opv_early_first']) &&
            Utils.isExpected<String?>(e['opv_early_second']) &&
            Utils.isExpected<String?>(e['opv_early_third']) &&
            Utils.isExpected<String?>(e['dtp_hb_first']) &&
            Utils.isExpected<String?>(e['dtp_hb_second']) &&
            Utils.isExpected<String?>(e['dtp_hb_third']) &&
            Utils.isExpected<String?>(e['ipv_first']) &&
            Utils.isExpected<String?>(e['mmr_first']) &&
            Utils.isExpected<String?>(e['mmr_second']) &&
            Utils.isExpected<String?>(e['je_first']) &&
            Utils.isExpected<String?>(e['je_second']) &&
            Utils.isExpected<String?>(e['opv_later_first']) &&
            Utils.isExpected<String?>(e['opv_later_second']) &&
            Utils.isExpected<String?>(e['dtp_first']) &&
            Utils.isExpected<String?>(e['dtp_second']) &&
            Utils.isExpected<String?>(e['hpv_first']) &&
            Utils.isExpected<String?>(e['dt_first']) &&
            Utils.isExpected<int>(e['id']),
      )) throw converted;

      return VaccineRecordResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get the patient's certificate of vaccination.
  static Future<BriefyVaccineCertificationResult> viewCertificate({
    required int patientId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'patient_id': patientId,
      };

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/certificate/view',
        body,
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var contentType = _getHeader(response.headers, 'Content-Type');
      if (contentType == null ||
          !contentType.contains(RegExp("^multipart\/form-data"))) {
        if (contentType?.contains(RegExp("^application\/json")) ?? true) {
          throw await response.json();
        }

        throw await response.text();
      }

      var converted = await response.formData();

      return BriefyVaccineCertificationResult(converted);
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get the whole patient's certificate of vaccination.
  static Future<CompletedVaccineCertificationResult> getCompleteCertificate({
    required int patientId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'patient_id': patientId,
      };

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/certificate/view/complete',
        body,
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var contentType = _getHeader(response.headers, 'Content-Type');
      if (contentType == null ||
          !contentType.contains(RegExp("^multipart\/form-data"))) {
        if (contentType?.contains(RegExp("^application\/json")) ?? true) {
          throw await response.json();
        }

        throw await response.text();
      }

      var converted = await response.formData();

      return CompletedVaccineCertificationResult(converted);
    } catch (e) {
      debugPrint('$e');
      throw _determineError(e);
    }
  }

  /// Edit the certificate.
  static Future<void> editCertificate({
    required int vaccinePatientId,
    String? fullName,
    int? sex,
    String? nationality,
    String? againstDescription,
    Uint8List? signature,
    DateTime? dateOfBirth,
    List<Certification>? certificationList,
  }) async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      List<FormDataField> fields = [];

      fields.add(NonFileField("vaccine_patient_id", "$vaccinePatientId"));

      if (fullName != null) {
        fields.add(NonFileField("fullname_in_cert", fullName));
      }
      if (sex != null) {
        fields.add(NonFileField("sex", "$sex"));
      }
      if (nationality != null) {
        fields.add(NonFileField("nationality", nationality));
      }
      if (againstDescription != null) {
        fields.add(NonFileField("against_description", againstDescription));
      }
      if (dateOfBirth != null) {
        fields
            .add(NonFileField("date_of_birth", dateOfBirth.toIso8601String()));
      }

      if (signature != null) {
        fields.add(
          FileField(
              "signature", signature, "signature_${DateTime.now().toUtc()}"),
        );
      }

      if (certificationList != null) {
        int i = 0;
        for (var c in certificationList) {
          MultipartBuilder multipart = MultipartBuilder();
          multipart.append("id", c.id.toString());
          if (c.vaccineName != null) {
            multipart.append(
              "vaccine_name",
              c.vaccineName!,
            );
          }
          if (c.vaccineBatchNumber != null) {
            multipart.append(
              "vaccine_batch_number",
              c.vaccineBatchNumber!,
            );
          }
          if (c.vaccineManufacturer != null) {
            multipart.append(
              "vaccine_manufacturer",
              c.vaccineManufacturer!,
            );
          }
          if (c.certifyFrom != null) {
            multipart.append("certify_from", c.certifyFrom!.toIso8601String());
          }
          if (c.certifyTo != null) {
            multipart.append("certify_to", c.certifyTo!.toIso8601String());
          }
          if (c.clinicianProfStatus != null) {
            multipart.append("clinician_prof_status", c.clinicianProfStatus!);
          }
          if (c.clinicianSignature != null) {
            multipart.appendFile(
              "clinician_signature",
              c.clinicianSignature!,
              "clinician_signature",
            );
          }

          if (c.administringCentreStamp != null) {
            multipart.appendFile(
              "administring_centre_stamp",
              c.administringCentreStamp!,
              "administring_centre_stamp",
            );
          }

          fields.add(
              FileField("certification_list", multipart.toBytes(), "${++i}"));
        }
      }

      FetchResponse response = await _postFormData(
        '/certificate/edit',
        fields,
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => e['success'] == true,
      )) {
        throw converted;
      }
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get the vaccination records that they are available for creating certification of vaccination.
  static Future<List<String>> getAvailableVaccination({
    required int vaccinePatientId,
  }) async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _postJson(
        '/certificate/available',
        {
          'patient_id': vaccinePatientId,
        },
        headers: {
          'Authorization': authorization,
        },
      );

      var converted = await response.json();

      if (!_isExpected<List>(
        converted,
        next: (e) {
          for (var x in e) {
            if (x is! String) return false;
          }
          return true;
        },
      )) throw converted;

      return (converted as List).cast<String>();
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Create a certification.
  static Future<void> createCertification({
    required int vaccinePatientId,
    required List<String> vaccineAgainstList,
  }) async {
    try {
      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();

      FetchResponse response = await _postJson(
        '/certificate/create',
        {
          'patient_id': vaccinePatientId,
          'vaccine_against_list': vaccineAgainstList,
        },
        headers: {
          'Authorization': authorization,
        },
      );

      var converted = await response.json();

      if (!_isExpected<Map<String, dynamic>>(
        converted,
        next: (e) => e['success'] == true,
      )) throw CertificateCreatingError();
    } catch (e) {
      throw _determineError(e);
    }
  }

  /// Get an item of certification.
  static Future<CertificationResult> viewEachCertification({
    required int certificateId,
    required int vaccinePatientId,
  }) async {
    try {
      Map<String, dynamic> body = {
        'certificate_id': certificateId,
        'patient_id': vaccinePatientId,
      };

      String? authorization = await AuthorizationKey.get();
      if (authorization == null) throw NoAuthenticationKeyError();
      FetchResponse response = await _postJson(
        '/certificate/view/each',
        body,
        headers: {
          'Authorization': authorization,
        },
      );

      if (response.status != 200) throw response.status;

      var contentType = _getHeader(response.headers, 'Content-Type');
      if (contentType == null ||
          !contentType.contains(RegExp("^multipart\/form-data"))) {
        if (contentType?.contains(RegExp("^application\/json")) ?? true) {
          throw await response.json();
        }

        throw await response.text();
      }

      var converted = await response.formData();

      late int id;
      String? vaccineAgainst;
      String? vaccineName;
      String? vaccineManufacturer;
      String? vaccineBatchNumber;
      DateTime? certifyFrom;
      DateTime? certifyTo;
      Uint8List? clinicianSignature;
      String? clinicianProfStatus;
      Uint8List? administringCentreStamp;

      for (var e in converted) {
        var value = e.tryJsonDecodeValue();
        switch (e.name) {
          case 'id':
            id = value;
            break;
          case 'vaccine_against':
            vaccineAgainst = value;
            break;
          case 'vaccine_name':
            vaccineName = value;
            break;
          case 'vaccine_manufacturer':
            vaccineManufacturer = value;
            break;
          case 'vaccine_batch_number':
            vaccineBatchNumber = value;
            break;
          case 'certify_from':
            certifyFrom = DateTime.tryParse(value ?? '');
            break;
          case 'certify_to':
            certifyTo = DateTime.tryParse(value ?? '');
            break;
          case 'clinician_prof_status':
            clinicianProfStatus = value;
            break;
          case 'clinician_signature':
            if (value is String) {
              clinicianSignature = Uint8List.fromList(utf8.encode(value));
              break;
            }
            if (e is FileField) {
              clinicianSignature = value as Uint8List;
              break;
            }

            clinicianSignature = null;

            break;
          case 'administring_centre_stamp':
            if (value is String) {
              administringCentreStamp = Uint8List.fromList(utf8.encode(value));
              break;
            }
            if (e is FileField) {
              administringCentreStamp = value as Uint8List;
              break;
            }

            administringCentreStamp = null;

            break;
        }
      }

      return CertificationResult(_Cert(
        id: id,
        vaccineName: vaccineName,
        vaccineBatchNumber: vaccineBatchNumber,
        vaccineManufacturer: vaccineManufacturer,
        vaccineAgainst: vaccineAgainst,
        certifyFrom: certifyFrom,
        certifyTo: certifyTo,
        clinicianProfStatus: clinicianProfStatus,
        clinicianSignature: clinicianSignature,
        administringCentreStamp: administringCentreStamp,
      ));
    } catch (e) {
      throw _determineError(e);
    }
  }
}
