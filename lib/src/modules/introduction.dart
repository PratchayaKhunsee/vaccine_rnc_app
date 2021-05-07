import 'package:flutter/material.dart';

Map<String, String> _intro = {
  'app':
      'เป็นแอปพลิเคชันสำหรับบันทึกการรับวัคซีนและออกใบรับรองการรับวัคซีน โดยถอกแบบมาจากสมุดสุขภาพแม่และเด็ก และสมุดรับรองการฉีดวัคซีนหรือการรับยาป้องกันโรค'
};

class Introduction extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            ExpansionTile(
              title: Text(
                'แอปพลิเคชันนี้คืออะไร?',
                textScaleFactor: 1.2,
                style: TextStyle(
                  // fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ListTile(
                  title: Text(_intro['app']),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
