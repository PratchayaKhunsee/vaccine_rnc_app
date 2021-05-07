import 'package:flutter/material.dart';
// import '../../src/widget/test/subject.dart';
import '_appdrawer.dart';

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
          return false;
        }

        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('ออกจากแอปพลิเคชั่น'),
            actions: [
              TextButton(
                child: Text('ยกเลิก'),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
              TextButton(
                child: Text('ตกลง'),
                onPressed: () {
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
      },
      child: Scaffold(
        drawer: BaseAppDrawer(),
        appBar: AppBar(
          title: Text('หน้าแรก'),
        ),
        body: ListView(
          children: [
            Container(
              padding: EdgeInsets.all(15),
              // child: TestSubject(),
            ),
          ],
        ),
      ),
    );
  }
}
