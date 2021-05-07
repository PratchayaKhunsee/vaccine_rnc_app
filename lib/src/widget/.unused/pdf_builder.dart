import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PDFBuilder extends StatelessWidget {
  final pdf = pw.Document();

  @override
  Widget build(BuildContext context) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Text('Hello World'),
          ); // Center
        },
      ),
    );

    return Scaffold();
    // return pdf;
  }
}
