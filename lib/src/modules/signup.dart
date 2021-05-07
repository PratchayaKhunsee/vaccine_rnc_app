import 'dart:convert';
import 'package:flutter/material.dart';
import '../widget/selectbutton.dart';
import '_base.dart';
import 'package:http/http.dart' as Http;
import '../../global.dart' as global;

class _SignUpState extends State<_SignUpStateful> {
  Future<Http.Response> signUp() {
    return Http.post(
      global.url + '/signup',
      body: json.encode(this.widget.baseWidget.data.toMap()),
      headers: {
        'Content-Type': 'application/json',
      },
    );
  }

  Future _createDialog(bool signUpSuccessful) {
    return showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title:
            Text(signUpSuccessful ? 'สมัครสมาชิกได้สำเร็จ' : 'เกิดข้อผิดพลาด'),
      ),
    );
  }

  SignUpData get data => this.widget.baseWidget.data;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('สมัครชื่อผู้ใช้งาน'),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(20),
            child: Form(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ข้อมูลส่วนตัว',
                    style: TextStyle(fontSize: 24),
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 0,
                        child: SelectButton(
                          [
                            SelectOption(text: 'นาย', value: 0),
                            SelectOption(text: 'นาง', value: 1),
                            SelectOption(text: 'นางสาว', value: 2),
                            SelectOption(text: 'เด็กชาย', value: 3),
                            SelectOption(text: 'เด็กหญิง', value: 4),
                          ],
                          onChangedd: (value) {
                            this.data.namePrefix = value;
                          },
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'ชื่อ',
                          ),
                          onChanged: (value) {
                            this.data.firstName = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: InputDecoration(
                            hintText: 'นามสกุล',
                          ),
                          onChanged: (value) {
                            this.data.lastName = value;
                          },
                        ),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'เลขประจำตัวประชาชน',
                    ),
                    onChanged: (value) {
                      this.data.idNumber = value;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('เพศ'),
                      Padding(
                        padding: EdgeInsets.all(5),
                      ),
                      Expanded(
                        flex: 0,
                        child: SelectButton(
                          [
                            SelectOption(text: 'ชาย', value: 0),
                            SelectOption(text: 'หญิง', value: 1),
                          ],
                          onChangedd: (value) {
                            this.data.gender = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  Text(
                    'บัญชีใช้งาน',
                    style: TextStyle(fontSize: 24),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'ชื่อผู้ใช้งาน',
                    ),
                    onChanged: (value) {
                      this.data.username = value;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(5),
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: 'รหัสผ่าน',
                    ),
                    obscureText: true,
                    onChanged: (value) {
                      this.data.password = value;
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(20),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      child: Text('สมัครบัญชีผู้ใช้งาน'),
                      onPressed: () async {
                        Http.Response res = await this.signUp();
                        switch (res.statusCode) {
                          case 200:
                            this._createDialog(true);
                            break;
                          default:
                            this._createDialog(false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignUpStateful extends BaseStatefulWidget<SignUp> {
  _SignUpStateful(SignUp parent) : super(parent);

  @override
  _SignUpState createState() {
    return _SignUpState();
  }
}

class SignUpData extends Data {
  String firstName = '';
  String lastName = '';
  String username = '';
  String password = '';
  String idNumber = '';
  int gender = 0;
  int namePrefix = 0;

  Map toMap() {
    return {
      'firstName': this.firstName,
      'lastName': this.lastName,
      'idNumber': this.idNumber,
      'gender': this.gender,
      'namePrefix': this.namePrefix,
      'username': this.username,
      'password': this.password
    };
  }
}

class SignUp extends BaseWidget<_SignUpState, SignUpData> {
  SignUp() : super(SignUpData());

  @override
  Widget build(BuildContext context) {
    return _SignUpStateful(this);
  }
}
