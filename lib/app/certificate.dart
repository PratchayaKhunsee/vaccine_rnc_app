import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as PdfWidget;
import 'package:printing/printing.dart';

import '../src/js/js.dart';
import '../src/webservice/vaccine-rnc.dart';

import '_import.dart';
import '_widgets.dart';
import '_change_notifier.dart';

/// The shown text map of vaccination title.
final Map<String, String> _vaccineName = const {
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

/// The shown text of recommendation of age for vaccination.
final Map<String, String> _ageForVaccination = const {
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

/// Get the title text of vaccination with "vaccine_against" keyword.
String? _getVaccineAgainstTitle(String vaccineAgainst) {
  var entries = _vaccineName.entries;
  for (var e in entries) {
    if (vaccineAgainst.contains(RegExp("^${e.key}\_(first|second|third)\$"))) {
      return e.value;
    }
  }

  return null;
}

/// The instance of each certification information.
class _Certification {
  final int id;
  final String vaccineAgainst;
  String? vaccineName;
  String? vaccineManufacturer;
  String? vaccineBatchNumber;
  DateTime? certifyFrom;
  DateTime? certifyTo;
  Uint8List? clinicianSignature;
  String? clinicianProfStatus;
  Uint8List? administringCentreStamp;
  bool modified = false;
  _Certification({
    required this.id,
    required this.vaccineAgainst,
    this.vaccineManufacturer,
    this.vaccineName,
    this.vaccineBatchNumber,
    this.certifyFrom,
    this.certifyTo,
    this.clinicianProfStatus,
    this.clinicianSignature,
    this.administringCentreStamp,
  });
}

/// The instance that representing the whole certifcate of vaccination document.
class _Certificate {
  String? fullName;
  String? nationality;
  int sex = 0;
  String? againstDescription;
  Uint8List? signature;
  DateTime? dateOfBirth;
  List<_Certification> certificationList;

  _Certificate({
    this.fullName,
    this.nationality,
    this.sex = 0,
    this.againstDescription,
    this.signature,
    this.dateOfBirth,
    this.certificationList = const [],
  });
}

/// The main body of certification page.
class _CertificateBody extends StatelessWidget {
  Future<void> printAsPDF(CompletedVaccineCertificationResult cert) async {
    ByteData fontData =
        await rootBundle.load('assets/fonts/arial-unicode-ms.ttf');

    final ttf = PdfWidget.TtfFont(fontData);

    final pdf = PdfWidget.Document();

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
    PdfWidget.TextStyle textStyle = PdfWidget.TextStyle(
      font: ttf,
      fontSize: 8,
    );
    PdfWidget.TextStyle headingStyle = textStyle.merge(PdfWidget.TextStyle(
      fontWeight: PdfWidget.FontWeight.bold,
      fontSize: 14,
    ));
    PdfWidget.TextStyle subHeaderStyle = textStyle.merge(PdfWidget.TextStyle(
      fontSize: 10,
    ));
    PdfWidget.TextStyle tableHeaderStyle = textStyle.merge(PdfWidget.TextStyle(
      fontSize: 8,
      fontWeight: PdfWidget.FontWeight.bold,
    ));

    List<PdfWidget.Page> pages = [];

    PdfWidget.Container buildTableCell(PdfWidget.Widget widget) {
      return PdfWidget.Container(
        width: tableCellWidth,
        height: tableCellHeight,
        child: PdfWidget.Center(
          child: widget,
        ),
      );
    }

    PdfWidget.TableRow buildLeftPageTableHeader() {
      return PdfWidget.TableRow(
        children: [
          buildTableCell(PdfWidget.Text(
            'Vaccine or prophylaxis',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
          buildTableCell(PdfWidget.Text(
            'Date',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
          buildTableCell(PdfWidget.Text(
            'Signature and professional status of supervising clinician',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
        ],
      );
    }

    PdfWidget.TableRow buildRightPageTableHeader() {
      return PdfWidget.TableRow(
        children: [
          buildTableCell(PdfWidget.Text(
            'Manufacturer and batch no. of vaccine or prophylaxis',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
          buildTableCell(PdfWidget.Text(
            'Certificate valid\nfrom:\nuntil:',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
          buildTableCell(PdfWidget.Text(
            'Official stamp of the administering centre',
            textAlign: PdfWidget.TextAlign.center,
            style: tableHeaderStyle,
          )),
        ],
      );
    }

    PdfWidget.Widget buildCertificateHeader(bool onlyBlank) {
      PdfWidget.Container textFieldWithDottedLine(PdfWidget.Widget child) {
        return PdfWidget.Container(
          decoration: PdfWidget.BoxDecoration(
            border: PdfWidget.Border(
              bottom: PdfWidget.BorderSide(
                color: PdfColor(0, 0, 0),
                style: PdfWidget.BorderStyle.dotted,
              ),
            ),
          ),
          child: child,
        );
      }

      PdfWidget.Container buildBlankField() => PdfWidget.Container(height: 16);

      List<PdfWidget.Widget> buildColumn(List<PdfWidget.Widget> widgets) {
        List<PdfWidget.Widget> w = [];
        for (var e in widgets) {
          if (e != widgets.first) {
            w.add(
              PdfWidget.Padding(padding: PdfWidget.EdgeInsets.only(top: 2)),
            );
          }

          w.add(e);
        }
        return w;
      }

      List<PdfWidget.Widget> buildRow(List<PdfWidget.Widget> widgets) {
        List<PdfWidget.Widget> w = [];
        for (var e in widgets) {
          if (e != widgets.first) {
            w.add(
              PdfWidget.Padding(padding: PdfWidget.EdgeInsets.only(left: 2)),
            );
          }

          w.add(e);
        }
        return w;
      }

      var fullName = PdfWidget.Text(
        cert.fullName ?? '',
        style: textStyle,
      );

      var dateOfBirth = PdfWidget.Text(
        cert.dateOfBirth == null
            ? ''
            : '${cert.dateOfBirth!.day}/${cert.dateOfBirth!.month}/${cert.dateOfBirth!.year}',
        style: textStyle,
      );

      var sex = PdfWidget.Text(
        cert.sex == 1 ? 'Female' : 'Male',
        style: textStyle,
      );

      var signature = PdfWidget.Stack(
        overflow: PdfWidget.Overflow.visible,
        alignment: PdfWidget.Alignment.center,
        children: [
          PdfWidget.Positioned(
            child: PdfWidget.Container(
              constraints: PdfWidget.BoxConstraints(
                maxWidth: 64,
              ),
              child: PdfWidget.Image(
                PdfWidget.MemoryImage(
                  cert.signature!,
                ),
              ),
            ),
          ),
        ],
      );

      var againstDescription = PdfWidget.RichText(
        text: PdfWidget.TextSpan(
          text: cert.againstDescription ?? '',
          style: textStyle,
        ),
      );

      return PdfWidget.Column(
        children: buildColumn([
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Text(
                'This is to certify that [name]',
                style: textStyle,
              ),
            ]),
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true ? buildBlankField() : fullName,
                ),
              ),
            ]),
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Text(
                'date of birth',
                style: textStyle,
              ),
              PdfWidget.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true
                      ? buildBlankField()
                      : PdfWidget.Center(child: dateOfBirth),
                ),
              ),
              PdfWidget.Text(
                'sex',
                style: textStyle,
              ),
              PdfWidget.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true
                      ? buildBlankField()
                      : PdfWidget.Center(
                          child: sex,
                        ),
                ),
              ),
            ]),
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Text(
                'national identification document, if applicable',
                style: textStyle,
              ),
              PdfWidget.Expanded(
                child: textFieldWithDottedLine(buildBlankField()),
              ),
            ]),
          ),
          PdfWidget.Row(
            children: [
              PdfWidget.Text(
                'whose signature follows',
                style: textStyle,
              ),
              PdfWidget.Expanded(
                child: cert.signature == null
                    ? buildBlankField()
                    : textFieldWithDottedLine(
                        PdfWidget.Container(
                          constraints: PdfWidget.BoxConstraints(
                            maxHeight: 16,
                          ),
                          child: onlyBlank == true || cert.signature == null
                              ? null
                              : signature,
                        ),
                      ),
              ),
            ],
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Expanded(
                child: PdfWidget.RichText(
                  text: PdfWidget.TextSpan(
                    text:
                        'has on the date indicated been vaccinated or received prophylaxis against: (name of disease or condition)',
                    style: textStyle,
                  ),
                ),
              ),
            ]),
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Expanded(
                child: textFieldWithDottedLine(
                  onlyBlank == true ? buildBlankField() : againstDescription,
                ),
              ),
            ]),
          ),
          PdfWidget.Row(
            children: buildRow([
              PdfWidget.Expanded(
                child: PdfWidget.Text(
                  'in accordance with the International Health Regulations.',
                  style: textStyle,
                ),
              ),
            ]),
          ),
        ]),
      );
    }

    while (usedRows < cert.certificateList.length) {
      int currentUsedRows = firstPairPage ? 3 : 8;
      bool firstPair = firstPairPage;
      List<PdfWidget.TableRow> tableLeft = [
        buildLeftPageTableHeader(),
      ];
      List<PdfWidget.TableRow> tableRight = [
        buildRightPageTableHeader(),
      ];

      for (int i = 0; i < currentUsedRows; i++) {
        CertificationResult? certRow =
            usedRows + i >= cert.certificateList.length
                ? null
                : cert.certificateList[usedRows + i];

        var vaccineName = buildTableCell(
          PdfWidget.Text(
            certRow?.vaccineName ?? '',
            style: textStyle,
          ),
        );

        var date = buildTableCell(PdfWidget.Center(
          child: PdfWidget.Text(
            '',
            style: textStyle,
          ),
        ));

        var clinicianField = buildTableCell(PdfWidget.Stack(
          children: [
            PdfWidget.Align(
              alignment: PdfWidget.Alignment.center,
              child: certRow != null && certRow.clinicianSignature != null
                  ? PdfWidget.Image(PdfWidget.MemoryImage(
                      certRow.clinicianSignature!,
                    ))
                  : null,
            ),
            PdfWidget.Align(
              alignment: PdfWidget.Alignment.bottomCenter,
              child: PdfWidget.Text(
                certRow?.clinicianProfStatus ?? '',
                style: textStyle,
              ),
            ),
          ],
        ));

        var vaccineInfo = buildTableCell(PdfWidget.Column(
          crossAxisAlignment: PdfWidget.CrossAxisAlignment.start,
          mainAxisAlignment: PdfWidget.MainAxisAlignment.center,
          children: [
            PdfWidget.Text(
              certRow?.vaccineManufacturer ?? '',
              style: textStyle,
            ),
            PdfWidget.Text(
              certRow?.vaccineBatchNumber ?? '',
              style: textStyle,
            ),
          ],
        ));

        var certifyDuration = buildTableCell(PdfWidget.Column(
          crossAxisAlignment: PdfWidget.CrossAxisAlignment.center,
          mainAxisAlignment: PdfWidget.MainAxisAlignment.center,
          children: [
            PdfWidget.Text(
              certRow?.certifyFrom == null
                  ? ''
                  : 'From: ${certRow?.certifyFrom?.day}/${certRow?.certifyFrom?.month}/${certRow?.certifyFrom?.year}',
              style: textStyle,
            ),
            PdfWidget.Text(
              certRow?.certifyTo == null
                  ? ''
                  : 'To: ${certRow?.certifyTo?.day}/${certRow?.certifyTo?.month}/${certRow?.certifyTo?.year}',
              style: textStyle,
            ),
          ],
        ));

        var administringCentreStamp = buildTableCell(
          certRow?.administringCentreStamp != null
              ? PdfWidget.Image(PdfWidget.MemoryImage(
                  certRow!.administringCentreStamp!,
                ))
              : PdfWidget.Container(),
        );

        tableLeft.add(PdfWidget.TableRow(
          children: [
            vaccineName,
            date,
            clinicianField,
          ],
        ));
        tableRight.add(PdfWidget.TableRow(
          children: [
            vaccineInfo,
            certifyDuration,
            administringCentreStamp,
          ],
        ));
      }

      pages.add(PdfWidget.Page(
        pageFormat: format,
        build: (context) {
          if (!firstPair) {
            return PdfWidget.Container(
              alignment: PdfWidget.Alignment.bottomLeft,
              child: PdfWidget.Table(
                border: PdfWidget.TableBorder.all(
                  color: PdfColor(0, 0, 0),
                  width: 1,
                ),
                children: tableLeft,
              ),
            );
          }
          return PdfWidget.Container(
            child: PdfWidget.Column(
              children: [
                PdfWidget.RichText(
                  text: PdfWidget.TextSpan(
                    text:
                        'INTERNATIONAL CERTIFICATE OF VACCINATION OR PROPHYLAXIS',
                    style: headingStyle,
                  ),
                ),
                PdfWidget.Expanded(
                  flex: 2,
                  child: PdfWidget.Container(
                    child: PdfWidget.DefaultTextStyle(
                      style: subHeaderStyle,
                      child: buildCertificateHeader(false),
                    ),
                  ),
                ),
                PdfWidget.Table(
                  border: PdfWidget.TableBorder.all(
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
      pages.add(PdfWidget.Page(
        pageFormat: format,
        build: (context) {
          if (!firstPair) {
            return PdfWidget.Container(
              alignment: PdfWidget.Alignment.bottomLeft,
              child: PdfWidget.Table(
                border: PdfWidget.TableBorder.all(
                  color: PdfColor(0, 0, 0),
                  width: 1,
                ),
                children: tableRight,
              ),
            );
          }

          return PdfWidget.Container(
            child: PdfWidget.Column(
              children: [
                PdfWidget.Opacity(
                  opacity: .25,
                  child: PdfWidget.RichText(
                    text: PdfWidget.TextSpan(
                      text:
                          'INTERNATIONAL CERTIFICATE OF VACCINATION OR PROPHYLAXIS',
                      style: headingStyle,
                    ),
                  ),
                ),
                PdfWidget.Expanded(
                  flex: 2,
                  child: PdfWidget.Opacity(
                    opacity: .25,
                    child: PdfWidget.Container(
                      child: PdfWidget.DefaultTextStyle(
                        style: subHeaderStyle,
                        child: buildCertificateHeader(true),
                      ),
                    ),
                  ),
                ),
                PdfWidget.Expanded(
                  flex: 0,
                  child: PdfWidget.Table(
                    border: PdfWidget.TableBorder.all(
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

    Uint8List pdfBytes = await pdf.save();
    if (kIsWeb) {
      try {
        printBlob(pdfBytes, 'application/pdf',
            'certificate_of_vaccination_' + DateTime.now().toString());
      } catch (err) {
        print(err);
      }
    } else {
      await Printing.layoutPdf(
        name: 'certificate_of_vaccination_' + DateTime.now().toString(),
        onLayout: (format) => pdf.save(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Patient? currentPatient;
    _Certificate? cert;
    BooleanNotifier certificateRequesting = BooleanNotifier(false);
    BooleanNotifier formsDisabled = BooleanNotifier(false);
    BooleanNotifier saveButtonDisabled = BooleanNotifier(true);
    BooleanNotifier printButtonDisabled = BooleanNotifier(false);
    ValueNotifier<int> signatureId = ValueNotifier(0);

    void onSaveButtonPressed(BuildContext context) async {
      saveButtonDisabled.value =
          formsDisabled.value = printButtonDisabled.value = true;

      try {
        await VaccineRNCDatabaseWS.editCertificate(
          vaccinePatientId: currentPatient!.id,
          fullName: cert?.fullName,
          dateOfBirth: cert?.dateOfBirth,
          againstDescription: cert?.againstDescription,
          nationality: cert?.nationality,
          sex: cert?.sex,
          signature: cert?.signature,
          certificationList: cert?.certificationList
              .where((e) => e.modified)
              .map((e) => Certification(
                    id: e.id,
                    vaccineAgainst: e.vaccineAgainst,
                    certifyFrom: e.certifyFrom,
                    certifyTo: e.certifyTo,
                    vaccineName: e.vaccineName,
                    vaccineBatchNumber: e.vaccineBatchNumber,
                    vaccineManufacturer: e.vaccineManufacturer,
                    clinicianSignature: e.clinicianSignature,
                    clinicianProfStatus: e.clinicianProfStatus,
                    administringCentreStamp: e.administringCentreStamp,
                  ))
              .toList(),
        );
        saveButtonDisabled.value = true;

        MessageNotification.push(
          context: context,
          message: 'บันทึกข้อมูลสำเร็จ',
        );
      } catch (err) {
        if (err is NoAuthenticationKeyError) {
          await Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
          return;
        }

        if (err is UnauthorizedError) {
          await Alert.unauthorized(context: context);
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
          return;
        }

        if (err is RecordModifyingError || err is BadRequestError)
          MessageNotification.badRequest(context: context);

        if (err is UnexpectedResponseError)
          MessageNotification.unexpected(context: context);
        saveButtonDisabled.value = false;
      } finally {
        formsDisabled.value = printButtonDisabled.value = false;
      }
    }

    void onPrintButtonPressed() async {
      bool isSaveButtonDisabled = saveButtonDisabled.value;
      bool isFormsDisabled = formsDisabled.value;
      saveButtonDisabled.value =
          formsDisabled.value = printButtonDisabled.value = true;

      try {
        var c = await VaccineRNCDatabaseWS.getCompleteCertificate(
          patientId: currentPatient!.id,
        );

        await printAsPDF(c);
      } catch (err) {
        // print(err);
        // debugPrint('$err');
        printButtonDisabled.value = false;
      } finally {
        saveButtonDisabled.value = isSaveButtonDisabled;
        formsDisabled.value = isFormsDisabled;
        printButtonDisabled.value = false;
      }
    }

    void onAddCertificationButtonPressed() async {
      BooleanNotifier requesting = BooleanNotifier(true);
      List<String>? availableVaccineAgainst;
      Set<String> selectedVaccineDoses = Set<String>();
      BooleanNotifier createButtonDisabled = BooleanNotifier(true);

      void getAvailableVaccination() async {
        availableVaccineAgainst =
            await VaccineRNCDatabaseWS.getAvailableVaccination(
          vaccinePatientId: currentPatient!.id,
        );
        requesting.value = false;
      }

      Widget buildCertificateCreationPanel(BuildContext context) {
        void onCreateCertificateButtonPressed() async {
          requesting.value = true;

          try {
            await VaccineRNCDatabaseWS.createCertification(
              vaccinePatientId: currentPatient!.id,
              vaccineAgainstList: selectedVaccineDoses.map((e) => e).toList(),
            );

            Navigator.of(context).pop();
          } catch (error) {
            requesting.value = false;
          }
        }

        availableVaccineAgainst?.sort((a, b) => a.compareTo(b));
        List<String> vaccineAbvNames = [];
        availableVaccineAgainst?.forEach((e) {
          String name = e.replaceAll(RegExp("\_(first|second|third)\$"), "");
          if (!vaccineAbvNames.contains(name)) {
            vaccineAbvNames.add(name);
          }
        });

        var body = Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: vaccineAbvNames.map(
              (e) {
                List<Widget> children = [
                  ListTile(
                    title: Text(
                      '${_vaccineName[e]}',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ];

                availableVaccineAgainst?.forEach((s) {
                  if (s.contains(RegExp("^$e\_(first|second|third)\$"))) {
                    children.add(StatefulBuilder(
                      builder: (context, setState) => CheckboxListTile(
                        value: selectedVaccineDoses.contains(s),
                        contentPadding: EdgeInsets.fromLTRB(32, 0, 16, 0),
                        title: Text('อายุ ${_ageForVaccination[s]}'),
                        onChanged: (b) {
                          setState(() {
                            if (selectedVaccineDoses.contains(s)) {
                              selectedVaccineDoses.remove(s);
                            } else {
                              selectedVaccineDoses.add(s);
                            }
                          });
                          createButtonDisabled.value =
                              selectedVaccineDoses.isEmpty;
                        },
                      ),
                    ));
                  }
                });

                return Container(
                  child: Column(
                    children: children,
                  ),
                );
              },
            ).toList(),
          ),
        );

        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(bottom: 16),
                child: Text(
                  'โปรดเลือกรายการที่แสดง',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: ChangeNotifierProvider.value(
                        value: createButtonDisabled,
                        builder: (context, _) => Consumer<BooleanNotifier>(
                          builder: (context, b, _) => ElevatedButton.icon(
                            onPressed: b.value
                                ? null
                                : onCreateCertificateButtonPressed,
                            label: Text('สร้าง'),
                            icon: Icon(Icons.create),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }

      getAvailableVaccination();
      await VaccineRNCAppBottomSheet.showModal(
        context: context,
        builder: (context) => ChangeNotifierProvider.value(
          value: requesting,
          builder: (context, _) => Consumer<BooleanNotifier>(
            builder: (context, b, _) {
              if (b.value) {
                return Center(
                  child: SimpleProgressIndicator(
                    size: ProgressIndicatorSize.large,
                  ),
                );
              }

              if (availableVaccineAgainst == null) {
                return Center(child: Text('ไม่พบรายการ'));
              }
              return buildCertificateCreationPanel(context);
            },
          ),
        ),
      );
    }

    Widget afterFirst(
      Widget child, [
      bool isExpanded = false,
    ]) {
      Container c = Container(
        margin: EdgeInsets.only(left: 10),
        child: child,
      );
      return isExpanded ? Expanded(child: c) : c;
    }

    Widget buildVacCertificatePanel() {
      SingleChildScrollView createBody() {
        void signatureImageSelection() async {
          Uint8List? imageBytes =
              await showImagePickerBottomSheet(context: context);
          if (cert != null && imageBytes != null) {
            cert!.signature = imageBytes;
            signatureId.value += 1;
            saveButtonDisabled.value = false;
          }
        }

        TextStyle heading1 = TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        );

        TextStyle heading2 = TextStyle(
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
        );

        var fullName = Consumer<BooleanNotifier>(
          builder: (context, b, _) => SimpleTextField(
            disabled: b.value,
            value: cert!.fullName ?? '',
            onInput: (v) {
              cert!.fullName = v;
              saveButtonDisabled.value = false;
            },
          ),
        );

        var sex = Consumer<BooleanNotifier>(
          builder: (context, b, _) {
            int i = 0;
            return SimpleDropdownButton<int>(
              disabled: b.value,
              items: ['ชาย (Male)', 'หญิง (Female)']
                  .map<SimpleDropdownButtonItem<int>>(
                (text) {
                  int j = i++;
                  return SimpleDropdownButtonItem<int>(
                    text: text,
                    selected: j == cert!.sex,
                    value: j,
                  );
                },
              ).toList(),
              onChanged: (v) {
                cert!.sex = v!.value as int;
                saveButtonDisabled.value = false;
              },
            );
          },
        );

        var dateOfBirth = Consumer<BooleanNotifier>(
          builder: (context, b, _) => DatePickerWrapper(
            initialDate: cert!.dateOfBirth,
            firstDate: DateTime(1900),
            lastDate: DateTime.now(),
            onDatePicked: (selected) {
              cert!.dateOfBirth = selected;
              saveButtonDisabled.value = false;
            },
            builder: (context, selectedDate) => DummyTextField(
              placeholder: 'วันเกิด',
              value: selectedDate != null
                  ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                  : '',
            ),
          ),
        );

        var nationality = Consumer<BooleanNotifier>(
          builder: (context, b, _) => SimpleTextField(
            disabled: b.value,
            value: cert!.nationality ?? '',
            onInput: (v) {
              cert!.nationality = v;
              saveButtonDisabled.value = false;
            },
          ),
        );

        var againstDescription = Consumer<BooleanNotifier>(
          builder: (context, b, _) => SimpleTextField(
            disabled: b.value,
            value: cert!.againstDescription ?? '',
            onInput: (v) {
              cert!.againstDescription = v;
              saveButtonDisabled.value = false;
            },
          ),
        );

        var signature = Consumer<BooleanNotifier>(
          builder: (context, b, _) => InkWell(
            onTap: b.value ? null : signatureImageSelection,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    width: 2,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
              child: ChangeNotifierProvider<ValueNotifier<int>>.value(
                value: signatureId,
                builder: (context, _) => Consumer<ValueNotifier<int>>(
                  builder: (context, v, _) => Center(
                    child: cert!.signature != null
                        ? Image.memory(cert!.signature as Uint8List)
                        : null,
                  ),
                ),
              ),
            ),
          ),
        );

        var addCertificationButton = InkWell(
          onTap: onAddCertificationButtonPressed,
          child: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade400,
                style: BorderStyle.solid,
                width: 3,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text('เพิ่มการรับรองการรับวัคซีน'),
                Container(
                  margin: EdgeInsets.only(top: 8),
                  child: Icon(Icons.add_circle_outline_rounded),
                ),
              ],
            ),
          ),
        );

        Widget createCertificationEditingPanel(_Certification c) {
          bool requesting = false;
          bool retrieved = false;

          return StatefulBuilder(
            builder: (context, setState) {
              void onReloadButtonPressed() async {
                setState(() {
                  requesting = true;
                });
                try {
                  CertificationResult result =
                      await VaccineRNCDatabaseWS.viewEachCertification(
                    certificateId: c.id,
                    vaccinePatientId: currentPatient!.id,
                  );

                  c.vaccineName = result.vaccineName;
                  c.vaccineManufacturer = result.vaccineManufacturer;
                  c.vaccineBatchNumber = result.vaccineBatchNumber;
                  c.clinicianSignature = result.clinicianSignature;
                  c.clinicianProfStatus = result.clinicianProfStatus;
                  c.certifyFrom = result.certifyFrom;
                  c.certifyTo = result.certifyTo;
                  c.administringCentreStamp = result.administringCentreStamp;

                  retrieved = true;
                } catch (e) {
                } finally {
                  setState(() {
                    requesting = false;
                  });
                }
              }

              var reloadButton = Consumer<BooleanNotifier>(
                builder: (context, b, _) => ElevatedButton.icon(
                  icon: Icon(Icons.refresh),
                  label: Text('โหลดข้อมูล'),
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      StadiumBorder(),
                    ),
                  ),
                  onPressed: requesting || formsDisabled.value
                      ? null
                      : onReloadButtonPressed,
                ),
              );

              if (retrieved) {
                ValueNotifier<int> clinicianSignatureId = ValueNotifier(0);
                ValueNotifier<int> administringCentreStampId = ValueNotifier(0);

                void clinicianSignatureImageSelection() async {
                  Uint8List? imageBytes =
                      await showImagePickerBottomSheet(context: context);
                  if (cert != null && imageBytes != null) {
                    c.clinicianSignature = imageBytes;
                    clinicianSignatureId.value += 1;
                    c.modified = true;
                    saveButtonDisabled.value = false;
                  }
                }

                void administringCentreStampImageSelection() async {
                  Uint8List? imageBytes =
                      await showImagePickerBottomSheet(context: context);
                  if (cert != null && imageBytes != null) {
                    c.administringCentreStamp = imageBytes;
                    administringCentreStampId.value += 1;
                    c.modified = true;
                    saveButtonDisabled.value = false;
                  }
                }

                var vaccineName = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => SimpleTextField(
                    value: c.vaccineName ?? '',
                    placeholder: 'ชื่อวัคซีน',
                    disabled: requesting || formsDisabled.value,
                    onInput: (value) {
                      c.vaccineName = value;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                  ),
                );

                var vaccineBatchNumber = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => SimpleTextField(
                    value: c.vaccineBatchNumber ?? '',
                    placeholder: 'เลขที่ชุดของวัคซีน',
                    disabled: requesting || formsDisabled.value,
                    onInput: (value) {
                      c.vaccineBatchNumber = value;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                  ),
                );

                var vaccineManufacturer = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => SimpleTextField(
                    value: c.vaccineManufacturer,
                    placeholder: 'ชื่อบริษัทที่ผลิต',
                    disabled: requesting || b.value,
                    onInput: (value) {
                      c.vaccineManufacturer = value;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                  ),
                );

                var certifyFrom = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => DatePickerWrapper(
                    initialDate: c.certifyFrom,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    onDatePicked: (selected) {
                      c.certifyFrom = selected;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                    builder: (context, selectedDate) => DummyTextField(
                      placeholder: 'วันเริ่มต้น',
                      value: selectedDate != null
                          ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : '',
                    ),
                  ),
                );

                var certifyTo = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => DatePickerWrapper(
                    initialDate: c.certifyTo,
                    firstDate: DateTime(1900),
                    lastDate: DateTime(2100),
                    onDatePicked: (selected) {
                      c.certifyTo = selected;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                    builder: (context, selectedDate) => DummyTextField(
                      placeholder: 'วันสิ้นสุด',
                      value: selectedDate != null
                          ? '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}'
                          : '',
                    ),
                  ),
                );

                var clinicianSignature = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => InkWell(
                    onTap: b.value ? null : clinicianSignatureImageSelection,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 32,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: ChangeNotifierProvider<ValueNotifier<int>>.value(
                        value: clinicianSignatureId,
                        builder: (context, _) => Consumer<ValueNotifier<int>>(
                          builder: (context, v, _) => Center(
                            child: c.clinicianSignature != null
                                ? Image.memory(
                                    c.clinicianSignature as Uint8List)
                                : Text(
                                    'ลายเซ็น',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                var clinicianProfStatus = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => SimpleTextField(
                    value: c.clinicianProfStatus,
                    placeholder: 'ตำแหน่งผู้รับรอง',
                    disabled: requesting || formsDisabled.value,
                    onInput: (value) {
                      c.clinicianProfStatus = value;
                      c.modified = true;
                      saveButtonDisabled.value = false;
                    },
                  ),
                );

                var administringCentreStamp = Consumer<BooleanNotifier>(
                  builder: (context, b, _) => InkWell(
                    onTap:
                        b.value ? null : administringCentreStampImageSelection,
                    child: Container(
                      constraints: BoxConstraints(
                        minHeight: 32,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            width: 2,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                      child: ChangeNotifierProvider<ValueNotifier<int>>.value(
                        value: administringCentreStampId,
                        builder: (context, _) => Consumer<ValueNotifier<int>>(
                          builder: (context, v, _) => Center(
                            child: c.administringCentreStamp != null
                                ? Image.memory(
                                    c.administringCentreStamp as Uint8List)
                                : Text(
                                    'ตราประทับ',
                                    style: TextStyle(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );

                return ChangeNotifierProvider.value(
                  value: formsDisabled,
                  builder: (context, _) {
                    var w = Container(
                      padding: EdgeInsets.all(8),
                      child: SimpleLayout(
                        lines: [
                          Line(
                            child: SimpleLayout(
                              lines: [
                                Line(
                                  child: Text(
                                    'ข้อมูลวัคซืน',
                                    style: heading2,
                                  ),
                                ),
                                Line(
                                  child: ResponsiveBuilder(
                                    builder: (context, properties) {
                                      if (properties.screenType ==
                                          DeviceScreenType.mobile) {
                                        return Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              vaccineName,
                                              Container(
                                                margin:
                                                    EdgeInsets.only(top: 10),
                                                child: vaccineBatchNumber,
                                              ),
                                            ],
                                          ),
                                        );
                                      }

                                      return Row(
                                        children: [
                                          Expanded(child: vaccineName),
                                          afterFirst(vaccineBatchNumber, true),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                                Line(
                                  child: vaccineManufacturer,
                                  nextLineSpacing: 16,
                                ),
                                Line(
                                  child: Text(
                                    'ระยะเวลาการรับรองการป้องกันโรค',
                                    style: heading2,
                                  ),
                                ),
                                Line(
                                  child: Row(
                                    children: [
                                      Text('จาก'),
                                      afterFirst(certifyFrom, true),
                                      afterFirst(Text('ถึง')),
                                      afterFirst(certifyTo, true),
                                    ],
                                  ),
                                  nextLineSpacing: 16,
                                ),
                                Line(
                                  child: Text(
                                    'ผู้รับรอง',
                                    style: heading2,
                                  ),
                                ),
                                Line(
                                  child: clinicianSignature,
                                ),
                                Line(
                                  child: clinicianProfStatus,
                                  nextLineSpacing: 16,
                                ),
                                Line(
                                  child: Text(
                                    'ตราประทับศูนย์รับรอง',
                                    style: heading2,
                                  ),
                                ),
                                Line(
                                  child: administringCentreStamp,
                                ),
                              ],
                            ),
                          ),
                          Line(
                            child: Center(
                              child: reloadButton,
                            ),
                          ),
                        ],
                      ),
                    );

                    if (requesting) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          w,
                          Container(
                            constraints: BoxConstraints.expand(),
                            color: Color(0xa0FFFFFF),
                            child: Center(
                              child: SimpleProgressIndicator(
                                size: ProgressIndicatorSize.large,
                              ),
                            ),
                          ),
                        ],
                      );
                    }
                    return w;
                  },
                );
              }

              var reloadButtonWrapped = ChangeNotifierProvider.value(
                value: formsDisabled,
                builder: (context, child) => reloadButton,
              );

              if (requesting) {
                return Container(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.all(10),
                        child: SimpleProgressIndicator(
                          size: ProgressIndicatorSize.large,
                        ),
                      ),
                      reloadButtonWrapped,
                    ],
                  ),
                );
              }

              return Container(
                padding: EdgeInsets.all(10),
                child: Center(
                  child: reloadButtonWrapped,
                ),
              );
            },
          );
        }

        return SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.fromLTRB(10, 10, 10, 96),
            child: Material(
              elevation: 10,
              child: Container(
                padding: EdgeInsets.all(10),
                child: ChangeNotifierProvider.value(
                  value: formsDisabled,
                  builder: (context, _) => SimpleLayout(
                    lines: [
                      Line(
                        child: Text(
                          "(กรุณากรอกข้อมูลดังต่อไปนี้เป็นภาษาอังกฤษ)",
                          style: TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      Line(
                        child: Row(
                          children: [
                            Text('ชื่อ-นามสกุล'),
                            afterFirst(fullName, true),
                          ],
                        ),
                      ),
                      Line(
                        child: Row(
                          children: [
                            Text('เพศ'),
                            afterFirst(sex),
                            afterFirst(Text('วันเดือนปีเกิด')),
                            afterFirst(dateOfBirth, true),
                          ],
                        ),
                      ),
                      Line(
                        child: Row(
                          children: [
                            Text('สัญชาติ'),
                            afterFirst(nationality, true),
                          ],
                        ),
                      ),
                      Line(
                        child: Text('ลายเซ็นผู้ถือ'),
                      ),
                      Line(
                        child: signature,
                      ),
                      Line(
                        child: Text('เอกสารนี้ครอคลุมการป้องกันโรคดังต่อไปนี้'),
                      ),
                      Line(
                        nextLineSpacing: 20,
                        child: againstDescription,
                      ),
                      Line(
                        child: Row(
                          children: [
                            Expanded(child: addCertificationButton),
                          ],
                        ),
                      ),
                      Line(
                        child: PlainTable(
                          children: cert!.certificationList
                              .map(
                                (e) => <Widget>[
                                  PlainTable(
                                    children: [
                                      [
                                        Container(
                                          padding: EdgeInsets.all(8),
                                          child: Text(
                                            '${_getVaccineAgainstTitle(e.vaccineAgainst)} [อายุ ${_ageForVaccination[e.vaccineAgainst]}]',
                                            style: heading1,
                                          ),
                                        ),
                                      ],
                                      [
                                        createCertificationEditingPanel(e),
                                      ],
                                    ],
                                  ),
                                ],
                              )
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }

      Column createButtons() {
        ChangeNotifierProvider<BooleanNotifier> saveButton =
            ChangeNotifierProvider.value(
          value: saveButtonDisabled,
          builder: (context, _) => Consumer<BooleanNotifier>(
            builder: (context, b, _) => ElevatedButton.icon(
              icon: Icon(Icons.save),
              label: Text('บันทึก'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  b.value ? Colors.grey.shade50 : Colors.teal,
                ),
                textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 24)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  StadiumBorder(),
                ),
              ),
              onPressed: b.value ? null : () => onSaveButtonPressed(context),
            ),
          ),
        );

        ChangeNotifierProvider<BooleanNotifier> printButton =
            ChangeNotifierProvider.value(
          value: printButtonDisabled,
          builder: (context, _) => Consumer<BooleanNotifier>(
            builder: (context, b, _) => ElevatedButton.icon(
              icon: Icon(Icons.print),
              label: Text('พิมพ์'),
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                  b.value ? Colors.grey.shade50 : Colors.yellow.shade700,
                ),
                textStyle: MaterialStateProperty.all<TextStyle>(
                    TextStyle(fontSize: 24)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                  StadiumBorder(),
                ),
              ),
              onPressed: b.value ? null : onPrintButtonPressed,
            ),
          ),
        );

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            saveButton,
            Container(
              margin: EdgeInsets.only(top: 10),
              child: printButton,
            ),
          ],
        );
      }

      return ChangeNotifierProvider.value(
        value: certificateRequesting,
        builder: (context, _) => Consumer<BooleanNotifier>(
          builder: (context, v, _) {
            if (v.value) {
              VaccineRNCDatabaseWS.viewCertificate(
                patientId: currentPatient!.id,
              ).then((v) {
                cert = _Certificate(
                  fullName: v.fullName,
                  nationality: v.nationality,
                  againstDescription: v.againstDescription,
                  sex: v.sex,
                  signature: v.signature,
                  dateOfBirth: v.dateOfBirth,
                  certificationList: v.certificateList
                      .map<_Certification>(
                        (e) => _Certification(
                          id: e.id,
                          vaccineAgainst: e.vaccineAgainst,
                        ),
                      )
                      .toList(),
                );
              }).whenComplete(() {
                certificateRequesting.value = false;
                printButtonDisabled.value = false;
                saveButtonDisabled.value = true;
              });

              return Center(
                child: SimpleProgressIndicator(
                  size: ProgressIndicatorSize.large,
                ),
              );
            }

            if (cert == null) {
              return Container();
            }

            return Scaffold(
              body: createBody(),
              floatingActionButton: createButtons(),
            );
          },
        ),
      );
    }

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
                certificateRequesting.value = true;
              },
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.only(top: 10),
                child: buildVacCertificatePanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Certificate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageNotification.scaffold(
      appBar: AppBar(
        title: Text('ใบรับรองการรับวัคซีน'),
      ),
      body: _CertificateBody(),
    );
  }
}
