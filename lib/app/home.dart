import 'package:flutter/material.dart';

import '_import.dart';

class Home extends StatelessWidget {
  ///
  void _route(BuildContext context, String routeName) async {
    await Navigator.pushNamed(context, routeName);
  }

  /// Widget: A side menu.
  Widget _buildAppDrawer(BuildContext context) {
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
            leading: Icon(Icons.book),
            title: Text('บันทึกการรับวัคซีน'),
            onTap: () {
              _route(context, '/record');
            },
          ),
          ListTile(
            leading: Icon(Icons.check_circle_outline),
            title: Text('ใบรับรองการรับวัคซีน'),
            onTap: () {
              _route(context, '/certificate');
            },
          ),
          ListTile(
            leading: Icon(Icons.people_sharp),
            title: Text('รายชื่อผูกบันทึก/ใบรับรอง'),
            onTap: () {
              _route(context, '/parenting');
            },
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('บัญชีผู้ใช้'),
            onTap: () {
              _route(context, '/user');
            },
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('หน้าแรก'),
    );
  }

  Widget _buildPageSelection(
    BuildContext context,
    DeviceScreenProperties properties,
  ) {
    List<Widget> bookItems = [
      _buildBookSelectionButton(
        context: context,
        image: Image.asset('assets/images/book1.jpg'),
        title: 'บันทึกการรับวัคซีน',
        onTap: () {
          _route(context, '/record');
        },
      ),
      _buildBookSelectionButton(
        context: context,
        image: Image.asset('assets/images/book2.jpg'),
        title: 'ใบรับรองการรับวัคซีน',
        onTap: () {
          _route(context, '/certificate');
        },
      )
    ];

    return ListView(
      padding: EdgeInsets.all(10),
      children: bookItems
          .map(
            (e) => Container(
              margin: EdgeInsets.only(bottom: 10),
              child: e,
            ),
          )
          .toList(),
    );
  }

  Widget _buildBookSelectionButton({
    required BuildContext context,
    required Image image,
    required String title,
    required void Function() onTap,
  }) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10),
          constraints: BoxConstraints(maxHeight: 160),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  title,
                  textScaleFactor: MediaQuery.of(context).textScaleFactor,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: image,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      builder: (
        BuildContext context,
        DeviceScreenProperties properties,
      ) {
        return Scaffold(
          appBar: _buildAppBar(context),
          drawer: _buildAppDrawer(context),
          body: Center(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      'เลือกเมนูที่คุณต้องการ',
                      textScaleFactor: MediaQuery.textScaleFactorOf(context),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.transparent,
                      child: _buildPageSelection(context, properties),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
