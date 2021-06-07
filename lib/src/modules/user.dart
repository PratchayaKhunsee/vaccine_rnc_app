import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as Http;
import '_base.dart';
import '../layout/generic.dart';
import '../widget/input.dart';
import '../widget/select.dart';
import '../../global.dart' as global;

Future<bool> _editUserInfo(Map<String, dynamic> userInfo) async {
  String jwt = await global.Authorization.get();
  Http.Response res = await Http.post(
    global.VaccineDatabaseSource.uri('/user/account/edit'),
    headers: {
      'Authorization': jwt,
      'Content-Type': 'application/json',
    },
    body: json.encode(userInfo),
  );

  if (res.statusCode != 200) {
    throw res.statusCode;
  }

  return true;
}

void _logout(BuildContext context) async {
  await global.Authorization.delete();
  await (await global.LocalStorage.instance()).clear();
  Navigator.pushNamedAndRemoveUntil(
    context,
    '/login',
    (route) => false,
  );
}

class _UserInfoSectionState extends State<_UserInfoSection> {
  Map<String, dynamic> _data = {
    'disabled': true,
    'loaded': false,
    'patching': false,
    'old_values': {
      'firstname': '',
      'lastname': '',
      // 'id_number': '',
      'name_prefix': 0,
      'gender': 0,
    },
    'firstname': '',
    'lastname': '',
    // 'id_number': '',
    'name_prefix': 0,
    'gender': 0,
  };

  @override
  void initState() {
    super.initState();
    global.VaccineDatabaseSource.getUserInfo().then((value) {
      this.setState(() {
        this._data.addAll(value);
        this._data['loaded'] = true;
      });
    }).catchError((error) async {
      await showDialog(
        context: this.context,
        builder: (context) {
          return AlertDialog(
            title: Text('เกิดข้อผิดพลาด'),
            content: Text('ไม่พบข้อมูลของผู้ใช้นี้'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('ตกลง'),
              ),
            ],
          );
        },
      );
      this.setState(() {
        this._data['loaded'] = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      [
        [
          {
            'widget': Text(
              'ข้อมูลส่วนตัว',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            'flex': 0,
            'spacingOnNext': {
              'size': 5,
            },
          },
          /* Edit Button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.edit),
                visible: this._data['disabled'] &&
                    this._data['loaded'] &&
                    !this._data['patching'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();

                this.setState(() {
                  this._data['disabled'] = false;
                  this._data['old_values'] = {
                    'firstname': this._data['firstname'],
                    'lastname': this._data['lastname'],
                    // 'id_number': this._data['id_number'],
                    'name_prefix': this._data['name_prefix'],
                    'gender': this._data['gender'],
                  };
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': false,
          },
          /* Save button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.save),
                visible: !this._data['disabled'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();

                this.setState(() {
                  this._data['disabled'] = true;
                  this._data['patching'] = true;
                });

                global.VaccineDatabaseSource.updateUserInfo({
                  'firstname': this._data['firstname'],
                  'lastname': this._data['lastname'],
                  // 'id_number': this._data['id_number'],
                  'name_prefix': this._data['name_prefix'],
                  'gender': this._data['gender'],
                }).then((value) {
                  this.setState(() {
                    this._data['disabled'] = true;
                    this._data['patching'] = false;
                    this._data.addAll(value);
                  });
                }).catchError((error) async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('เกิดข้อผิดพลาด'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('ตกลง'),
                        ),
                      ],
                    ),
                  ).whenComplete(() {
                    this.setState(() {
                      this._data['disabled'] = true;
                      this._data['patching'] = false;
                    });
                  });
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': false
          },
          /* Close Button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.close),
                visible: !this._data['disabled'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                this.setState(() {
                  this._data['disabled'] = true;
                  this._data.addAll(this._data['old_values']);
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': {
              'size': 5,
              'needed': this._data['patching'],
            },
          },
          /* Circular indicator when patching user infomation */
          {
            'widget': Visibility(
              visible: this._data['patching'] || !this._data['loaded'],
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
            ),
            'flex': 0
          },
        ],
        [
          {
            'widget': Select(
              [
                {'text': 'นาย', 'value': 0},
                {'text': 'นาง', 'value': 1},
                {'text': 'นางสาว', 'value': 2},
                {'text': 'เด็กชาย', 'value': 3},
                {'text': 'เด็กหญิง', 'value': 4},
              ],
              disabled: this._data['disabled'],
              value: this._data['name_prefix'],
              onChanged: (value) {
                this._data['name_prefix'] = value;
              },
            ),
            'flex': 0,
          },
          Input(
            placeholder: 'ชื่อ',
            disabled: this._data['disabled'],
            value: this._data['firstname'],
            onChanged: (value) {
              this._data['firstname'] = value;
            },
          ),
        ],
        Input(
          placeholder: 'นามสกุล',
          disabled: this._data['disabled'],
          value: this._data['lastname'],
          onChanged: (value) {
            this._data['lastname'] = value;
          },
        ),
        // Input(
        //   placeholder: 'เลขประจำตัวประชาชน',
        //   disabled: true,
        //   value: this._data['id_number'],
        //   onChanged: (value) {
        //     this._data['id_number'] = value;
        //   },
        // ),
        [
          {
            'widget': Text('เพศ'),
            'flex': 0,
          },
          {
            'widget': Select(
              [
                {'text': 'ชาย', 'value': 0},
                {'text': 'หญิง', 'value': 1},
              ],
              disabled: this._data['disabled'],
              value: this._data['gender'],
              onChanged: (value) {
                this._data['gender'] = value;
              },
            ),
            'flex': 0,
          }
        ],
      ],
    );
  }
}

///
class _UserInfoSection extends StatefulWidget {
  @override
  _UserInfoSectionState createState() {
    return _UserInfoSectionState();
  }
}

class _UserAccountSectionState extends State<_UserAccountSection> {
  Map<String, dynamic> _data = {
    'password_section': {
      'disabled': true,
      'patching': false,
      'old_values': {
        'old': '',
        'new': '',
      },
      'old': '',
      'new': '',
    },
  };

  @override
  Widget build(BuildContext context) {
    return GenericLayout(
      [
        Text(
          'บัญชีผู้ใช้',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        [
          {
            'widget': Text(
              'แก้ไขรหัสผ่าน',
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            'flex': 0,
          },
          /* Edit Button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.edit),
                visible: this._data['password_section']['disabled'] &&
                    !this._data['password_section']['patching'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                this.setState(() {
                  this._data['password_section']['disabled'] = false;
                  this._data['password_section']['old_values'] = {
                    'old': this._data['password_section']['old'],
                    'new': this._data['password_section']['new'],
                  };
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': false,
          },
          /* Save button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.save),
                visible: !this._data['password_section']['disabled'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                this.setState(() {
                  this._data['password_section']['disabled'] = true;
                  this._data['password_section']['patching'] = true;
                });

                _editUserInfo({
                  'old': this._data['password_section']['old'],
                  'new': this._data['password_section']['new'],
                }).then((value) {
                  this.setState(() {
                    this._data['password_section']['disabled'] = true;
                    this._data['password_section']['patching'] = false;
                  });
                }).catchError((error) async {
                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('เกิดข้อผิดพลาด'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('ตกลง'),
                        ),
                      ],
                    ),
                  ).whenComplete(() {
                    this.setState(() {
                      this._data['password_section']['disabled'] = true;
                      this._data['password_section']['patching'] = false;
                    });
                  });
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': false
          },
          /* Close Button */
          {
            'widget': GestureDetector(
              child: Visibility(
                child: Icon(Icons.close),
                visible: !this._data['password_section']['disabled'],
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                this.setState(() {
                  this._data['password_section']['disabled'] = true;
                  this
                      ._data
                      .addAll(this._data['password_section']['old_values']);
                });
              },
            ),
            'flex': 0,
            'spacingOnNext': {
              'size': 5,
              'needed': this._data['password_section']['patching'],
            },
          },
          /* Circular indicator when patching user infomation */
          {
            'widget': Visibility(
              visible: this._data['password_section']['patching'],
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                ),
              ),
            ),
            'flex': 0,
          },
        ],
        Input(
          placeholder: 'รหัสผ่านเดิม',
          type: 'password',
          disabled: this._data['password_section']['disabled'],
          value: this._data['password_section']['old'],
          onChanged: (value) {
            this._data['password_section']['old'] = value;
          },
        ),
        Input(
          placeholder: 'รหัสผ่านใหม่',
          type: 'password',
          disabled: this._data['password_section']['disabled'],
          value: this._data['password_section']['new'],
          onChanged: (value) {
            this._data['password_section']['new'] = value;
          },
        ),
      ],
    );
  }
}

class _UserAccountSection extends StatefulWidget {
  @override
  _UserAccountSectionState createState() => _UserAccountSectionState();
}

/// User page as a module.
class User extends Module {
  @override
  Widget createWidget(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('บัญชีผู้ใช้'),
      ),
      body: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: GenericLayout(
              [
                {
                  'widget': _UserInfoSection(),
                  'spacingOnNext': {
                    'size': 20,
                  },
                },
                {
                  'widget': _UserAccountSection(),
                  'spacingOnNext': {
                    'size': 20,
                  }
                },
                ElevatedButton(
                  child: Text('ออกจากระบบ'),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) => AlertDialog(
                        title: Text('ออกจากระบบ'),
                        content: Text('คุณต้องการออกจากระบบหรือไม่'),
                        actions: [
                          TextButton(
                            child: Text('ยกเลิก'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('ตกลง'),
                            onPressed: () {
                              _logout(context);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
