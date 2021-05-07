import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../widget/custom_button.dart';
import '../widget/input.dart';
import '../layout/generic.dart';
import '../modules/_base.dart';
import '../widget/collapsible.dart';
import '../widget/interactive_text.dart';
import '../../global.dart' as global;

class _RCState extends State<_RecordCollapsed> {
  @override
  Widget build(BuildContext context) {
    int i = 1;
    return Collapsible(
      header: Text(this.widget._data['title']),
      content: Container(
        child: GenericLayout(
          (this.widget._data['list'] as List)
              .map(
                (e) => {
                  'widget': Row(
                    children: [
                      Text('${i++})'),
                      Padding(
                        padding: EdgeInsets.only(left: 5),
                      ),
                      InteractiveText(e['title'] ?? ''),
                    ],
                  ),
                },
              )
              .toList(),
        ),
      ),
    );
  }
}

/// A collapsible widget that provide vaccine record data.
class _RecordCollapsed extends StatefulWidget {
  final Map<String, dynamic> _data = {
    'title': '',
    'list': [],
  };

  _RecordCollapsed({
    String title = '',
    List<Map<String, dynamic>> list = const [],
  }) : super() {
    this._data['title'] = title;
    this._data['list'] = list;
  }

  @override
  _RCState createState() => _RCState();
}

class _State extends State<_Widget> {
  final Map<String, dynamic> _currentPatient = {
    'id': -1,
    'firstname': '',
    'lastname': '',
  };

  final Map<String, dynamic> _currentRecord = {
    'requested': false,
    'requesting': false,
    'empty': true,
    'id': -1,
    'bcg_first': null,
    'hb_first': null,
    'hb_second': null,
    'opv_early_first': null,
    'opv_early_second': null,
    'opv_early_third': null,
    'dtp_hb_first': null,
    'dtp_hb_second': null,
    'dtp_hb_third': null,
    'ipv_first': null,
    'mmr_first': null,
    'mmr_second': null,
    'je_first': null,
    'je_seconds': null,
    'opv_later_first': null,
    'opv_later_second': null,
    'dtp_first': null,
    'dtp_second': null,
    'hpv_first': null,
    'dt_first': null,
    'vaccine_id_bcg_first': null,
    'vaccine_id_hb_first': null,
    'vaccine_id_hb_second': null,
    'vaccine_id_opv_early_first': null,
    'vaccine_id_opv_early_second': null,
    'vaccine_id_opv_early_third': null,
    'vaccine_id_dtp_hb_first': null,
    'vaccine_id_dtp_hb_second': null,
    'vaccine_id_dtp_hb_third': null,
    'vaccine_id_ipv_first': null,
    'vaccine_id_mmr_first': null,
    'vaccine_id_mmr_second': null,
    'vaccine_id_je_first': null,
    'vaccine_id_je_seconds': null,
    'vaccine_id_opv_later_first': null,
    'vaccine_id_opv_later_second': null,
    'vaccine_id_dtp_first': null,
    'vaccine_id_dtp_second': null,
    'vaccine_id_hpv_first': null,
    'vaccine_id_dt_first': null
  };

  final List<String> alias = const ['first', 'second', 'third'];
  Widget _createRecordCollapsible(
    BuildContext context, {
    @required String against,
    @required String summary,
    @required List<String> displayed,
  }) {
    List<String> found = [];
    this._currentRecord.forEach((key, value) {
      String k = key.replaceAll(RegExp(r'_(first|second|third)'), '');
      if (k == against) found.add(key);
    });

    int i = 0;

    return ExpansionTile(
      title: Text(
        summary,
        style: TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      children: found.map((e) {
        int pos = i++;

        return ListTile(
          title: Text('ครั้งที่ ${pos + 1}: ' + (displayed[pos] ?? '')),
          onTap: () async {
            String target() => '${against}_${alias[pos]}';
            String datestring() => this._currentRecord[target()];
            bool patching = false;
            DateTime date = DateTime.tryParse('${datestring()}');

            await showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              builder: (context) {
                return SingleChildScrollView(
                  child: Container(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: StatefulBuilder(
                      builder: (context, setState) {
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: 300,
                          ),
                          child: Column(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: EdgeInsets.all(15),
                                  child: GenericLayout([
                                    [
                                      {
                                        'widget': Text(
                                          'วันที่ได้รับวัคซีน',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                        'flex': 0,
                                      },
                                      {
                                        'widget': Visibility(
                                          visible: !patching,
                                          child: GestureDetector(
                                            child: Icon(
                                              Icons.edit,
                                              size: 28,
                                            ),
                                            onTap: () async {
                                              DateTime now = DateTime.now();
                                              DateTime selectedDate =
                                                  await showDatePicker(
                                                context: context,
                                                initialDate: date ?? now,
                                                firstDate: DateTime(1970),
                                                lastDate: now,
                                                locale: Locale('th', 'TH'),
                                              );

                                              if (selectedDate != null) {
                                                setState(() {
                                                  patching = true;
                                                });

                                                var result = await global
                                                        .VaccineDatabaseSource
                                                    .updateRecord(
                                                  {
                                                    'id': this
                                                        ._currentRecord['id'],
                                                    '${target()}': selectedDate
                                                        .toIso8601String(),
                                                  },
                                                );

                                                if (result != null) {
                                                  setState(() {
                                                    this
                                                        ._currentRecord
                                                        .addAll(result);
                                                    date = DateTime.tryParse(
                                                        this._currentRecord[
                                                            target()]);
                                                    patching = false;
                                                  });
                                                }
                                              }
                                            },
                                          ),
                                        ),
                                        'flex': 0,
                                        'spacingOnNext': !patching,
                                      },
                                      {
                                        'widget': Visibility(
                                          visible: patching,
                                          child: SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 3,
                                            ),
                                          ),
                                        ),
                                        'flex': 0,
                                      }
                                    ],
                                    {
                                      'widget': Input(
                                        value:
                                            '${date != null ? DateFormat('d MMMM yyyy', 'th').format(date) : '-'}',
                                        disabled: true,
                                      ),
                                    },
                                  ]),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            );
          },
        );
      }).toList(),
    );
  }

  /// Create a stateful widget for selecting patient.
  Future<Map<String, dynamic>> _createPatientSelector(
      BuildContext context) async {
    String fname = '';
    String lname = '';
    int page = 1;
    bool patientRequested = false;
    bool hasPatient = false;
    bool userInfoRequested = false;
    bool patientCreatorDisabled = false;
    bool createPatientRequesting = false;
    bool confirmed = false;
    Map<String, dynamic> selectedPatient;
    List<Map<String, dynamic>> list = [];

    // Waiting the execution until bottom sheet has been dismissed.
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: StatefulBuilder(builder: (context, setState) {
              // Retrieve all available patient.
              if (!patientRequested)
                global.VaccineDatabaseSource.getAvailablePatient()
                    .then((value) {
                  setState(() {
                    patientRequested = true;
                    hasPatient = true;
                    list = value;
                  });
                }).catchError((error) {
                  setState(() {
                    patientRequested = true;
                    hasPatient = false;
                  });
                });

              // Create a whole widget.
              return Container(
                constraints: BoxConstraints(
                  maxHeight: 450,
                ),
                child: Row(
                  children: [
                    // Page 1: [Patient Selector] widget
                    Visibility(
                      visible: page == 1,
                      child: Expanded(
                        flex: 2,
                        child: Container(
                          child: Column(
                            children: [
                              Expanded(
                                flex: !hasPatient ? 2 : 0,
                                child: Container(
                                  padding:
                                      !hasPatient ? EdgeInsets.all(15) : null,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Widget: [Circular Loading Indicator]
                                      Visibility(
                                        visible: !patientRequested,
                                        child: SizedBox(
                                          width: 75,
                                          height: 75,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 5,
                                          ),
                                        ),
                                      ),
                                      // Widget: [Message displayed when no available patient has been found]
                                      Visibility(
                                        visible:
                                            patientRequested && !hasPatient,
                                        child: Column(
                                          children: [
                                            Text(
                                              'ไม่พบรายชื่อของผู้รับบันทึกการรับวัคซีนที่คุณสามารถดูได้',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                top: 20,
                                              ),
                                            ),
                                            // Widget: [Link for Page 2]
                                            InteractiveText(
                                              'สามารถสร้างรายชื่อผู้ถือบันทึกการรับวัคซีนของคุณได้ที่นี่',
                                              textAlign: TextAlign.center,
                                              onPress: () {
                                                setState(() {
                                                  page = 2;
                                                });

                                                // After changing to page 2, getting user information then display page 2.
                                                global.VaccineDatabaseSource
                                                        .getUserInfo()
                                                    .then((value) {
                                                  setState(() {
                                                    userInfoRequested = true;
                                                    patientCreatorDisabled =
                                                        true;
                                                    fname = value['firstname'];
                                                    lname = value['lastname'];
                                                  });
                                                }).catchError((error) {
                                                  setState(() {
                                                    userInfoRequested = true;
                                                    patientCreatorDisabled =
                                                        true;
                                                  });
                                                });
                                              },
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Widget: [Patient selection list when available]
                              Expanded(
                                flex: patientRequested && hasPatient ? 2 : 0,
                                child: Visibility(
                                  visible: patientRequested && hasPatient,
                                  child: Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        // Widget: [List of available patient]
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.all(10),
                                            height: double.infinity,
                                            child: ConstrainedBox(
                                              constraints: BoxConstraints(
                                                minHeight: double.infinity,
                                              ),
                                              child: ListView(
                                                shrinkWrap: true,
                                                children: list
                                                    .map(
                                                      (e) => RadioListTile(
                                                        title: Text(
                                                          '${e['firstname']} ${e['lastname']}',
                                                        ),
                                                        value: e,
                                                        groupValue:
                                                            selectedPatient,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            selectedPatient =
                                                                value;
                                                          });
                                                        },
                                                      ),
                                                    )
                                                    .toList(),
                                              ),
                                            ),
                                          ),
                                        ),
                                        // Widget: [Button for patient selecting confirmation]
                                        CustomButton(
                                          child: Text(
                                            'ตกลง',
                                            style: TextStyle(
                                              color: Color(0xffffffff),
                                            ),
                                            textScaleFactor: 1.75,
                                          ),
                                          onPressed: selectedPatient != null
                                              ? () {
                                                  confirmed = true;
                                                  Navigator.of(context).pop();
                                                }
                                              : null,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Page 2: [Patient Creator]
                    Visibility(
                      visible: page == 2,
                      child: Expanded(
                        flex: 2,
                        child: Container(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Widget: [Circular Loading Indicator]
                              Visibility(
                                visible: !userInfoRequested,
                                child: SizedBox(
                                  width: 75,
                                  height: 75,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 5,
                                  ),
                                ),
                              ),
                              // Widget: [Form of patient creation]
                              Visibility(
                                visible: userInfoRequested,
                                child: Expanded(
                                  flex: 2,
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            padding: EdgeInsets.all(15),
                                            child: GenericLayout([
                                              // Widget: [Heading]
                                              [
                                                {
                                                  'widget': Text(
                                                    'สร้างรายชื่อ',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  'flex': 0,
                                                },
                                                // Widget: [Edit Button]
                                                {
                                                  'widget': Visibility(
                                                    visible:
                                                        patientCreatorDisabled &&
                                                            !createPatientRequesting,
                                                    child: GestureDetector(
                                                      child: Icon(Icons.edit),
                                                      onTap: () {
                                                        setState(() {
                                                          patientCreatorDisabled =
                                                              false;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  'flex': 0,
                                                  'spacingOnNext':
                                                      patientCreatorDisabled,
                                                },
                                                // Widget: [Save Button]
                                                {
                                                  'widget': Visibility(
                                                    visible:
                                                        !patientCreatorDisabled &&
                                                            !createPatientRequesting,
                                                    child: GestureDetector(
                                                      child: Icon(Icons.save),
                                                      onTap: () {
                                                        setState(() {
                                                          patientCreatorDisabled =
                                                              true;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  'flex': 0,
                                                }
                                              ],
                                              // Widget: [Firstname]
                                              Input(
                                                placeholder: 'ชื่อ',
                                                value: fname,
                                                disabled:
                                                    patientCreatorDisabled,
                                                onChanged: (value) {
                                                  fname = value;
                                                },
                                              ),
                                              // Widget: [Lastname]
                                              Input(
                                                placeholder: 'นามสกุล',
                                                value: lname,
                                                disabled:
                                                    patientCreatorDisabled,
                                                onChanged: (value) {
                                                  lname = value;
                                                },
                                              ),
                                            ]),
                                          ),
                                        ),
                                        // Widget: [Button for creating patient confirmation]
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: !createPatientRequesting
                                                ? LinearGradient(
                                                    colors: [
                                                      Color(0xff00cfff),
                                                      Color(0xff008fff),
                                                    ],
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                  )
                                                : null,
                                            color: createPatientRequesting
                                                ? Color(0xffafafaf)
                                                : null,
                                          ),
                                          width: double.infinity,
                                          child: TextButton(
                                            onPressed: !createPatientRequesting
                                                ? () {
                                                    setState(() {
                                                      patientCreatorDisabled =
                                                          true;
                                                      createPatientRequesting =
                                                          true;
                                                    });

                                                    global.VaccineDatabaseSource
                                                            .createOwnPatient(
                                                                firstname:
                                                                    fname,
                                                                lastname: lname)
                                                        .then((value) {
                                                          setState(() {
                                                            page = 1;
                                                            patientRequested =
                                                                false;
                                                          });
                                                        })
                                                        .catchError((error) {})
                                                        .whenComplete(() {
                                                          setState(() {
                                                            createPatientRequesting =
                                                                false;
                                                          });
                                                        });
                                                  }
                                                : null,
                                            child: Text(
                                              'สร้าง',
                                              style: TextStyle(
                                                color: Color(0xffffffff),
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        );
      },
    );

    return confirmed ? selectedPatient : null;
  }

  void _viewRecord() {
    global.VaccineDatabaseSource.viewRecord(
      patientID: this._currentPatient['id'] ?? -1,
    ).then((value) {
      this.setState(() {
        this._currentRecord['requested'] = true;
        this._currentRecord['requesting'] = false;
        this._currentRecord['empty'] = false;
        this._currentRecord.addAll(value);
      });
    }).catchError((error) {
      this.setState(() {
        this._currentRecord['requested'] = true;
        this._currentRecord['requesting'] = false;
        this._currentRecord['empty'] = true;
      });
    });
  }

  void initState() {
    super.initState();
    global.LocalStorage.instance().then((pref) {
      int id = pref.getInt('patient_id');
      String firstname = pref.getString('patient_firstname');
      String lastname = pref.getString('patient_lastname');
      if (id == null) return;

      this.setState(() {
        if (id != null) this._currentPatient['id'] = id;
        if (firstname != null) this._currentPatient['firstname'] = firstname;
        if (lastname != null) this._currentPatient['lastname'] = lastname;
        this._currentRecord['requesting'] = true;
      });

      this._viewRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xff00cfff),
                Color(0xff008fff),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(5),
            boxShadow: [
              BoxShadow(
                color: Color(0x6f000000),
                blurRadius: 5,
              ),
            ],
          ),
          width: double.infinity,
          child: TextButton(
            onPressed: () {
              _createPatientSelector(context).then((value) {
                if (value == null) return;

                global.LocalStorage.instance().then((pref) async {
                  await pref.setInt('patient_id', value['id']);
                  await pref.setString('patient_firstname', value['firstname']);
                  await pref.setString('patient_lastname', value['lastname']);
                });

                this.setState(() {
                  this._currentPatient.addAll(value);
                  this._currentRecord['requesting'] = true;
                  this._currentRecord['requested'] = true;
                });

                this._viewRecord();
              });
            },
            child: Row(
              children: [
                Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xffffffff),
                  size: 36,
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    // width: double.infinity,
                    child: Text(
                      this._currentPatient['id'] == -1
                          ? '<โปรดเลือกบันทึก>'
                          : '${this._currentPatient['firstname']} ${this._currentPatient['lastname']}',
                      style: TextStyle(
                        color: Color(0xffffffff),
                      ),
                      overflow: TextOverflow.ellipsis,
                      textScaleFactor: 1.75,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            top: 15,
          ),
        ),
        Expanded(
          flex: 2,
          child: Container(
            height: double.infinity,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: this._currentRecord['empty'] ||
                      this._currentRecord['requesting']
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                Visibility(
                  visible: this._currentRecord['empty'] &&
                      this._currentRecord['requested'] &&
                      !this._currentRecord['requesting'],
                  child: Text(
                    'ไม่พบบันทึกของรายชื่อนี้',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                Visibility(
                  visible: this._currentRecord['empty'] &&
                      this._currentRecord['requested'] &&
                      !this._currentRecord['requesting'],
                  child: InteractiveText(
                    'สร้างบันทึกให้กับรายชื่อนี้ได้ที่นี่',
                    onPress: () {
                      this.setState(() {
                        this._currentRecord['requesting'] = true;
                        this._currentRecord['requested'] = false;
                      });

                      global.VaccineDatabaseSource.createRecord(
                        patientID: this._currentPatient['id'],
                      ).then((value) {
                        this.setState(() {
                          this._currentRecord['requesting'] = false;
                          this._currentRecord['requested'] = true;
                          this._currentRecord['empty'] = false;
                          this._currentRecord.addAll(value);
                        });
                      }).catchError((error) {
                        this.setState(() {
                          this._currentRecord['requested'] = true;
                          this._currentRecord['requesting'] = false;
                          this._currentRecord['empty'] = true;
                        });
                      });
                    },
                  ),
                ),
                Visibility(
                  visible: this._currentRecord['requesting'],
                  child: SizedBox(
                    width: 75,
                    height: 75,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
                  ),
                ),
                Visibility(
                  visible: this._currentRecord['requested'] &&
                      !this._currentRecord['requesting'] &&
                      !this._currentRecord['empty'],
                  child: Expanded(
                    flex: 2,
                    child: Container(
                      child: ListView(
                        children: [
                          {
                            'against': 'bcg',
                            'summary': 'ฉีดวัคซีนป้องกันวัณโรค (BCG)',
                            'displayed': ['อายุแรกเกิด']
                          },
                          {
                            'against': 'hb',
                            'summary': 'ฉีดวัคซีนป้องกันโรคตับอักเสบบี (HB)',
                            'displayed': [
                              'อายุแรกเกิด',
                              'อายุ 1 เดือน (เฉพาะแม่ที่เป็นพาหะ)'
                            ],
                          },
                          {
                            'against': 'opv_early',
                            'summary': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
                            'displayed': [
                              'อายุ 2 เดือน',
                              'อายุ 4 เดือน',
                              'อายุ 6 เดือน'
                            ],
                          },
                          {
                            'against': 'dtp_hb',
                            'summary':
                                'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
                            'displayed': [
                              'อายุ 2 เดือน',
                              'อายุ 4 เดือน',
                              'อายุ 6 เดือน'
                            ],
                          },
                          {
                            'against': 'ipv',
                            'summary': 'ฉีดวัคซีนป้องกันโรคโปลิโอ (IPV)',
                            'displayed': ['อายุ 4 เดือน'],
                          },
                          {
                            'against': 'mmr',
                            'summary':
                                'ฉีดวัคซีนรวมป้องกันโรคหัด-คางทูม-หัดเยอรมัน (MMR)',
                            'displayed': ['อายุ 2 เดือน', 'อายุ 2 ปี 6 เดือน'],
                          },
                          {
                            'against': 'je',
                            'summary':
                                'ฉีดวัคซีนป้องกันโรคไข้สมองอักเสบเจอี (JE)',
                            'displayed': ['อายุ 1 ปี', 'อายุ 2 ปี 6 เดือน']
                          },
                          {
                            'against': 'opv_later',
                            'summary': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
                            'displayed': ['อายุ 1 ปี 6 เดือน', 'อายุ 4 ปี'],
                          },
                          {
                            'against': 'dtp',
                            'summary':
                                'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน (DTP)',
                            'displayed': ['อายุ 1 ปี 6 เดือน', 'อายุ 4 ปี'],
                          },
                          {
                            'against': 'hpv',
                            'summary': 'ฉีดวัคซีนป้องกันเอชพีวี (HPV)',
                            'displayed': ['อายุ 11 ปี (นักเรียนหญิงชั้น ป.5)'],
                          },
                          {
                            'against': 'dt',
                            'summary':
                                'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก (dT)',
                            'displayed': ['อายุ 12 ปี (ชั้น ป.6)'],
                          }
                        ]
                            .map((e) => this._createRecordCollapsible(
                                  context,
                                  against: e['against'],
                                  summary: e['summary'],
                                  displayed: e['displayed'],
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Widget extends StatefulWidget {
  @override
  _State createState() => _State();
}

class Records extends Module {
  @override
  Widget createWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บันทึกการรับวัคซีน'),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        child: _Widget(),
      ),
    );
  }
}
