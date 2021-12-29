import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '_import.dart';

class _UserAccountValues extends ChangeNotifier {
  bool requesting;
  bool disabled;
  String oldPassword;
  String newPassword;
  _UserAccountValues? oldValues;
  _UserAccountValues({
    this.requesting = false,
    this.disabled = false,
    this.oldPassword = '',
    this.newPassword = '',
  }) : super();

  void setValuesForNotifying({
    bool? requesting,
    bool? disabled,
  }) {
    bool shouldNotify = false;
    if (requesting != this.requesting && requesting != null) {
      this.requesting = requesting;
      shouldNotify = true;
    }
    if (disabled != this.disabled && disabled != null) {
      this.disabled = disabled;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
  }

  void reserve() {
    oldValues = _UserAccountValues(
      newPassword: newPassword,
      oldPassword: oldPassword,
    );
  }

  void revert() {
    if (oldValues != null) {
      oldPassword = oldValues!.oldPassword;
      newPassword = oldValues!.newPassword;
    }
  }

  void reset() {
    oldPassword = '';
    newPassword = '';
    oldValues = null;
  }

  bool get isSameAsReserve {
    if (oldValues == null ||
        oldPassword != oldValues!.oldPassword ||
        newPassword != oldValues!.newPassword) return false;
    return true;
  }

  bool get hasEmptyValues => oldPassword.isEmpty || newPassword.isEmpty;
}

class _UserInfoValues extends ChangeNotifier {
  bool requesting;
  bool disabled;
  int namePrefix;
  int gender;
  String firstName;
  String lastName;
  _UserInfoValues? oldValues;
  _UserInfoValues({
    this.requesting = false,
    this.disabled = false,
    this.firstName = '',
    this.lastName = '',
    this.namePrefix = 0,
    this.gender = 0,
  }) : super();

  void setValuesForNotifying({
    bool? requesting,
    bool? disabled,
  }) {
    bool shouldNotify = false;
    if (requesting != this.requesting && requesting != null) {
      this.requesting = requesting;
      shouldNotify = true;
    }
    if (disabled != this.disabled && disabled != null) {
      this.disabled = disabled;
      shouldNotify = true;
    }

    if (shouldNotify) notifyListeners();
  }

  void reserve() {
    oldValues = _UserInfoValues(
      firstName: firstName,
      lastName: lastName,
      gender: gender,
      namePrefix: namePrefix,
    );
  }

  void revert() {
    if (oldValues != null) {
      firstName = oldValues!.firstName;
      lastName = oldValues!.lastName;
      gender = oldValues!.gender;
      namePrefix = oldValues!.namePrefix;
      oldValues = null;
    }
  }

  void reset() {
    firstName = '';
    lastName = '';
    gender = 0;
    namePrefix = 0;
    oldValues = null;
  }

  bool get isSameAsReserve {
    if (oldValues == null ||
        firstName != oldValues!.firstName ||
        lastName != oldValues!.lastName ||
        gender != oldValues!.gender ||
        namePrefix != oldValues!.namePrefix) return false;
    return true;
  }

  bool get hasEmptyValues => firstName.isEmpty || lastName.isEmpty;
}

class _UserFormPanelState extends State<_UserFormPanel> {
  bool requesting = true;
  bool isLoggingOut = false;
  String username = '';
  final _UserAccountValues account = _UserAccountValues(requesting: true);
  final _UserInfoValues infos = _UserInfoValues(requesting: true);

  Future<void> preloadUserInfo() async {
    try {
      UserInfoResult result = await VaccineRNCDatabaseWS.getUserInfo();
      infos.firstName = result.firstName;
      infos.lastName = result.lastName;
      infos.namePrefix = result.namePrefix;
      infos.gender = result.gender;
      username = result.username;
    } catch (e) {
      debugPrint(e.toString());
      if (e is NoAuthenticationKeyError) {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        return;
      }

      if (e is UnauthorizedError) {
        await Alert.unauthorized(context: context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
    } finally {
      setState(() {
        requesting = account.requesting = infos.requesting = false;
        infos.disabled = account.disabled = true;
      });
    }
  }

  Future<void> performEditingUserInfo(_UserInfoValues values) async {
    try {
      values.setValuesForNotifying(requesting: true);

      UserInfoResult u = await VaccineRNCDatabaseWS.editUserInfo(
        firstName: values.firstName,
        lastName: values.lastName,
        gender: values.gender,
        namePrefix: values.namePrefix,
      );

      values.firstName = u.firstName;
      values.lastName = u.lastName;
      values.gender = u.gender;
      values.namePrefix = u.namePrefix;

      MessageNotification.push(
        context: this.context,
        message: 'บันทึกข้อมูลสำเร็จ',
      );

      values.setValuesForNotifying(
        requesting: false,
        disabled: true,
      );
    } catch (e) {
      if (e is NoAuthenticationKeyError) {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        return;
      }

      if (e is UnauthorizedError) {
        await Alert.unauthorized(context: context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (e is UserInfoModifyingError || e is BadRequestError)
        MessageNotification.badRequest(context: this.context);

      if (e is UnexpectedResponseError)
        MessageNotification.unexpected(context: this.context);

      values.setValuesForNotifying(
        requesting: false,
        disabled: false,
      );
    }
  }

  Future<void> performEditingUserAccount(_UserAccountValues values) async {
    try {
      values.setValuesForNotifying(requesting: true);
      await VaccineRNCDatabaseWS.editUserAccount(
        oldPassword: values.oldPassword,
        newPassword: values.newPassword,
      );

      values.oldPassword = '';
      values.newPassword = '';

      MessageNotification.push(
        context: this.context,
        message: 'บันทึกข้อมูลสำเร็จ',
      );

      values.setValuesForNotifying(
        requesting: false,
        disabled: true,
      );
    } catch (e) {
      if (e is NoAuthenticationKeyError) {
        await Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
        return;
      }

      if (e is UnauthorizedError) {
        await Alert.unauthorized(context: context);
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }

      if (e is UserPasswordChangingError)
        MessageNotification.passwordIncorrect(context: this.context);

      if (e is BadRequestError)
        MessageNotification.badRequest(context: this.context);

      if (e is UnexpectedResponseError)
        MessageNotification.unexpected(context: this.context);

      values.setValuesForNotifying(
        requesting: false,
        disabled: false,
      );
    }
  }

  Future<void> performLogout() async {
    bool confirmed = false;

    try {
      await SimpleAlertDialog.show(
        context,
        title: "ออกจากระบบ",
        body: Text("คุณต้องการอกจากระบบหรือไม่"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("ยกเลิก"),
          ),
          TextButton(
            onPressed: () {
              confirmed = true;
              Navigator.of(context).pop();
            },
            child: Text("ออกจากระบบ"),
          ),
        ],
      );
      if (confirmed) {
        setState(() {
          isLoggingOut = true;
        });
        await VaccineRNCDatabaseWS.logout();
      }
    } catch (e) {
    } finally {
      if (!confirmed) {
        setState(() {
          isLoggingOut = false;
        });
      } else {
        await AuthorizationKey.delete();
        await Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (requesting) preloadUserInfo();
    double textScaleFactor = MediaQuery.textScaleFactorOf(context);
    Widget afterFirst(
      Widget child, {
      bool isExpanded = false,
    }) {
      var c = Container(
        margin: EdgeInsets.only(left: 10),
        child: child,
      );

      return isExpanded ? Expanded(child: c) : c;
    }

    Row row(List<Widget> items) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: items,
      );
    }

    Container createLoadingIndicator() => Container(
          child: Center(
            child: SimpleProgressIndicator(
              size: ProgressIndicatorSize.large,
            ),
          ),
        );

    ElevatedButton createIconButton(
      Icon icon,
      Widget label, {
      void Function()? onPressed,
    }) =>
        ElevatedButton.icon(
          onPressed: onPressed,
          icon: icon,
          label: label,
          style: ButtonStyle(
            padding: MaterialStateProperty.all<EdgeInsets>(
              EdgeInsets.fromLTRB(10, 2, 10, 2),
            ),
          ),
        );

    Widget formSection(
      Widget child,
      Widget loadingOverlay,
    ) =>
        Stack(
          alignment: Alignment.center,
          children: [
            child,
            loadingOverlay,
          ],
        );

    Widget forms(Widget child) {
      if (isLoggingOut)
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: 300),
          child: createLoadingIndicator(),
        );

      return child;
    }

    Consumer<_UserInfoValues> firstName = Consumer<_UserInfoValues>(
      builder: (context, _, child) => SimpleTextField(
        value: _.firstName,
        disabled: _.requesting || _.disabled,
        placeholder: 'ชื่อ',
        onInput: (v) {
          _.firstName = v;
        },
      ),
    );
    Consumer<_UserInfoValues> lastName = Consumer<_UserInfoValues>(
      builder: (context, _, child) => SimpleTextField(
        value: _.lastName,
        disabled: _.requesting || _.disabled,
        placeholder: 'นามสกุล',
        onInput: (v) {
          _.lastName = v;
        },
      ),
    );
    Consumer<_UserInfoValues> namePrefix = Consumer<_UserInfoValues>(
      builder: (context, _, child) {
        int i = 0;
        return SimpleDropdownButton<int>(
          disabled: _.requesting || _.disabled,
          onChanged: (selected) {
            _.namePrefix = selected?.value as int;
          },
          items: [
            'นาย',
            'นาง',
            'นางสาว',
            'เด็กชาย',
            'เด็กหญิง',
          ].map<SimpleDropdownButtonItem<int>>((e) {
            int v = i++;
            return SimpleDropdownButtonItem<int>(
              text: e,
              value: v,
              selected: v == _.namePrefix,
            );
          }).toList(),
        );
      },
    );

    Consumer<_UserInfoValues> gender = Consumer<_UserInfoValues>(
      builder: (context, _, child) {
        int i = 0;
        return SimpleDropdownButton<int>(
          disabled: _.requesting || _.disabled,
          onChanged: (selected) {
            _.gender = selected?.value as int;
          },
          items: [
            'ชาย',
            'หญิง',
          ].map<SimpleDropdownButtonItem<int>>((e) {
            int v = i++;
            return SimpleDropdownButtonItem<int>(
              text: e,
              value: v,
              selected: v == _.gender,
            );
          }).toList(),
        );
      },
    );
    Consumer<_UserAccountValues> oldPassword = Consumer<_UserAccountValues>(
      builder: (context, _, child) => SimpleTextField(
        value: _.oldPassword,
        disabled: _.requesting || _.disabled,
        placeholder: 'รหัสผ่านเดิม',
        type: SimpleTextFieldInputType.password,
        onInput: (v) {
          _.oldPassword = v;
        },
      ),
    );
    Consumer<_UserAccountValues> newPassword = Consumer<_UserAccountValues>(
      builder: (context, _, child) => SimpleTextField(
        value: _.newPassword,
        disabled: _.requesting || _.disabled,
        placeholder: 'รหัสผ่านใหม่',
        type: SimpleTextFieldInputType.password,
        onInput: (v) {
          _.newPassword = v;
        },
      ),
    );
    Consumer<_UserInfoValues> userInfoEditAndCloseButton =
        Consumer<_UserInfoValues>(
      builder: (context, _, child) => createIconButton(
        !_.requesting && !_.disabled ? Icon(Icons.close) : Icon(Icons.edit),
        Text(!_.requesting && !_.disabled ? 'ยกเลิก' : 'แก้ไข'),
        onPressed: _.requesting
            ? null
            : () {
                if (!_.disabled)
                  _.revert();
                else
                  _.reserve();
                _.setValuesForNotifying(disabled: !_.disabled);
              },
      ),
    );

    Consumer<_UserAccountValues> userAccountEditAndCloseButton =
        Consumer<_UserAccountValues>(
      builder: (context, _, child) => createIconButton(
        !_.requesting && !_.disabled ? Icon(Icons.close) : Icon(Icons.edit),
        Text(!_.requesting && !_.disabled ? 'ยกเลิก' : 'แก้ไข'),
        onPressed: _.requesting
            ? null
            : () {
                if (!_.disabled)
                  _.revert();
                else
                  _.reserve();
                _.setValuesForNotifying(disabled: !_.disabled);
              },
      ),
    );

    Consumer<_UserInfoValues> userInfoSaveButton = Consumer<_UserInfoValues>(
      builder: (context, _, child) => createIconButton(
        Icon(Icons.save),
        Text('บันทึก'),
        onPressed:
            _.requesting || _.disabled ? null : () => performEditingUserInfo(_),
      ),
    );

    Consumer<_UserAccountValues> userAccountSaveButton =
        Consumer<_UserAccountValues>(
      builder: (context, _, child) => createIconButton(
        Icon(Icons.save),
        Text('บันทึก'),
        onPressed: _.requesting || _.disabled
            ? null
            : () => performEditingUserAccount(_),
      ),
    );

    ElevatedButton logoutButton = ElevatedButton.icon(
      icon: Icon(Icons.logout),
      label: Text('ออกจากระบบ'),
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(12)),
      ),
      onPressed: isLoggingOut || requesting ? null : () => performLogout(),
    );

    Consumer<_UserInfoValues> userInfoEdittingIndicator =
        Consumer<_UserInfoValues>(
      builder: (context, _, child) => Visibility(
        visible: _.requesting,
        child: createLoadingIndicator(),
      ),
    );

    Consumer<_UserAccountValues> userAccountEdittingIndicator =
        Consumer<_UserAccountValues>(
      builder: (context, _, child) => Visibility(
        visible: _.requesting,
        child: createLoadingIndicator(),
      ),
    );

    Widget usernameSection = row([
      Text(
        'ชื่อบัญชีผู้ใช้:',
        textScaleFactor: textScaleFactor,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      afterFirst(
        Text('$username'),
      ),
    ]);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: account),
        ChangeNotifierProvider.value(value: infos),
      ],
      builder: (context, child) => ResponsiveBuilder(
        builder: (context, properties) {
          if (requesting) {
            return Container(
              child: Center(
                child: SimpleProgressIndicator(
                  size: ProgressIndicatorSize.large,
                ),
              ),
            );
          }

          TextStyle headersTextStyle = TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );

          Text userInfoHeader = Text(
            'ข้อมูลส่วนตัว',
            textScaleFactor: textScaleFactor,
            style: headersTextStyle,
          );
          Text userAccountHeader = Text(
            'ข้อมูลบัญชีผู้ใช้',
            textScaleFactor: textScaleFactor,
            style: headersTextStyle,
          );

          if (properties.screenType == DeviceScreenType.mobile) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: forms(
                    SingleChildScrollView(
                      padding: EdgeInsets.all(10),
                      child: SimpleLayout(
                        lines: [
                          Line(
                            child: userInfoHeader,
                          ),
                          Line(
                            child: formSection(
                              SimpleLayout(
                                lines: [
                                  Line(
                                    child: row([
                                      namePrefix,
                                      afterFirst(
                                        firstName,
                                        isExpanded: true,
                                      ),
                                    ]),
                                  ),
                                  Line(
                                    child: lastName,
                                  ),
                                  Line(
                                    child: row([
                                      Text(
                                        'เพศ',
                                        textScaleFactor: textScaleFactor,
                                      ),
                                      afterFirst(gender),
                                    ]),
                                  ),
                                ],
                              ),
                              userInfoEdittingIndicator,
                            ),
                          ),
                          Line(
                            child: row([
                              userInfoEditAndCloseButton,
                              afterFirst(userInfoSaveButton),
                            ]),
                          ),
                          Line(
                            child: userAccountHeader,
                          ),
                          Line(
                            child: usernameSection,
                          ),
                          Line(
                            child: formSection(
                              SimpleLayout(
                                lines: [
                                  Line(
                                    child: oldPassword,
                                  ),
                                  Line(
                                    child: newPassword,
                                  ),
                                ],
                              ),
                              userAccountEdittingIndicator,
                            ),
                          ),
                          Line(
                            child: row([
                              userAccountEditAndCloseButton,
                              afterFirst(userAccountSaveButton),
                            ]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(10),
                  child: logoutButton,
                ),
              ],
            );
          }

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: 500,
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: forms(
                        SimpleLayout(
                          lines: [
                            Line(
                              child: formSection(
                                SimpleLayout(
                                  lines: [
                                    Line(
                                      child: userInfoHeader,
                                    ),
                                    Line(
                                      child: row([
                                        namePrefix,
                                        afterFirst(firstName, isExpanded: true),
                                        afterFirst(lastName, isExpanded: true),
                                      ]),
                                    ),
                                    Line(
                                      child: row([
                                        Text('เพศ'),
                                        afterFirst(gender),
                                      ]),
                                    ),
                                  ],
                                ),
                                userInfoEdittingIndicator,
                              ),
                            ),
                            Line(
                              child: row([
                                userInfoEditAndCloseButton,
                                afterFirst(userInfoSaveButton),
                              ]),
                            ),
                            Line(
                              child: userAccountHeader,
                            ),
                            Line(
                              child: usernameSection,
                            ),
                            Line(
                              child: formSection(
                                row([
                                  Expanded(child: oldPassword),
                                  afterFirst(newPassword, isExpanded: true),
                                ]),
                                userAccountEdittingIndicator,
                              ),
                            ),
                            Line(
                              child: row([
                                userAccountEditAndCloseButton,
                                afterFirst(userAccountSaveButton),
                              ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10),
                      child: logoutButton,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UserFormPanel extends StatefulWidget {
  @override
  _UserFormPanelState createState() => _UserFormPanelState();
}

/// The page widget instance of user section.
class User extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageNotification.scaffold(
      appBar: AppBar(
        title: Text('บัญชีผู้ใช้งาน'),
      ),
      body: _UserFormPanel(),
    );
  }
}
