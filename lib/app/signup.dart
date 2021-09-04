import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:vaccine_records_and_certs/modules/_change_notifier.dart';

import '_import.dart';
import '_change_notifier.dart';

class _SignUpButtonState extends BooleanNotifier {
  _SignUpButtonState({
    bool disabled = true,
  }) : super(disabled);
  bool get disabled => value;
  void isDisabled(bool x) {
    super.value = x;
  }
}

class _SignUpPanelState extends State<_SignUpPanel> {
  String firstName = '';
  String lastName = '';
  String username = '';
  String password = '';
  int gender = 0;
  int namePrefix = 0;
  bool requesting = false;

  Future<void> performSignUp() async {
    try {
      String auth = await VaccineRNCDatabaseWS.signup(
        namePrefix: namePrefix,
        gender: gender,
        firstname: firstName,
        lastname: lastName,
        username: username,
        password: password,
      );

      await AuthorizationKey.put(auth);
    } catch (e) {
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled() =>
        username.isNotEmpty &&
        password.isNotEmpty &&
        firstName.isNotEmpty &&
        lastName.isNotEmpty;
    _SignUpButtonState buttonState =
        _SignUpButtonState(disabled: !isButtonEnabled());

    void renderButtonWhileInputting() {
      bool enabled = isButtonEnabled();
      if (buttonState.disabled != !enabled) {
        buttonState.isDisabled(!enabled);
      }
    }

    int i = 0;
    List<SimpleDropdownButtonItem<int>> namePrefixItemList =
        ['นาย', 'นาง', 'นางสาว', 'เด็กชาย', 'เด็กหญิง'].map(
      (text) {
        int c = i++;
        return SimpleDropdownButtonItem<int>(
          text: text,
          value: c,
          selected: namePrefix == c,
        );
      },
    ).toList();
    i = 0;
    List<SimpleDropdownButtonItem<int>> genderItemList = ['ชาย', 'หญิง'].map(
      (text) {
        int c = i++;
        return SimpleDropdownButtonItem<int>(
          text: text,
          value: c,
          selected: gender == c,
        );
      },
    ).toList();

    SimpleDropdownButton<int> namePrefixWidget = SimpleDropdownButton<int>(
      items: namePrefixItemList,
      disabled: requesting,
      onChanged: (selected) {
        namePrefix = selected?.value as int;
      },
    );

    SimpleTextField firstNameWidget = SimpleTextField(
      value: firstName,
      disabled: requesting,
      placeholder: 'ชื่อ/First Name',
      onInput: (value) {
        firstName = value;
        renderButtonWhileInputting();
      },
    );

    SimpleTextField lastNameWidget = SimpleTextField(
      value: lastName,
      disabled: requesting,
      placeholder: 'นามสกุล/Last Name',
      onInput: (value) {
        lastName = value;
        renderButtonWhileInputting();
      },
    );

    SimpleDropdownButton<int> genderWidget = SimpleDropdownButton<int>(
      items: genderItemList,
      disabled: requesting,
      onChanged: (selected) {
        gender = selected?.value as int;
      },
    );

    SimpleTextField usernameWidget = SimpleTextField(
      value: username,
      placeholder: 'ชื่อผู้ใช้งาน/Username',
      disabled: requesting,
      onInput: (value) {
        username = value;
        renderButtonWhileInputting();
      },
    );

    SimpleTextField passwordWidget = SimpleTextField(
      value: password,
      placeholder: 'รหัสผ่าน/Password',
      disabled: requesting,
      type: SimpleTextFieldInputType.password,
      onInput: (value) {
        password = value;
        renderButtonWhileInputting();
      },
    );

    void pressSignUpButton() {
      setState(() {
        requesting = true;
      });

      performSignUp().then((_) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home',
          (route) => true,
        );
      }).catchError((err) {
        if (err is UsernameExistError) {
          MessageNotification.usernameExist(context: context);
        } else {
          MessageNotification.badRequest(context: context);
        }
      }).whenComplete(() {
        setState(() {
          requesting = false;
        });
      });
    }

    return ChangeNotifierProvider.value(
      value: buttonState,
      builder: (context, child) => ResponsiveBuilder(
        builder: (context, properties) {
          if (properties.screenType == DeviceScreenType.mobile) {
            return Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: SimpleLayout(
                        lines: [
                          Line(
                            child: Text(
                              'ข้อมูลส่วนตัว',
                              textScaleFactor:
                                  MediaQuery.of(context).textScaleFactor,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Line(
                            child: Container(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                      margin: EdgeInsets.only(
                                        right: 10,
                                      ),
                                      child: namePrefixWidget),
                                  Expanded(
                                    child: firstNameWidget,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Line(
                            child: lastNameWidget,
                          ),
                          Line(
                            items: [
                              Item(
                                child: Text(
                                  'เพศ',
                                  textScaleFactor:
                                      MediaQuery.of(context).textScaleFactor,
                                ),
                              ),
                              Item(
                                child: genderWidget,
                              ),
                            ],
                          ),
                          Line(
                            child: Text(
                              'บัญชีผู้ใช้',
                              textScaleFactor:
                                  MediaQuery.of(context).textScaleFactor,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Line(
                            child: usernameWidget,
                          ),
                          Line(
                            child: passwordWidget,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Consumer<_SignUpButtonState>(
                      builder: (context, state, child) => ElevatedButton(
                        onPressed: requesting || state.disabled
                            ? null
                            : pressSignUpButton,
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'สมัครบัญชีผู้ใช้',
                            textScaleFactor:
                                MediaQuery.of(context).textScaleFactor,
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return Container(
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                    ),
                    child: SimpleLayout(
                      lines: [
                        Line(
                          child: Text(
                            'ข้อมูลส่วนตัว',
                            textScaleFactor:
                                MediaQuery.of(context).textScaleFactor,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Line(
                          child: Container(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                namePrefixWidget,
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: firstNameWidget,
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(left: 10),
                                    child: lastNameWidget,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        Line(
                          items: [
                            Item(
                              child: Text(
                                'เพศ',
                                textScaleFactor:
                                    MediaQuery.of(context).textScaleFactor,
                              ),
                            ),
                            Item(
                              child: genderWidget,
                            ),
                          ],
                        ),
                        Line(
                          child: Text(
                            'บัญชีผู้ใช้',
                            textScaleFactor:
                                MediaQuery.of(context).textScaleFactor,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Line(
                          child: Row(
                            children: [
                              Expanded(child: usernameWidget),
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 10),
                                  child: passwordWidget,
                                ),
                              )
                            ],
                          ),
                        ),
                        Line(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Consumer<_SignUpButtonState>(
                                builder: (context, state, child) =>
                                    ElevatedButton(
                                  onPressed: requesting || state.disabled
                                      ? null
                                      : pressSignUpButton,
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    child: Text(
                                      'สมัครบัญชีผู้ใช้',
                                      textScaleFactor: MediaQuery.of(context)
                                          .textScaleFactor,
                                      style: TextStyle(
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SignUpPanel extends StatefulWidget {
  @override
  _SignUpPanelState createState() => _SignUpPanelState();
}

/// The page widget instance of sign up section.
class SignUp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageNotification.scaffold(
      appBar: AppBar(
        title: Text('สมัครบัญชีผู้ใช้'),
      ),
      body: _SignUpPanel(),
    );
  }
}
