import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
// import 'package:unicorndial/unicorndial.dart';

import '../../src/helper/change_notifier.dart';
import '../../src/layout/generic.dart';
import '../../src/widget/combined_image_picker.dart';
import '../../src/widget/custom_button.dart';
import '../../src/widget/datetime_textfield.dart';
import '../../src/widget/persistent_widget.dart';
import '../../src/widget/reactive_text_field.dart';

import '../widget/patient_selector.dart';
import '../../global.dart' as global;

class _CertNetworkStateNotifier extends ChangeNotifier {
  static bool _initRequested = false;
  static bool _requesting = false;
  static bool _requested = false;
  bool get initRequested => _initRequested;
  bool get requesting => _requesting;
  bool get requested => _requested;
  void setToInitialState() {
    _initRequested = true;
    _requesting = true;
    _requested = false;
    notifyListeners();
  }

  void update({
    bool initRequested,
    bool requesting,
    bool requested,
  }) {
    bool changed = false;
    if (initRequested != _initRequested) {
      _initRequested = initRequested == true;
      changed = true;
    }
    if (requesting != _requesting) {
      _requesting = requesting == true;
      changed = true;
    }
    if (requested != _requested) {
      _requested = requested == true;
      changed = true;
    }

    if (changed) notifyListeners();
  }
}

class _CertDataNotifier extends ChangeNotifier {
  static final Map<String, dynamic> _selectedPatient = {};
  static final List<Map<String, dynamic>> _certList = [];
  Map<String, dynamic> get selectedPatient => _selectedPatient;
  List<Map<String, dynamic>> get certList => _certList;
  void update({
    Map<String, dynamic> selectedPatient,
    List<Map<String, dynamic>> certList,
  }) {
    bool changed = false;

    if (selectedPatient != null) {
      var entries = selectedPatient.entries.iterator;
      while (entries.moveNext()) {
        var entry = entries.current;

        if (_selectedPatient[entry.key] != entry.value) {
          _selectedPatient[entry.key] = entry.value;
          changed = true;
        }
      }
    }

    if (certList != null) {
      _certList.clear();
      _certList.addAll(certList);

      changed = true;
    }

    if (changed) notifyListeners();
  }
}

class Certificate extends StatelessWidget {
  static final Map<String, String> message = const {
    'bcg_first': 'ฉีดวัคซีนป้องกันวัณโรค (BCG)',
    'hb_first': 'ฉีดวัคซีนป้องกันโรคตับอักเสบบี (HB)',
    'hb_second': 'ฉีดวัคซีนป้องกันโรคตับอักเสบบี (HB)',
    'opv_early_first': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
    'opv_early_second': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
    'opv_early_third': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
    'dtp_hb_first':
        'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
    'dtp_hb_second':
        'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
    'dtp_hb_third':
        'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
    'ipv_first': 'ฉีดวัคซีนป้องกันโรคโปลิโอ (IPV)',
    'mmr_first': 'ฉีดวัคซีนรวมป้องกันโรคหัด-คางทูม-หัดเยอรมัน (MMR)',
    'mmr_second': 'ฉีดวัคซีนรวมป้องกันโรคหัด-คางทูม-หัดเยอรมัน (MMR)',
    'je_first': 'ฉีดวัคซีนป้องกันโรคไข้สมองอักเสบเจอี (JE)',
    'je_seconds': 'ฉีดวัคซีนป้องกันโรคไข้สมองอักเสบเจอี (JE)',
    'opv_later_first': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
    'opv_later_second': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
    'dtp_first': 'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน (DTP)',
    'dtp_second': 'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน (DTP)',
    'hpv_first': 'ฉีดวัคซีนป้องกันเอชพีวี (HPV)',
    'dt_first': 'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก (dT)',
  };

  final Map<String, String> _vaccine = const {
    'bcg': 'วัคซีนป้องกันวัณโรค (BCG)',
    'hb': 'วัคซีนป้องกันไวรัสตับอักเสบปี (HB)',
    'opv_early': 'วัคซีนป้องกันโรคโปลิโอ (OPV)',
    'dtp_hb': 'วัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
    'ipv': 'วัคซีนป้องกันโรคโปลิโอ (IPV)',
    'mmr': 'วัคซีนรวมป้องกันโรคหัด-คางทูม-หัดเยอรมัน (MMR)',
    'je': 'วัคซีนป้องกันโรคไข้สมองอักเสบเจอี (JE)',
    'opv_later': 'วัคซีนป้องกันโรคโปลิโอ (OPV)',
    'dtp': 'วัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน (DTP)',
    'hpv': 'ฉีดวัคซีนป้องกันเอชพีวี (HPV)',
    'dt': 'วัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก (dT)',
  };

  final Map<String, String> _age = const {
    'bcg_first': 'แรกเกิด',
    'hb_first': 'แรกเกิด',
    'hb_second': '1 เดือน',
    'opv_early_first': '2 เดือน',
    'opv_early_second': '4 เดือน',
    'opv_early_third': '6 เดือน',
    'dtp_hb_first': '2 เดือน',
    'dtp_hb_second': '4 เดือน',
    'dtp_hb_third': '6 เดือน',
    'ipv_first': '4 เดือน',
    'mmr_first': '9 เดือน',
    'mmr_second': '2 ปี 6 เดือน',
    'je_first': '1 ปี',
    'je_seconds': '2 ปี 6 เดือน',
    'opv_later_first': '1 ปี 6 เดือน',
    'opv_later_second': '4 ปี',
    'dtp_first': '1 ปี 6 เดือน',
    'dtp_second': '4 ปี',
    'hpv_first': '11 ปี',
    'dt_first': '12 ปี',
  };

  final _CertNetworkStateNotifier _network = _CertNetworkStateNotifier();
  final _CertDataNotifier _notifier = _CertDataNotifier();
  final IntNotifier _certSelectedPanelIndex = IntNotifier(value: -1);
  bool get isCertListEmpty =>
      _notifier.certList == null || _notifier.certList.isEmpty;

  Certificate({
    Key key,
  }) : super(key: key) {
    _network.setToInitialState();
  }

  Future<String> _showAvailableVaccination({
    BuildContext context,
  }) async {
    List<String> availableVaccinationList = [];
    bool requested = false;
    bool confirmed = false;
    PlainStringNotifier against = PlainStringNotifier(value: null);

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Container(
              height: MediaQuery.of(context).size.height - 200,
              child: StatefulBuilder(
                builder: (context, setState) {
                  if (!requested) {
                    global.VaccineDatabaseSource.getAvailableVaccination(
                            _notifier.selectedPatient['id'])
                        .then((value) {
                      availableVaccinationList.addAll(value);
                    }).whenComplete(() {
                      setState(() {
                        requested = true;
                      });
                    });
                  }

                  return Container(
                    child: Builder(
                      builder: (context) {
                        List<Widget> children = [];
                        if (!requested) {
                          children.add(global.LoadingIcon.large());
                        }

                        if (requested && availableVaccinationList.isEmpty) {
                          children.add(
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'ไม่พบราบการการรับวัคซีนที่สามารถออกใบรับรองได้',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }

                        if (requested && availableVaccinationList.isNotEmpty) {
                          children.add(
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'เลือกรายการที่จะรับรอง',
                                      textScaleFactor: 1.75,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(
                                        bottom: 10,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Container(
                                        child: SingleChildScrollView(
                                          child: ChangeNotifierProvider.value(
                                            value: against,
                                            builder: (context, child) {
                                              var children = <Widget>[];

                                              _vaccine.forEach((key, value) {
                                                var subChildren = <Widget>[];

                                                _age.forEach((k, v) {
                                                  if (!k.contains(RegExp(
                                                          '^${key}_(first|second|third)')) ||
                                                      availableVaccinationList
                                                              .indexOf(k) ==
                                                          -1) return;
                                                  subChildren.add(Consumer<
                                                      PlainStringNotifier>(
                                                    builder:
                                                        (context, _, child) =>
                                                            RadioListTile(
                                                      value: k,
                                                      groupValue: _?.value,
                                                      onChanged: (value) {
                                                        _.value = value;
                                                      },
                                                      title: Text('$v'),
                                                    ),
                                                  ));
                                                });

                                                if (subChildren.length > 0)
                                                  children.add(ExpansionTile(
                                                    title: Text('$value'),
                                                    children: subChildren,
                                                  ));
                                              });

                                              return Column(
                                                children: children,
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      child: ChangeNotifierProvider.value(
                                        value: against,
                                        builder: (context, child) =>
                                            Consumer<PlainStringNotifier>(
                                          builder: (context, _, child) {
                                            String age = _.value != null
                                                ? _age[_.value]
                                                : '';
                                            // debugPrint('${_.value} ');
                                            String vaccine = '';
                                            if (_.value != null) {
                                              _vaccine.forEach((key, value) {
                                                if (_.value.contains(RegExp(
                                                    '^${key}_(first|second|third)')))
                                                  vaccine = value;
                                              });
                                            }
                                            return Text.rich(
                                              TextSpan(children: [
                                                TextSpan(
                                                  text: 'รายการที่เลือก: ',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text:
                                                      '$vaccine${age != null && age.isNotEmpty ? '; ' : ''}',
                                                ),
                                                TextSpan(
                                                  text:
                                                      '${age != null && age.isNotEmpty ? 'อายุ ' : ''}$age',
                                                  style: TextStyle(
                                                    decoration: TextDecoration
                                                        .underline,
                                                  ),
                                                ),
                                              ]),
                                              textScaleFactor: 1.5,
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );

                          children.add(
                            ChangeNotifierProvider.value(
                              value: against,
                              builder: (context, child) =>
                                  Consumer<PlainStringNotifier>(
                                builder: (context, _, child) => CustomButton(
                                  child: Text('ยืนยัน'),
                                  onPressed: _.value != null
                                      ? () {
                                          confirmed = true;
                                          Navigator.of(context).pop();
                                        }
                                      : null,
                                ),
                              ),
                            ),
                          );
                        }

                        return Column(
                          mainAxisAlignment: requested
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          crossAxisAlignment: requested
                              ? CrossAxisAlignment.stretch
                              : CrossAxisAlignment.center,
                          children: children,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );

    return confirmed ? against.value : null;
  }

  void _showCertificatePanel({
    @required int patientId,
    @required int certificateId,
    @required BuildContext context,
  }) async {
    Map<String, dynamic> cert = {};
    Map<String, dynamic> keepOriginCert = {};
    BooleanNotifier unchanged = BooleanNotifier(
      value: false,
    );
    bool loaded = false;
    bool requesting = false;
    bool checkUnchanged() {
      var iterator = keepOriginCert.entries.iterator;
      while (iterator.moveNext()) {
        var entry = iterator.current;
        if (entry.value != cert[entry.key]) return true;
      }

      return false;
    }

    int currentPage = 0;

    Map<String, Widget> input = {
      'vaccine_briefing': ReactiveTextField(
        initialValue: cert['vaccine_briefing'],
        onChange: (value) {
          cert['vaccine_briefing'] = value.isNotEmpty ? value : null;
          unchanged.value = checkUnchanged();
        },
      ),
      'vaccine_manufacturer': ReactiveTextField(
        initialValue: cert['vaccine_manufacturer'],
        onChange: (value) {
          cert['vaccine_manufacturer'] = value.isNotEmpty ? value : null;
          unchanged.value = checkUnchanged();
        },
      ),
      'vaccine_batch_number': ReactiveTextField(
        initialValue: cert['vaccine_batch_number'],
        onChange: (value) {
          cert['vaccine_batch_number'] = value.isNotEmpty ? value : null;
          unchanged.value = checkUnchanged();
        },
      ),
      'certify_from': DateTimeTextField(
        onChange: (value) {
          cert['certify_from'] = value.toIso8601String() + 'Z';
          unchanged.value = checkUnchanged();
        },
      ),
      'certify_to': DateTimeTextField(
        lastDate: DateTime(2200),
        onChange: (value) {
          cert['certify_to'] = value.toIso8601String() + 'Z';
          unchanged.value = checkUnchanged();
        },
      ),
      'clinician_signature': CombinedImagePicker(
        base64ToFile: cert['clinician_signature'],
        onImageChange: (imageFile) {
          String value = base64.encode(imageFile.readAsBytesSync().toList());
          cert['clinician_signature'] = value;
          unchanged.value = checkUnchanged();
        },
      ),
      'clinician_prof_status': ReactiveTextField(
        initialValue: cert['clinician_prof_status'],
        onChange: (value) {
          cert['clinician_prof_status'] = value.isNotEmpty ? value : null;
          unchanged.value = checkUnchanged();
        },
      ),
      'administring_centre_stamp': CombinedImagePicker(
        base64ToFile: cert['administring_centre_stamp'],
        isDrawingPadClosed: true,
        onImageChange: (imageFile) {
          String value = base64.encode(imageFile.readAsBytesSync().toList());

          cert['administring_centre_stamp'] = value;
          unchanged.value = checkUnchanged();
        },
      ),
    };

    Map<String, dynamic> getDifferentCertificate() {
      Map<String, dynamic> result = {};
      var iterator = cert.entries.iterator;
      while (iterator.moveNext()) {
        var entry = iterator.current;
        if (entry.value != keepOriginCert[entry.key] ||
            entry.key == 'id' ||
            entry.key == 'vaccine_patient_id') result[entry.key] = entry.value;
      }
      return result;
    }

    Widget bottomSheet = StatefulBuilder(
      builder: (context, setState) {
        if (!loaded) {
          global.VaccineDatabaseSource.viewCertificate(certificateId, patientId)
              .then((map) {
            map.forEach((key, value) {
              if (input.containsKey(key)) {
                if (input[key] is ReactiveTextField)
                  (input[key] as ReactiveTextField).value = value ?? '';
                if (input[key] is DateTimeTextField)
                  (input[key] as DateTimeTextField).value =
                      DateTime.tryParse(value ?? '');
                if (input[key] is CombinedImagePicker) {
                  (input[key] as CombinedImagePicker).setImageByBase64(value);
                }
              }
            });
            setState(() {
              cert.addAll(map);
              keepOriginCert.addAll(map);
              loaded = true;
            });
          });
        }

        if (!loaded || requesting) {
          return SingleChildScrollView(
            child: Container(
              height:
                  MediaQuery.of(context).size.height - global.StatusBar.height,
              child: Center(
                child: global.LoadingIcon.large(),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          child: Container(
            height:
                MediaQuery.of(context).size.height - global.StatusBar.height,
            child: DefaultTabController(
              length: 4,
              initialIndex: currentPage,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TabBar(
                    labelColor: Theme.of(context).primaryColor,
                    isScrollable: true,
                    onTap: (index) {
                      currentPage = index;
                    },
                    tabs: [
                      Tab(
                        text: 'ข้อมูลวัคซีน',
                      ),
                      Tab(
                        text: 'ระยะเวลารับรอง',
                      ),
                      Tab(
                        text: 'แพทย์ผู้ดูแล',
                      ),
                      Tab(
                        text: 'หน่วยงานรับรอง',
                      ),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        PersistentWidget(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: GenericLayout([
                              Text(
                                'คำอธิบายย่อวัคซีน',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              input['vaccine_briefing'],
                              Text(
                                'เลขชุดวัคซีน',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              input['vaccine_batch_number'],
                              Text(
                                'ผู้ผลิตวัคซีน',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              input['vaccine_manufacturer'],
                            ]),
                          ),
                        ),
                        PersistentWidget(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: GenericLayout([
                              Text(
                                'รับรองวัคซีนตั้งแต่วันที่',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              input['certify_from'],
                              Text(
                                'ถึงวันที่',
                                textScaleFactor: 1.5,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              input['certify_to'],
                            ]),
                          ),
                        ),
                        PersistentWidget(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: SingleChildScrollView(
                              child: GenericLayout([
                                Text(
                                  'ลายมือชื่อแพทย์ผู้ดูแล',
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                input['clinician_signature'],
                                Text(
                                  'ตำแหน่งทางวิชาชีพ',
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                input['clinician_prof_status'],
                              ]),
                            ),
                          ),
                        ),
                        PersistentWidget(
                          child: Container(
                            padding: EdgeInsets.all(15),
                            child: SingleChildScrollView(
                              child: GenericLayout([
                                Text(
                                  'ตราประทับหน่วยงานรับรอง',
                                  textScaleFactor: 1.5,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                input['administring_centre_stamp'],
                              ]),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ChangeNotifierProvider.value(
                    value: unchanged,
                    builder: (context, child) => Consumer<BooleanNotifier>(
                      builder: (context, instance, child) => CustomButton(
                        child: Text('บันทึก'),
                        onPressed: instance.value
                            ? () async {
                                bool confirmed = false;

                                await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('ยืนยันการบันทึกหรือไม่'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          confirmed = true;
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('ตกลง'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('ยกเลิก'),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmed) {
                                  setState(() {
                                    requesting = true;
                                  });

                                  try {
                                    var value =
                                        await global.VaccineDatabaseSource
                                            .editCertificate(
                                                getDifferentCertificate());
                                    if (value
                                        .containsKey('clinician_signature')) {
                                      value['clinician_signature'] =
                                          value == null
                                              ? null
                                              : '$value'.replaceAll(
                                                  RegExp('(\r|\n|\r\n)'), '');
                                    }

                                    if (value.containsKey(
                                        'administring_centre_stamp')) {
                                      value['administring_centre_stamp'] =
                                          value == null
                                              ? null
                                              : '$value'.replaceAll(
                                                  RegExp('(\r|\n|\r\n)'), '');
                                    }

                                    keepOriginCert.addAll(value);
                                    cert.addAll(value);
                                    unchanged.value = checkUnchanged();
                                  } catch (e) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('ไม่สามารถบันทึกได้'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('ตกลง'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } finally {
                                    setState(() {
                                      requesting = false;
                                    });
                                  }
                                }
                              }
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return bottomSheet;
      },
    );
  }

  void _viewAsPDF(
    Map<String, dynamic> header,
    List<Map<String, dynamic>> list,
  ) async {
    final pdf = pw.Document();

    double inch = PdfPageFormat.inch;
    double cm = PdfPageFormat.cm;
    double pageWidth = 3.35 * inch;
    double pageHeight = 4.92 * inch;
    double pageMargin = .2 * cm;
    double tableCellWidth = pageWidth / 3;
    double tableCellHeight = (pageHeight - cm * 1) / 9;
    PdfPageFormat format = PdfPageFormat(
      pageWidth,
      pageHeight,
      marginAll: pageMargin,
    );

    bool firstPairPage = true;
    int usedRows = 0;
    pw.TextStyle headingStyle = pw.TextStyle(
      fontWeight: pw.FontWeight.bold,
      fontSize: 14,
    );
    pw.TextStyle subHeaderStyle = pw.TextStyle(
      fontSize: 10,
    );
    pw.TextStyle tableHeaderStyle = pw.TextStyle(
      fontSize: 6,
      fontWeight: pw.FontWeight.bold,
    );
    List<pw.Page> pages = [];
    pw.Container Function(pw.Widget child) textFieldWithDottedLine =
        (pw.Widget child) {
      return pw.Container(
        decoration: pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              color: PdfColor(0, 0, 0),
              style: pw.BorderStyle.dotted,
            ),
          ),
        ),
        child: child,
      );
    };
    pw.TableRow Function() leftPageTableHeader = () {
      return pw.TableRow(
        children: [
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Vaccine or prophylaxis',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Date',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Signature and professional status of supervising clinician',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
        ],
      );
    };
    pw.TableRow Function() rightPageTableHeader = () {
      return pw.TableRow(
        children: [
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Manufacturer and batch no. of vaccine or prophylaxis',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Certificate valid\nfrom:\nuntil:',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
          pw.Container(
            width: tableCellWidth,
            height: tableCellHeight,
            child: pw.Center(
              child: pw.Text(
                'Official stamp of the administering centre',
                textAlign: pw.TextAlign.center,
                style: tableHeaderStyle,
              ),
            ),
          ),
        ],
      );
    };
    pw.Widget Function(bool onlyBlank) generateCertHeader = (bool onlyBlank) {
      return pw.Column(
        children: [
          pw.Row(
            children: [
              pw.Text('This is to certify that [name]'),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true
                      ? pw.Container(height: 10)
                      : pw.Text(header['fullname_in_cert'] ?? ''),
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('date of birth'),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: 2,
                ),
              ),
              pw.Expanded(
                child: pw.Builder(
                  builder: (context) {
                    DateTime date =
                        DateTime.tryParse(header['date_of_birth'] ?? '');
                    return textFieldWithDottedLine(
                      onlyBlank == true
                          ? pw.Container(height: 10)
                          : pw.Center(
                              child: pw.Text(date != null
                                  ? '${date.day}/${date.month}/${date.year}'
                                  : ''),
                            ),
                    );
                  },
                ),
              ),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: 2,
                ),
              ),
              pw.Text('sex'),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                  left: 2,
                ),
              ),
              pw.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true
                      ? pw.Container(height: 10)
                      : pw.Center(
                          child:
                              pw.Text(header['sex'] == 1 ? 'Female' : 'Male'),
                        ),
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('national identification document, if applicable'),
              pw.Expanded(
                child: textFieldWithDottedLine(pw.Container(height: 10)),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Text('whose signature follows'),
              pw.Expanded(
                child: pw.Builder(
                  builder: (context) {
                    if (header['signature'] == null) return pw.Container();

                    Uint8List signature = base64.decode('${header['signature']}'
                        .replaceAll(RegExp('\r|\n|\r\n'), ''));

                    return textFieldWithDottedLine(
                      pw.Container(
                        constraints: pw.BoxConstraints(
                          maxHeight: 10,
                        ),
                        child: onlyBlank == true
                            ? null
                            : pw.Stack(
                                overflow: pw.Overflow.visible,
                                alignment: pw.Alignment.center,
                                children: [
                                  pw.Positioned(
                                    child: pw.Container(
                                      constraints: pw.BoxConstraints(
                                        maxHeight: 32,
                                      ),
                                      child: pw.Image(
                                        pw.MemoryImage(
                                          signature,
                                        ),
                                      ),
                                      // child:
                                      // pw.Image.provider(
                                      //   pw.RawImage(
                                      //     width: 100,
                                      //     height: 100,
                                      //     bytes: signature,
                                      //   ),

                                      //   // PdfImage.file(
                                      //   //   pdf.document,
                                      //   //   bytes: signature,
                                      //   // ),
                                      // ),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.RichText(
                  text: pw.TextSpan(
                    text:
                        'has on the date indicated been vaccinated or received prophylaxis against: (name of disease or condition)',
                  ),
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true
                      ? pw.Container(height: 10)
                      : pw.RichText(
                          text: pw.TextSpan(
                            text: header['against_description'] ?? '',
                          ),
                        ),
                ),
              ),
            ],
          ),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Text(
                    'in accordance with the International Health Regulations.'),
              ),
            ],
          ),
        ],
      );
    };

    while (usedRows < list.length) {
      int currentUsedRows = firstPairPage ? 3 : 8;
      bool firstPair = firstPairPage;
      List<pw.TableRow> tableLeft = [
        leftPageTableHeader(),
      ];
      List<pw.TableRow> tableRight = [
        rightPageTableHeader(),
      ];

      for (int i = 0; i < currentUsedRows; i++) {
        Map<String, dynamic> certRow =
            usedRows + i >= list.length ? null : list[usedRows + i];
        tableLeft.add(pw.TableRow(
          children: [
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Center(
                      child: pw.Text('${certRow['vaccine_briefing'] ?? ''}'),
                    ),
            ),
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Center(
                      child: pw.Text(''),
                    ),
            ),
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Center(
                      child: pw.Builder(
                        builder: (context) {
                          List<pw.Widget> stackChildren = [];
                          if (certRow['clinician_signature'] != null) {
                            String encoded = '${certRow['clinician_signature']}'
                                .replaceAll(RegExp('(\r|\n|\r\n)'), '');

                            Uint8List buffer = base64.decode(encoded);

                            pw.ImageProvider pdfImage = pw.MemoryImage(
                              buffer,
                            );
                            // PdfImage.file(
                            //   pdf.document,
                            //   bytes: buffer,
                            // );

                            stackChildren.add(
                              pw.Image(pdfImage),
                            );
                          }
                          stackChildren.add(pw.Text(
                              '${certRow['clinician_prof_status'] ?? ''}'));
                          return pw.Stack(
                            children: stackChildren,
                          );
                        },
                      ),
                    ),
            ),
          ],
        ));
        tableRight.add(pw.TableRow(
          children: [
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Text('${certRow['vaccine_manufacturer'] ?? ''}'),
                        pw.Text('${certRow['vaccine_batch_number'] ?? ''}'),
                      ],
                    ),
            ),
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Builder(
                          builder: (context) {
                            DateTime date = DateTime.tryParse(
                                certRow['certify_from'] ?? '');
                            return pw.Text(date != null
                                ? '${date.day}/${date.month}/${date.year}'
                                : '');
                          },
                        ),
                        pw.Builder(
                          builder: (context) {
                            DateTime date =
                                DateTime.tryParse(certRow['certify_to'] ?? '');
                            return pw.Text(date != null
                                ? '${date.day}/${date.month}/${date.year}'
                                : '');
                          },
                        ),
                      ],
                    ),
            ),
            pw.Container(
              width: tableCellWidth,
              height: tableCellHeight,
              child: certRow == null
                  ? null
                  : pw.Center(
                      child: pw.Builder(
                        builder: (context) {
                          if (certRow['administring_centre_stamp'] != null) {
                            String encoded =
                                '${certRow['administring_centre_stamp']}'
                                    .replaceAll(RegExp('(\r|\n|\r\n)'), '');

                            Uint8List buffer = base64.decode(encoded);

                            pw.ImageProvider image = pw.MemoryImage(buffer);
                            // PdfImage.file(
                            //   pdf.document,
                            //   bytes: buffer,
                            // );

                            return pw.Image(image);
                          }

                          return pw.Text('');
                        },
                      ),
                    ),
            ),
          ],
        ));
      }

      pages.add(pw.Page(
        pageFormat: format,
        build: (context) {
          if (!firstPair) {
            return pw.Container(
              alignment: pw.Alignment.bottomLeft,
              child: pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor(0, 0, 0),
                  width: 1,
                ),
                children: tableLeft,
              ),
            );
          }
          return pw.Container(
            child: pw.Column(
              children: [
                pw.RichText(
                  text: pw.TextSpan(
                    text:
                        'INTERNATIONAL CERTIFICATE OF VACCINATION OR PROPHYLAXIS',
                    style: headingStyle,
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    child: pw.DefaultTextStyle(
                      style: subHeaderStyle,
                      child: generateCertHeader(false),
                    ),
                  ),
                ),
                pw.Table(
                  border: pw.TableBorder.all(
                    color: PdfColor(0, 0, 0),
                    width: 1,
                  ),
                  children: tableLeft,
                ),
              ],
            ),
          );
        },
      ));
      pages.add(pw.Page(
        pageFormat: format,
        build: (context) {
          if (!firstPair) {
            return pw.Container(
              alignment: pw.Alignment.bottomLeft,
              child: pw.Table(
                border: pw.TableBorder.all(
                  color: PdfColor(0, 0, 0),
                  width: 1,
                ),
                children: tableRight,
              ),
            );
          }

          return pw.Container(
            child: pw.Column(
              children: [
                pw.Opacity(
                  opacity: .25,
                  child: pw.RichText(
                    text: pw.TextSpan(
                      text:
                          'INTERNATIONAL CERTIFICATE OF VACCINATION OR PROPHYLAXIS',
                      style: headingStyle,
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 2,
                  child: pw.Opacity(
                    opacity: .25,
                    child: pw.Container(
                      child: pw.DefaultTextStyle(
                        style: subHeaderStyle,
                        child: generateCertHeader(true),
                      ),
                    ),
                  ),
                ),
                pw.Expanded(
                  flex: 0,
                  child: pw.Table(
                    border: pw.TableBorder.all(
                      color: PdfColor(0, 0, 0),
                      width: 1,
                    ),
                    children: tableRight,
                  ),
                )
              ],
            ),
          );
        },
      ));
      usedRows += currentUsedRows;
      firstPairPage = false;
    }
    pages.forEach((p) {
      pdf.addPage(p);
    });

    await Printing.layoutPdf(
      name: 'vaccine_certificate_' + DateTime.now().toString(),
      onLayout: (format) => pdf.save(),
    );
  }

  void _showCertificateHeaderPanel({
    @required int patientId,
    @required BuildContext context,
  }) async {
    bool initRequested = false;
    bool requesting = true;
    Map<String, dynamic> originalCertHeader = {};
    Map<String, dynamic> certHeader = {};
    BooleanNotifier changed = BooleanNotifier(value: false);
    bool isChanged() {
      var entries = certHeader.entries.iterator;
      while (entries.moveNext()) {
        var entry = entries.current;
        if (entry.value != originalCertHeader[entry.key]) return true;
      }
      return false;
    }

    Map<String, dynamic> onlyDiffCertHeader() {
      Map<String, dynamic> result = {};
      certHeader.forEach((key, value) {
        if (value != originalCertHeader[key]) result[key] = value;
      });
      return result;
    }

    Map<String, Widget> input = {
      'fullname_in_cert': ReactiveTextField(
        inputFormatters: [
          FilteringTextInputFormatter(
            RegExp('([A-Za-z]| )'),
            allow: true,
          ),
        ],
        onChange: (value) {
          certHeader['fullname_in_cert'] = value.isNotEmpty ? value : null;
          changed.value = isChanged();
        },
      ),
      'sex': Container(
        child: StatefulBuilder(
          builder: (context, setState) {
            List<Radio> radios = [];
            for (var i = 0; i < 2; i++) {
              Radio radio = Radio(
                groupValue: certHeader['sex'] ?? 0,
                value: i,
                onChanged: (value) {
                  certHeader['sex'] = value;
                  changed.value = isChanged();
                  setState(() {});
                },
              );
              radios.add(radio);
            }

            int i = 0;
            return Row(
              children: radios.map((radio) {
                int value = i++;
                return Row(
                  children: [
                    radio,
                    TextButton(
                      child: Text(value == 0 ? 'ชาย' : 'หญิง'),
                      onPressed: () {
                        certHeader['sex'] = value;
                        changed.value = isChanged();
                        setState(() {});
                      },
                    )
                  ],
                );
              }).toList(),
            );
          },
        ),
      ),
      'date_of_birth': DateTimeTextField(
        onChange: (value) {
          certHeader['date_of_birth'] = value.toIso8601String() + 'Z';
          changed.value = isChanged();
        },
      ),
      'nationality': ReactiveTextField(
        inputFormatters: [
          FilteringTextInputFormatter(
            RegExp('[A-Za-z]'),
            allow: true,
          ),
        ],
        onChange: (value) {
          certHeader['nationality'] = value.isNotEmpty ? value : null;
          changed.value = isChanged();
        },
      ),
      'signature': CombinedImagePicker(
        onImageChange: (imageFile) {
          certHeader['signature'] = base64.encode(imageFile.readAsBytesSync());
          changed.value = isChanged();
        },
      ),
      'against_description': ReactiveTextField(
        inputFormatters: [
          FilteringTextInputFormatter(
            RegExp('[A-Za-z,\ ]'),
            allow: true,
          ),
        ],
        onChange: (value) {
          certHeader['against_description'] = value.isNotEmpty ? value : null;
          changed.value = isChanged();
        },
      ),
    };

    Widget bottomSheetContent = StatefulBuilder(
      builder: (context, setState) {
        if (!initRequested) {
          global.VaccineDatabaseSource.viewCertHeader(
                  _notifier.selectedPatient['id'])
              .then((map) {
            if (map['signature'] != null) {
              map['signature'] =
                  '${map['signature']}'.replaceAll(RegExp('(\r|\n|\r\n)'), '');
            }
            map.forEach((key, value) {
              if (input[key] is ReactiveTextField) {
                (input[key] as ReactiveTextField).value = value ?? '';
              }

              if (input[key] is CombinedImagePicker) {
                (input[key] as CombinedImagePicker).setImageByBase64(value);
              }

              if (input[key] is DateTimeTextField) {
                (input[key] as DateTimeTextField).value =
                    DateTime.tryParse('$value');
              }
            });
            certHeader.addAll(map);
            originalCertHeader.addAll(map);
          }).whenComplete(() {
            setState(() {
              initRequested = true;
              requesting = false;
            });
          });
        }

        if (requesting) {
          return Center(
            child: global.LoadingIcon.large(),
          );
        }

        return Column(
          children: [
            Expanded(
              flex: 2,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(15),
                child: GenericLayout([
                  Text('ชื่อ-นามสกุล (ภาษาอังกฤษ)'),
                  input['fullname_in_cert'],
                  Text('เพศ'),
                  input['sex'],
                  Text('วันเดือนปีเกิด'),
                  input['date_of_birth'],
                  Text('สัญชาติ (ภาษาอังกฤษ)'),
                  input['nationality'],
                  Text('ลายเซ็น'),
                  input['signature'],
                  Text('ได้รับวัคซีนและยาต้านโรค ได้แก่ (ภาษาอังกฤษ)'),
                  input['against_description'],
                ]),
              ),
            ),
            ChangeNotifierProvider.value(
              value: changed,
              builder: (context, child) => Consumer<BooleanNotifier>(
                builder: (context, _, child) => CustomButton(
                  child: Text('บันทึก'),
                  onPressed: _.value
                      ? () {
                          setState(() {
                            requesting = true;
                          });
                          var diff = onlyDiffCertHeader();
                          global.VaccineDatabaseSource.editCertHeader(
                            editedMap: diff,
                            patientId: patientId,
                          ).then((map) {
                            if (map['signature'] != null) {
                              map['signature'] = '${map['signature']}'
                                  .replaceAll(RegExp('(\r|\n|\r\n)'), '');
                            }
                            map.forEach((key, value) {
                              if (input[key] is ReactiveTextField) {
                                (input[key] as ReactiveTextField).value =
                                    value ?? '';
                              }

                              if (input[key] is CombinedImagePicker) {
                                (input[key] as CombinedImagePicker)
                                    .setImageByBase64(value);
                              }

                              if (input[key] is DateTimeTextField) {
                                (input[key] as DateTimeTextField).value =
                                    DateTime.tryParse('$value');
                              }
                            });
                            certHeader.addAll(map);
                            originalCertHeader.addAll(map);

                            _.value = false;
                          }).whenComplete(() {
                            setState(() {
                              requesting = false;
                            });
                          });
                        }
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );

    await showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (context) => SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height - global.StatusBar.height,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: bottomSheetContent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ใบรับรองการรับวัคซีน'),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PatientSelector(
              preferenceTarget: 'certificate_patient',
              onSelect: (selected) {
                _notifier.update(
                  selectedPatient: selected,
                );

                _network.update(
                  requested: false,
                  requesting: true,
                );

                List<Map<String, dynamic>> list;
                global.VaccineDatabaseSource.listCertification(selected['id'])
                    .then((value) {
                  list = value;
                }).whenComplete(() {
                  _notifier.update(
                    certList: list,
                  );

                  _network.update(
                    requested: true,
                    requesting: false,
                  );
                });
              },
              onPreferenceLoaded: (loaded) {
                List<Map<String, dynamic>> list;

                _notifier.update(
                  selectedPatient: loaded,
                );

                _network.update(
                  initRequested: false,
                  requested: false,
                  requesting: true,
                );

                global.VaccineDatabaseSource.listCertification(loaded['id'])
                    .then((value) {
                  list = value;
                }).whenComplete(() {
                  _notifier.update(
                    certList: list,
                  );

                  _network.update(
                    initRequested: true,
                    requested: true,
                    requesting: false,
                  );
                });
              },
            ),
            Padding(
              padding: EdgeInsets.all(5),
            ),
            Expanded(
              flex: 2,
              child: MultiProvider(
                providers: [
                  ChangeNotifierProvider<_CertNetworkStateNotifier>.value(
                    value: _network,
                  ),
                  ChangeNotifierProvider<_CertDataNotifier>.value(
                    value: _notifier,
                  ),
                  ChangeNotifierProvider<IntNotifier>.value(
                    value: _certSelectedPanelIndex,
                  ),
                ],
                builder: (context, child) =>
                    Consumer2<_CertNetworkStateNotifier, _CertDataNotifier>(
                  builder: (context, network, notifier, child) {
                    if (network.requesting) {
                      return Container(
                        height: double.infinity,
                        child: Center(
                          child: global.LoadingIcon.large(),
                        ),
                      );
                    }

                    if (isCertListEmpty && network.requested) {
                      return Container(
                        height: double.infinity,
                        child: Center(
                          child: Text(
                            'ไม่พบใบรับรองการรับวัคซีน',
                            textAlign: TextAlign.center,
                            textScaleFactor: 1.5,
                          ),
                        ),
                      );
                    }

                    return Consumer<IntNotifier>(
                      builder: (context, selectedPanelIndex, child) {
                        List<ExpansionPanel> children = <ExpansionPanel>[];
                        int index = 0;

                        notifier.certList.forEach((element) {
                          children.add(ExpansionPanel(
                            canTapOnHeader: true,
                            headerBuilder: (context, isExpanded) {
                              String against = element['vaccine_against'];
                              String age = _age[against];
                              String againstMsg = '';
                              _vaccine.forEach((key, value) {
                                if (against.contains(
                                    RegExp('${key}_(first|second|third)'))) {
                                  againstMsg = value;
                                }
                              });
                              return Container(
                                padding: EdgeInsets.all(15),
                                child: Text(
                                    '[อายุ${age.contains(RegExp('^[0-9]')) ? ' ' : ''}$age] $againstMsg'),
                              );
                            },
                            isExpanded: selectedPanelIndex.value == index++,
                            body: Container(
                              child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('แก้ไขรายการรับรองวัคซีน'),
                                    onTap: () {
                                      _showCertificatePanel(
                                        certificateId: element['id'],
                                        patientId:
                                            notifier.selectedPatient['id'],
                                        context: context,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ));
                        });

                        return SingleChildScrollView(
                          child: ExpansionPanelList(
                            expandedHeaderPadding: EdgeInsets.zero,
                            expansionCallback: (panelIndex, isExpanded) {
                              if (isExpanded &&
                                  panelIndex == selectedPanelIndex.value) {
                                selectedPanelIndex.value = -1;
                                return;
                              }
                              selectedPanelIndex.value = panelIndex;
                            },
                            children: children,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: MultiProvider(
        providers: [
          ChangeNotifierProvider<_CertNetworkStateNotifier>.value(
            value: _network,
          ),
          ChangeNotifierProvider<_CertDataNotifier>.value(
            value: _notifier,
          ),
        ],
        child: Consumer2<_CertNetworkStateNotifier, _CertDataNotifier>(
          builder: (context, network, notifier, child) {
            // debugPrint('${network.requesting}');
            // debugPrint(
            //     '${network.requesting || (network.requested && notifier.certList.length == 0)}');
            if (network.requesting) {
              return Container();
            }

            return SpeedDial(
              orientation: SpeedDialOrientation.Up,
              icon: Icons.menu,
              activeIcon: Icons.add,
              backgroundColor: Colors.blue,
              iconTheme: IconThemeData(color: Colors.white),
              children: [
                SpeedDialChild(
                  label: 'เพิ่มรายการวัคซีนรับรอง',
                  backgroundColor: Colors.green,
                  child: Icon(
                    Icons.my_library_books,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    String against = await _showAvailableVaccination(
                      context: context,
                    );
                    if (against != null && notifier.selectedPatient != null) {
                      network.update(
                        requesting: true,
                        requested: false,
                      );

                      global.VaccineDatabaseSource.createCertification(
                        against: against,
                        patientId: notifier.selectedPatient['id'],
                      ).then((value) {
                        // debugPrint('$value');
                        List<Map<String, dynamic>> list =
                            List<Map<String, dynamic>>.from(
                          notifier.certList,
                        );
                        list.add(value);
                        // debugPrint('$list');

                        notifier.update(
                          certList: list,
                        );

                        network.update(
                          requesting: false,
                          requested: true,
                        );
                      });
                    }
                  },
                ),
                SpeedDialChild(
                  label: 'แก้ไขข้อมูลส่วนบนใบรับรอง',
                  backgroundColor: Colors.amber,
                  child: Icon(
                    Icons.edit,
                    color: Colors.white,
                  ),
                  onTap: () {
                    _showCertificateHeaderPanel(
                      patientId: notifier.selectedPatient['id'],
                      context: context,
                    );
                  },
                ),
                SpeedDialChild(
                  label: 'ออกใบรับรองเป็นไฟล์ PDF',
                  backgroundColor: Colors.red,
                  child: Icon(
                    Icons.insert_drive_file,
                    color: Colors.white,
                  ),
                  onTap: () async {
                    List<Map<String, dynamic>> list = [];
                    Map<String, dynamic> header = {};
                    bool success = false;

                    await showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        global.VaccineDatabaseSource.getFullCertification(
                          patientId: notifier.selectedPatient['id'],
                        ).then((value) {
                          list.addAll(value['list']);
                          header.addAll(value['header']);
                          success = true;
                        }).whenComplete(() {
                          Navigator.of(context).pop();
                        });

                        return Container(
                          child: Center(
                            child: global.LoadingIcon.large(),
                          ),
                        );
                      },
                    );

                    if (success) _viewAsPDF(header, list);
                  },
                ),
              ],
            );

            // return UnicornDialer(
            //   orientation: UnicornOrientation.VERTICAL,
            //   parentButton: Icon(Icons.add),
            //   childButtons: <UnicornButton>[
            //     UnicornButton(
            //       hasLabel: true,
            //       labelText: 'เพิ่มรายการวัคซีนรับรอง',
            //       currentButton: FloatingActionButton(
            //         heroTag: 'add_certification',
            //         backgroundColor: Colors.green,
            //         child: Icon(
            //           Icons.my_library_books,
            //         ),
            //         mini: true,
            //         onPressed: () async {
            //           String against = await _showAvailableVaccination(
            //             context: context,
            //           );
            //           if (against != null && notifier.selectedPatient != null) {
            //             network.update(
            //               requesting: true,
            //               requested: false,
            //             );

            //             global.VaccineDatabaseSource.createCertification(
            //               against: against,
            //               patientId: notifier.selectedPatient['id'],
            //             ).then((value) {
            //               // debugPrint('$value');
            //               List<Map<String, dynamic>> list =
            //                   List<Map<String, dynamic>>.from(
            //                 notifier.certList,
            //               );
            //               list.add(value);
            //               // debugPrint('$list');

            //               notifier.update(
            //                 certList: list,
            //               );

            //               network.update(
            //                 requesting: false,
            //                 requested: true,
            //               );
            //             });
            //           }
            //         },
            //       ),
            //     ),
            //     UnicornButton(
            //       hasLabel: true,
            //       labelText: 'แก้ไขข้อมูลส่วนบนใบรับรอง',
            //       currentButton: FloatingActionButton(
            //         heroTag: 'edit_cert_header',
            //         backgroundColor: Colors.amber,
            //         child: Icon(Icons.edit),
            //         mini: true,
            //         onPressed: () {
            //           _showCertificateHeaderPanel(
            //             patientId: notifier.selectedPatient['id'],
            //             context: context,
            //           );
            //         },
            //       ),
            //     ),
            //     UnicornButton(
            //       hasLabel: true,
            //       labelText: 'ออกใบรับรองเป็นไฟล์ PDF',
            //       currentButton: FloatingActionButton(
            //         heroTag: 'create_pdf',
            //         backgroundColor: Colors.red,
            //         child: Icon(
            //           Icons.insert_drive_file,
            //         ),
            //         mini: true,
            //         onPressed: () async {
            //           List<Map<String, dynamic>> list = [];
            //           Map<String, dynamic> header = {};
            //           bool success = false;

            //           await showModalBottomSheet(
            //             context: context,
            //             builder: (context) {
            //               global.VaccineDatabaseSource.getFullCertification(
            //                 patientId: notifier.selectedPatient['id'],
            //               ).then((value) {
            //                 list.addAll(value['list']);
            //                 header.addAll(value['header']);
            //                 success = true;
            //               }).whenComplete(() {
            //                 Navigator.of(context).pop();
            //               });

            //               return Container(
            //                 child: Center(
            //                   child: global.LoadingIcon.large(),
            //                 ),
            //               );
            //             },
            //           );

            //           if (success) _viewAsPDF(header, list);
            //         },
            //       ),
            //     ),
            //   ],
            // );
          },
        ),
      ),
    );
  }
}
