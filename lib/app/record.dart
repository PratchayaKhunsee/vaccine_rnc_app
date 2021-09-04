import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
// import 'package:vaccine_records_and_certs/src/webservice/vaccine-rnc.dart';

import '_widgets.dart';
import '_import.dart';
import '_change_notifier.dart';

class _VaccineRecordEditor extends StatelessWidget {
  /// Get the list of vaccines.
  static Map<String, String> vaccineList() => const {
        'bcg': 'ฉีดวัคซีนป้องกันวัณโรค (BCG)',
        'hb': 'ฉีดวัคซีนป้องกันโรคตับอักเสบบี (HB)',
        'opv_early': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
        'dtp_hb':
            'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน-ตับอักเสบบี (DTP-HB)',
        'ipv': 'ฉีดวัคซีนป้องกันโรคโปลิโอ (IPV)',
        'mmr': 'ฉีดวัคซีนรวมป้องกันโรคหัด-คางทูม-หัดเยอรมัน (MMR)',
        'je': 'ฉีดวัคซีนป้องกันโรคไข้สมองอักเสบเจอี (JE)',
        'opv_later': 'กินวัคซีนป้องกันโรคโปลิโอ (OPV)',
        'dtp': 'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก-ไอกรน (DTP)',
        'hpv': 'ฉีดวัคซีนป้องกันเอชพีวี (HPV)',
        'dt': 'ฉีดวัคซีนรวมป้องกันโรคคอตีบ-บาดทะยัก (dT)',
      };

  /// Get the recommendation ages of taking vaccination dose depending on [vaccineList].
  static Map<String, String> vaccineDoses() => const {
        'bcg_first': 'อายุแรกเกิด',
        'hb_first': 'อายุแรกเกิด',
        'hb_second': 'อายุ 1 เดือน (เฉพาะแม่ที่เป็นพาหะ)',
        'opv_early_first': 'อายุ 2 เดือน',
        'opv_early_second': 'อายุ 4 เดือน',
        'opv_early_third': 'อายุ 6 เดือน',
        'dtp_hb_first': 'อายุ 2 เดือน',
        'dtp_hb_second': 'อายุ 4 เดือน',
        'dtp_hb_third': 'อายุ 6 เดือน',
        'ipv_first': 'อายุ 4 เดือน',
        'mmr_first': 'อายุ 2 เดือน',
        'mmr_second': 'อายุ 2 ปี 6 เดือน',
        'je_first': 'อายุ 1 ปี',
        'je_second': 'อายุ 2 ปี 6 เดือน',
        'opv_later_first': 'อายุ 1 ปี 6 เดือน',
        'opv_later_second': 'อายุ 4 ปี',
        'dtp_first': 'อายุ 1 ปี 6 เดือน',
        'dtp_second': 'อายุ 4 ปี',
        'hpv_first': 'อายุ 11 ปี (นักเรียนหญิงชั้น ป.5)',
        'dt_first': 'อายุ 12 ปี (ชั้น ป.6)',
      };

  /// The vaccine record information on this widget's instantiation.
  final VaccineRecordResult initialVaccineRecord;

  _VaccineRecordEditor({
    Key? key,
    required this.initialVaccineRecord,
  }) : super(key: key);

  @override
  Widget build(BuildContext _context) {
    Map<String, String> list = vaccineList();
    Map<String, String> doses = vaccineDoses();
    var vaccineRecordMap = initialVaccineRecord.toMap();
    Map<String, DateTime>? modifiedVaccineRecordMap;
    BooleanNotifier saveButtonDisabled = BooleanNotifier(true);
    BooleanNotifier requesting = BooleanNotifier(false);

    EdgeInsets cellPadding = EdgeInsets.all(5);

    List<Widget> vaccineRecordWidgets = [];
    bool first = true;

    list.forEach((vaccineAbvName, vaccinationTitle) {
      List<String> ageOfVaccineDoses = [];
      Text header = Text.rich(TextSpan(text: vaccinationTitle));

      doses.forEach((dose, doseTitle) {
        if (dose.contains(RegExp('^$vaccineAbvName\_(first|second|third)\$'))) {
          ageOfVaccineDoses.add(doseTitle);
        }
      });

      int i = 1;
      Widget vaccineDosesAgeInfo = Container(
        child: BulletItemList(
          items: ageOfVaccineDoses
              .map((txt) => Text.rich(TextSpan(
                    text: 'ครั้งที่ ${i++}: ',
                    children: [
                      TextSpan(text: txt),
                    ],
                  )))
              .toList(),
        ),
      );
      Container vaccineInfo = Container(
        padding: EdgeInsets.all(5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            header,
            vaccineDosesAgeInfo,
          ],
        ),
      );

      List<Container> vaccineDoseTableHeader = [];
      for (int i = 0; i < 3; i++) {
        vaccineDoseTableHeader.add(Container(
          padding: cellPadding,
          child: Center(child: Text('ครั้งที่ ${i + 1}')),
        ));
      }

      List<Widget> vaccineDoseDatePicker = [];
      final List<String> postfix = const ['first', 'second', 'third'];

      for (int i = 0; i < 3; i++) {
        String vaccineTarget = '$vaccineAbvName\_${postfix[i]}';
        if (vaccineRecordMap.containsKey(vaccineTarget)) {
          vaccineDoseDatePicker.add(DatePickerWrapper(
            initialDate: vaccineRecordMap[vaccineTarget],
            builder: (context, selectedDate) => Container(
              padding: cellPadding,
              child: Center(
                child: Text(
                  selectedDate == null
                      ? '-'
                      : '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                ),
              ),
            ),
            onDatePicked: (selected) {
              vaccineRecordMap[vaccineTarget] = selected;

              if (modifiedVaccineRecordMap == null)
                modifiedVaccineRecordMap = {};
              modifiedVaccineRecordMap![vaccineTarget] = selected;

              saveButtonDisabled.value = false;
            },
          ));
        } else {
          vaccineDoseDatePicker.add(Container(
            color: Colors.grey,
          ));
        }
      }

      Container vaccineRecordItem = Container(
        margin: first ? null : EdgeInsets.only(top: 24),
        child: PlainTable(
          children: [
            [
              vaccineInfo,
            ],
            [
              PlainTable(
                children: [
                  vaccineDoseTableHeader,
                  vaccineDoseDatePicker,
                ],
              ),
            ]
          ],
        ),
      );

      vaccineRecordWidgets.add(vaccineRecordItem);

      first = false;
    });

    ChangeNotifierProvider<BooleanNotifier> scaffoldBody =
        ChangeNotifierProvider.value(
      value: requesting,
      builder: (context, child) => Stack(
        children: [
          Consumer<BooleanNotifier>(
            builder: (context, _, child) => SingleChildScrollView(
              physics: _.value
                  ? NeverScrollableScrollPhysics()
                  : AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(10),
              child: Material(
                elevation: 8,
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: vaccineRecordWidgets,
                  ),
                ),
              ),
            ),
          ),
          Consumer<BooleanNotifier>(
            builder: (context, _, child) => Container(
              color: _.value ? Color(0x7DFFFFFF) : null,
              child: _.value
                  ? Center(
                      child: SimpleProgressIndicator(
                        size: ProgressIndicatorSize.large,
                      ),
                    )
                  : null,
            ),
          ),
        ],
      ),
    );

    ChangeNotifierProvider<BooleanNotifier> saveButton =
        ChangeNotifierProvider.value(
      value: saveButtonDisabled,
      builder: (context, child) => Consumer<BooleanNotifier>(
        builder: (context, _, child) => ElevatedButton.icon(
          icon: Icon(Icons.save, size: 24),
          label: Text('บันทึก'),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(
                _.value ? Colors.grey.shade400 : Colors.teal),
            textStyle:
                MaterialStateProperty.all<TextStyle>(TextStyle(fontSize: 24)),
            shape: MaterialStateProperty.all<OutlinedBorder>(StadiumBorder()),
          ),
          onPressed: _.value
              ? null
              : () async {
                  if (modifiedVaccineRecordMap == null) return;

                  _.value = true;
                  requesting.value = true;

                  try {
                    await VaccineRNCDatabaseWS.editRecord(
                      vaccineRecordId: initialVaccineRecord.id,
                      vaccineRecord: modifiedVaccineRecordMap!,
                    );

                    modifiedVaccineRecordMap = null;

                    MessageNotification.push(
                      context: _context,
                      message: 'บันทึกข้อมูลสำเร็จ',
                    );
                  } catch (e) {
                    if (e is NoAuthenticationKeyError) {
                      await Navigator.pushNamedAndRemoveUntil(
                        _context,
                        '/login',
                        (route) => false,
                      );
                      return;
                    }

                    if (e is UnauthorizedError) {
                      await Alert.unauthorized(context: _context);
                      Navigator.pushNamedAndRemoveUntil(
                          _context, '/login', (route) => false);
                      return;
                    }

                    if (e is RecordModifyingError || e is BadRequestError)
                      MessageNotification.badRequest(context: _context);

                    if (e is UnexpectedResponseError)
                      MessageNotification.unexpected(context: _context);

                    _.value = false;
                  } finally {
                    requesting.value = false;
                  }
                },
        ),
      ),
    );

    return Scaffold(
      body: scaffoldBody,
      floatingActionButton: saveButton,
    );
  }
}

class _RecordBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Patient? currentPatient;
    BooleanNotifier requesting = BooleanNotifier(false);
    VaccineRecordResult? record;

    Widget buildRecordEditor() => ChangeNotifierProvider.value(
          value: requesting,
          builder: (context, child) => Consumer<BooleanNotifier>(
            builder: (context, b, child) {
              if (b.value && currentPatient != null) {
                VaccineRNCDatabaseWS.viewRecord(
                  patientId: currentPatient!.id,
                ).then((r) {
                  record = r;
                }).catchError((error) async {
                  if (error is UnauthorizedError) {
                    await Alert.unauthorized(context: context);
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/login', (route) => false);
                    return;
                  }
                }).whenComplete(() {
                  b.value = false;
                });
                return Center(
                  child: SimpleProgressIndicator(
                    size: ProgressIndicatorSize.large,
                  ),
                );
              }

              if (record == null) {
                return Container(
                  child: Center(
                    child: currentPatient == null
                        ? null
                        : Text('ไม่มีบันทึกสำหรับรายชื่อนี้'),
                  ),
                );
              }

              return _VaccineRecordEditor(
                initialVaccineRecord: record!,
              );
            },
          ),
        );

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PatientSelector(
              onConfirmed: (v) {
                currentPatient = v;
                requesting.value = true;
              },
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: buildRecordEditor(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page widget instance of record section.
class Record extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageNotification.scaffold(
      appBar: AppBar(
        title: Text('บันทึกการรับวัคซีน'),
      ),
      body: _RecordBody(),
    );
  }
}
