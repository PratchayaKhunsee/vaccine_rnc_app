import 'package:flutter/material.dart';
import '../../src/layout/generic.dart';
import '../../src/widget/custom_button.dart';
import '../../src/widget/input.dart';
import '../../global.dart' as global;
import '_base.dart';

class _State extends State<_Widget> {
  final Map<String, dynamic> _data = {
    'requesting': false,
    'availablePatient': null,
    'panelSelectedIndex': -1,
    // 'availExpanded': null,
  };

  @override
  void initState() {
    super.initState();
    this.setState(() {
      _data['requesting'] = true;
    });

    global.VaccineDatabaseSource.getAvailablePatient().then((value) {
      value.sort((a, b) {
        if (a['is_primary'] || a['id'] < b['id']) return -1;
        if (b['is_primary'] || a['id'] > b['id']) return 1;
        return 0;
      });
      this.setState(() {
        _data['availablePatient'] = value;
        _data['requesting'] = false;
      });
    }).catchError((error) {
      this.setState(() {
        _data['requesting'] = false;
      });
    });
  }

  void _showPatientCreator(BuildContext context) async {
    Map<String, dynamic> result = {
      'firstname': '',
      'lastname': '',
    };

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
                  width: MediaQuery.of(context).size.width,
                  constraints: BoxConstraints(
                    maxHeight: 300,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 2,
                        child: Container(
                          padding: EdgeInsets.all(20),
                          child: GenericLayout([
                            {
                              'widget': Text(
                                'สร้างรายชื่อ',
                                textScaleFactor: 1.75,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            },
                            {
                              'widget': Input(
                                placeholder: 'ชื่อ',
                                onChanged: (value) {
                                  result['firstname'] = value;
                                },
                                value: result['firstname'],
                              ),
                            },
                            {
                              'widget': Input(
                                placeholder: 'นามสกุล',
                                onChanged: (value) {
                                  result['lastname'] = value;
                                },
                                value: result['lastname'],
                              ),
                            }
                          ]),
                        ),
                      ),
                      CustomButton(
                        child: Text('ยืนยัน'),
                        onPressed: result['firstname'] != '' &&
                                result['lastname'] != ''
                            ? () {
                                Navigator.of(context).pop();
                                // global.VaccineDatabaseSource.createPatientAsChild(firstname: res, lastname: null, personId: null)
                              }
                            : null,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        // return SingleChildScrollView(
        // child: Container(
        //   padding: EdgeInsets.only(
        //     bottom: MediaQuery.of(context).viewInsets.bottom,
        //   ),
        //   // child: StatefulBuilder(
        //   //   builder: (context, setState) {
        //   //     return Container(
        //   //       child: Column(
        //   //         crossAxisAlignment: CrossAxisAlignment.stretch,
        //   //         children: [
        //   //           Expanded(
        //   //             flex: 2,
        //   //             child: Container(
        //   //               padding: EdgeInsets.all(20),
        //   //               child: GenericLayout([
        //   //                 {
        //   //                   'widget': Text(
        //   //                     'สร้างรายชื่อ',
        //   //                     textScaleFactor: 1.75,
        //   //                     style: TextStyle(
        //   //                       fontWeight: FontWeight.bold,
        //   //                     ),
        //   //                   ),
        //   //                 },
        //   //                 {
        //   //                   'widget': Input(
        //   //                     placeholder: 'ชื่อ',
        //   //                     onChanged: (value) {
        //   //                       result['firstname'] = value;
        //   //                     },
        //   //                     value: result['firstname'],
        //   //                   ),
        //   //                 },
        //   //                 {
        //   //                   'widget': Input(
        //   //                     placeholder: 'นามสกุล',
        //   //                     onChanged: (value) {
        //   //                       result['lastname'] = value;
        //   //                     },
        //   //                     value: result['lastname'],
        //   //                   ),
        //   //                 }
        //   //               ]),
        //   //             ),
        //   //           ),
        //   //           CustomButton(
        //   //             child: Text('ยืนยัน'),
        //   //             onPressed: result['firstname'] != '' &&
        //   //                     result['lastname'] != ''
        //   //                 ? () {
        //   //                     Navigator.of(context).pop();
        //   //                   }
        //   //                 : null,
        //   //           ),
        //   //         ],
        //   //       ),
        //   //     );
        //   //   },
        //   // ),
        // ),
        // );
      },
    );

    String firstname = result['firstname'] ?? '';
    String lastname = result['lastname'] ?? '';
    if (firstname.isNotEmpty && lastname.isNotEmpty) {
      this.setState(() {
        this._data['requesting'] = true;
      });
      global.VaccineDatabaseSource.createPatientAsChild(
        firstname: firstname,
        lastname: lastname,
      ).then((value) {
        this.setState(() {
          var d = this._data['availablePatient'] as List;
          debugPrint('$d');
          d?.add(value);
          d?.sort((a, b) {
            if (a['is_primary'] || a['id'] < b['id']) return -1;
            if (b['is_primary'] || a['id'] > b['id']) return 1;
            return 0;
          });
        });
      }).whenComplete(() {
        this.setState(() {
          this._data['requesting'] = false;
        });
      });
    }
    // return result;
  }

  @override
  Widget build(BuildContext context) {
    int i = 0;
    return Stack(
      children: [
        Column(
          children: [
            // [Widget]: Loading Indicator
            Visibility(
              visible: _data['requesting'],
              child: Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 175,
                        height: 175,
                        child: CircularProgressIndicator(
                          strokeWidth: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // [Widget]: Empty Patient Available
            Visibility(
              visible: !_data['requesting'] &&
                  !(_data['availablePatient'] is List &&
                      _data['availablePatient'].length != 0),
              child: Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.all(10),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'ไม่พบรายชื่อสำหรับผูกกับบันทึกการรับวัคซีน',
                        textAlign: TextAlign.center,
                      ),
                      TextButton(
                        child: Text('สามารถสร้างรายชื่อได้ที่นี่'),
                        onPressed: () {
                          _showPatientCreator(context);
                        },
                      )
                    ],
                  ),
                ),
              ),
            ),
            // [Widget]: Patient Available As List
            Visibility(
              visible: !_data['requesting'] &&
                  _data['availablePatient'] is List &&
                  _data['availablePatient'].length != 0,
              child: Expanded(
                flex: 2,
                child: ListView(
                  children: [
                    Container(
                      padding: EdgeInsets.all(10),
                      child: ExpansionPanelList(
                        expansionCallback: (panelIndex, isExpanded) {
                          this.setState(() {
                            _data['panelSelectedIndex'] =
                                isExpanded ? -1 : panelIndex;
                          });
                        },
                        expandedHeaderPadding: EdgeInsets.all(0),
                        children: _data['availablePatient'] is List
                            ? (_data['availablePatient']
                                    as List<Map<String, dynamic>>)
                                .map<ExpansionPanel>((e) {
                                if (!e.containsKey('expanded'))
                                  e['expanded'] = false;

                                return ExpansionPanel(
                                  canTapOnHeader: true,
                                  headerBuilder: (context, isExpanded) {
                                    return ListTile(
                                      title: Text(
                                        '${e['firstname']} ${e['lastname']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  },
                                  body: Container(
                                    child: Column(
                                      children: [
                                        ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text(
                                            'แก้ไขข้อมูลรายชื่อ',
                                          ),
                                          onTap: () async {
                                            String firstname =
                                                e['firstname'] ?? '';
                                            String lastname =
                                                e['lastname'] ?? '';
                                            bool requesting = false;
                                            await showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              builder: (context) {
                                                return SingleChildScrollView(
                                                  child: Container(
                                                    padding: EdgeInsets.only(
                                                      bottom:
                                                          MediaQuery.of(context)
                                                              .viewInsets
                                                              .bottom,
                                                    ),
                                                    child: StatefulBuilder(
                                                      builder:
                                                          (context, setState) {
                                                        return Container(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  15),
                                                          constraints:
                                                              BoxConstraints(
                                                            minHeight: 300,
                                                          ),
                                                          child: GenericLayout([
                                                            [
                                                              {
                                                                'widget': Text(
                                                                  'ข้อมูลรายชื่อ',
                                                                  textScaleFactor:
                                                                      1.75,
                                                                  style:
                                                                      TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                                'flex': 0,
                                                              },
                                                              {
                                                                'widget':
                                                                    Visibility(
                                                                  visible: (e['firstname'] !=
                                                                              firstname ||
                                                                          e['lastname'] !=
                                                                              lastname) &&
                                                                      !requesting,
                                                                  child:
                                                                      GestureDetector(
                                                                    child: Icon(
                                                                      Icons
                                                                          .save,
                                                                      size: 24,
                                                                    ),
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        requesting =
                                                                            true;
                                                                      });
                                                                      global.VaccineDatabaseSource
                                                                              .updatePatient(
                                                                        firstname:
                                                                            firstname,
                                                                        lastname:
                                                                            lastname,
                                                                      )
                                                                          .then(
                                                                              (value) {
                                                                            this.setState(() {
                                                                              e['firstname'] = value['firstname'];
                                                                              e['lastname'] = value['lastname'];
                                                                            });
                                                                          })
                                                                          .catchError(
                                                                              (error) {})
                                                                          .whenComplete(
                                                                              () {
                                                                            setState(() {
                                                                              requesting = false;
                                                                            });
                                                                          });
                                                                    },
                                                                  ),
                                                                ),
                                                                'flex': 0,
                                                                'spacingOnNext':
                                                                    !requesting,
                                                              },
                                                              {
                                                                'widget':
                                                                    Visibility(
                                                                  visible:
                                                                      requesting,
                                                                  child:
                                                                      GestureDetector(
                                                                    child:
                                                                        SizedBox(
                                                                      height:
                                                                          24,
                                                                      width: 24,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            3,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                'flex': 0,
                                                              }
                                                            ],
                                                            {
                                                              'widget': Input(
                                                                value:
                                                                    firstname,
                                                                placeholder:
                                                                    'ชื่อ',
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    firstname =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            },
                                                            {
                                                              'widget': Input(
                                                                value: lastname,
                                                                placeholder:
                                                                    'นามสกุล',
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    lastname =
                                                                        value;
                                                                  });
                                                                },
                                                              ),
                                                            },
                                                          ]),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                        ),
                                        Visibility(
                                          visible: !e['is_primary'],
                                          child: ListTile(
                                            leading: Icon(Icons.delete),
                                            title: Text('ลบรายชื่อนี้'),
                                            onTap: () async {
                                              bool confirmed = false;
                                              await showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) =>
                                                        AlertDialog(
                                                  title: Text('ลบรายชื่อ'),
                                                  content: Container(
                                                    child: Text(
                                                        'คุณต้องการลบรายชื่อนี้หรือไม่'),
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('ยกเลิก'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        confirmed = true;
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: Text('ตกลง'),
                                                    ),
                                                  ],
                                                ),
                                              );
                                              if (confirmed) {
                                                this.setState(() {
                                                  this._data['requesting'] =
                                                      true;
                                                });

                                                global.VaccineDatabaseSource
                                                        .removePatient(e['id'])
                                                    .then((value) {
                                                  global.LocalStorage.instance()
                                                      .then((pref) async {
                                                    if (pref.getInt(
                                                            'patient_id') ==
                                                        e['id']) {
                                                      await pref
                                                          .remove('patient_id');
                                                      await pref.remove(
                                                          'patient_firstname');
                                                      await pref.remove(
                                                          'patient_lastname');
                                                    }
                                                  });

                                                  this.setState(() {
                                                    var d = this._data[
                                                            'availablePatient']
                                                        as List;
                                                    d?.remove(e);
                                                    d?.sort((a, b) {
                                                      if (a['is_primary'] ||
                                                          a['id'] < b['id'])
                                                        return -1;
                                                      if (b['is_primary'] ||
                                                          a['id'] > b['id'])
                                                        return 1;
                                                      return 0;
                                                    });
                                                    this._data['requesting'] =
                                                        false;
                                                  });
                                                }).catchError((error) {
                                                  this.setState(() {
                                                    this._data['requesting'] =
                                                        false;
                                                  });
                                                });
                                              }
                                            },
                                          ),
                                        ),
                                        // ListTile(
                                        //   leading: Icon(Icons.turned_in),
                                        //   title: Text(
                                        //     'ตั้งเป็นรายชื่อหลัก',
                                        //     style: TextStyle(
                                        //       color: e['is_primary']
                                        //           ? Theme.of(context)
                                        //               .disabledColor
                                        //           : null,
                                        //     ),
                                        //   ),
                                        //   onTap: e['is_primary'] ? null : () {},
                                        // ),
                                      ],
                                    ),
                                  ),
                                  isExpanded:
                                      i++ == _data['panelSelectedIndex'],
                                );
                              }).toList()
                            : [],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        Visibility(
          visible: _data['availablePatient'] is List &&
              _data['availablePatient'].length != 0 &&
              !_data['requesting'],
          child: Positioned.directional(
            textDirection: TextDirection.ltr,
            end: 20,
            bottom: 20,
            child: FloatingActionButton(
              onPressed: () async {
                this._showPatientCreator(context);
              },
              child: Icon(
                Icons.add,
                size: 36,
              ),
              tooltip: 'สร้างรายชื่อ',
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

class Parenting extends Module {
  @override
  Widget createWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ดูแลบันทึกการรับวัคซีน'),
      ),
      body: Container(
        child: _Widget(),
      ),
    );
  }
}
