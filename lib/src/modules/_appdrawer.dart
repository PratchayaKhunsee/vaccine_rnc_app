import 'package:flutter/material.dart';

class BaseAppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Container(),
          ),
          ListTile(
            title: Text('บันทึกการรับวัคซีน'),
            onTap: () {
              Navigator.pushNamed(context, '/records');
            },
          ),
          ListTile(
            title: Text('ใบรับรองการรับวัคซีน'),
            onTap: () {
              Navigator.pushNamed(context, '/certificate');
            },
          ),
          ListTile(
            title: Text('ดูแลบันทึกการรับวัคซีน'),
            onTap: () {
              Navigator.pushNamed(context, '/parenting');
            },
          ),
          ListTile(
            title: Text('บัญชีผู้ใช้'),
            onTap: () {
              Navigator.pushNamed(context, '/user');
            },
          ),
          ListTile(
            title: Text('แนะนำแอปพลิเคชัน'),
            onTap: () {
              Navigator.pushNamed(context, '/intro');
            },
          ),
        ],
      ),
    );
  }
}
