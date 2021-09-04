import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '_change_notifier.dart';
import '_import.dart';

class _LoginButtonState extends BooleanNotifier {
  _LoginButtonState({
    bool disabled = true,
  }) : super(disabled);

  bool get disabled => value;

  void isDisabled(bool x) {
    super.value = x;
  }
}

class _LoginPanelState extends State<_LoginPanel> {
  bool requesting = false;
  String username = '';
  String password = '';

  Future<void> performLogin() async {
    try {
      var result = await VaccineRNCDatabaseWS.login(
        username: username,
        password: password,
      );
      if (result is String) await AuthorizationKey.put(result);
    } catch (e) {
      throw e;
    }
  }

  void pressLoginButton(BuildContext context) async {
    setState(() {
      requesting = true;
    });

    try {
      await performLogin();
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    } catch (e) {
      if (e is PasswordIncorrectError)
        MessageNotification.passwordIncorrect(context: this.context);
      else if (e is UserNotFoundError)
        MessageNotification.userNotFound(context: this.context);
    } finally {
      setState(() {
        requesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled() => username.isNotEmpty && password.isNotEmpty;
    _LoginButtonState buttonState =
        _LoginButtonState(disabled: !isButtonEnabled());

    void renderButtonFromTextInput() {
      bool enabled = isButtonEnabled();
      if (buttonState.disabled != !enabled) buttonState.isDisabled(!enabled);
    }

    return ChangeNotifierProvider.value(
      value: buttonState,
      builder: (context, child) => SimpleLayout(
        lines: [
          Line(
            child: SimpleTextField(
              value: username,
              disabled: requesting,
              placeholder: 'ชื่อผู้ใช้',
              onInput: (value) {
                username = value;
                renderButtonFromTextInput();
              },
            ),
          ),
          Line(
            nextLineSpacing: 25,
            child: SimpleTextField(
              value: password,
              disabled: requesting,
              placeholder: 'รหัสผ่าน',
              type: SimpleTextFieldInputType.password,
              onInput: (value) {
                password = value;
                renderButtonFromTextInput();
              },
            ),
          ),
          Line(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'หากคุณไม่มีบัญชีผู้ใช้ ',
                    textScaleFactor: MediaQuery.textScaleFactorOf(context),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/signup');
                    },
                    child: Text(
                      'สามารถสมัครได้ที่นี่',
                      textScaleFactor: MediaQuery.textScaleFactorOf(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Line(
            child: Container(
              child: Row(
                children: [
                  Expanded(
                    child: Consumer<_LoginButtonState>(
                      builder: (context, state, child) => ElevatedButton(
                        child: Container(
                          padding: EdgeInsets.all(10),
                          child: Text(
                            'เข้าสู่ระบบ',
                            textScaleFactor:
                                MediaQuery.textScaleFactorOf(context),
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                        onPressed: requesting || state.disabled
                            ? null
                            : () => pressLoginButton(context),
                      ),
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

class _LoginPanel extends StatefulWidget {
  @override
  _LoginPanelState createState() => _LoginPanelState();
}

/// The page widget instance of login section.
class Login extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AuthorizationKey.get().then(
      (_) {
        if (_ != null) {
          Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (route) => false);
        }
      },
    );

    return MessageNotification.scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400,
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.only(
                    bottom: 20,
                  ),
                  child: Text(
                    'เข้าสู่ระบบ',
                    textScaleFactor: MediaQuery.textScaleFactorOf(context),
                    style: TextStyle(
                      fontSize: 36,
                    ),
                  ),
                ),
                _LoginPanel(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
