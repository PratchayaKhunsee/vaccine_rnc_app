import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import '../layout/generic.dart';
import '../widget/input.dart';
import '../../global.dart' as global;
import '_base.dart';

Future<Http.Response> logIn(String username, String password) {
  return Http.post(
    global.url + '/login',
    body: json.encode(
      {
        'username': username,
        'password': password,
      },
    ),
    headers: {
      'Content-Type': 'application/json',
    },
  );
}

class _LoginFormSectionState extends State<_LoginFormSection> {
  Map<String, dynamic> _data = {
    'username': '',
    'password': '',
    'requesting': false,
  };

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'เข้าสู่ระบบ',
              style: TextStyle(
                fontSize: 36,
              ),
            ),
          ],
        ),
        Input(
          value: this._data['username'],
          placeholder: 'ชื่อผู้ใช้',
          disabled: this._data['requesting'],
          onChanged: (value) {
            this._data['username'] = value;
          },
        ),
        Input(
          value: this._data['password'],
          placeholder: 'รหัสผ่าน',
          type: 'password',
          disabled: this._data['requesting'],
          onChanged: (value) {
            this._data['password'] = value;
          },
        ),
        {
          'widget': ElevatedButton(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('ยืนยัน'),
                Padding(
                  padding: EdgeInsets.only(left: 5),
                ),
                Visibility(
                  visible: this._data['requesting'],
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () async {
              this.setState(() {
                this._data['requesting'] = true;
              });

              var res =
                  await logIn(this._data['username'], this._data['password']);
              switch (res.statusCode) {
                case 200:
                  Map<String, dynamic> body = json.decode(res.body);
                  await global.Authorization.put(body['token']);
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (route) => false);
                  break;
                case 404:
                default:
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: Text('เกิดข้อผิดพลาด'),
                      content: Text('ชื่อผู้ใช้หรือรหัสผ่านไม่ถูกต้อง'),
                      actions: [
                        TextButton(
                          child: Text('ปิด'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
              }

              this.setState(() {
                this._data['requesting'] = false;
              });
            },
          ),
          'spacingOnNext': {
            'size': 20,
          }
        },
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/signup');
              },
              child: Text('สมัครบัญชีผู้ใช้งานได้ที่นี่'),
            ),
          ],
        ),
      ],
    );
  }
}

class _LoginFormSection extends StatefulWidget {
  @override
  _LoginFormSectionState createState() => _LoginFormSectionState();
}

class Login extends Module {
  @override
  Widget createWidget(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.all(20),
              child: _LoginFormSection(),
            ),
          ],
        ),
      ),
    );
  }
}
