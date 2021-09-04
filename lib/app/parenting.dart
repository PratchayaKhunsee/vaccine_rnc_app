import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '_import.dart';
import '_widgets.dart';
import '_change_notifier.dart';

/// The instance of patient's information as a [ChangeNotifier] object.
class _Patient extends ChangeNotifier {
  String firstName;
  String lastName;
  int id;

  bool panelOpened = false;
  _Patient({
    this.firstName = '',
    this.lastName = '',
    this.id = -1,
  });
  void toggle(bool? x) {
    panelOpened = x != null ? x : !panelOpened;
    notifyListeners();
  }

  void setInfo({
    String? firstName,
    String? lastName,
    int? id,
  }) {
    if (firstName != this.firstName ||
        lastName != this.lastName ||
        id != null) {
      if (firstName != null) this.firstName = firstName;
      if (lastName != null) this.lastName = lastName;
      if (id != null) this.id = id;
      notifyListeners();
    }
  }
}

/// The state of [_PatientBody].
class _PatientBodyState extends State<_PatientBody> {
  _Patient? currentPatient;
  List<_Patient>? patients;
  bool requesting = true;

  /// Show the modal bottom sheet of the patient creation tools.
  Future<void> showPatientCreationBottomSheet(BuildContext context) async {
    String _firstName = '';
    String _lastName = '';

    /// Create a patient for user account.
    Future<void> createPatient() async {
      try {
        PatientResult response =
            await VaccineRNCDatabaseWS.createPatientAsChild(
          firstName: _firstName,
          lastName: _lastName,
        );

        if (patients == null) patients = [];

        patients!.add(_Patient(
          firstName: response.firstName,
          lastName: response.lastName,
          id: response.id,
        ));
      } catch (e) {
        if (e is UnauthorizedError) {
          await Alert.unauthorized(context: context);
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        } else {
          MessageNotification.creatingPatientFailed(context: context);
        }

        throw e;
      }
    }

    await VaccineRNCAppBottomSheet.showModal(
      context: context,
      builder: (context) => ResponsiveBuilder(
        builder: (context, properties) {
          BooleanNotifier buttonDisabled = BooleanNotifier(true);
          BooleanNotifier _requesting = BooleanNotifier(false);

          Future<void> submitCreatingPatient() async {
            _requesting.value = true;

            try {
              await createPatient();

              Navigator.of(context).pop();
              MessageNotification.push(
                context: this.context,
                message: 'สร้างชื่อใหม่สำเร็จ',
              );

              setState(() {});
            } catch (e) {
              _requesting.value = false;
            }
          }

          Text header = Text(
            'สร้างรายชื่อ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );
          Widget formBody = buildPatientInfoEditor(
            context,
            properties,
            onInput: ({
              String firstName = '',
              String lastName = '',
            }) {
              _firstName = firstName;
              _lastName = lastName;
              buttonDisabled.value = _firstName.isEmpty || _lastName.isEmpty;
            },
          );
          Widget button = ChangeNotifierProvider<BooleanNotifier>.value(
            value: buttonDisabled,
            builder: (context, child) => Consumer<BooleanNotifier>(
              builder: (context, _, child) => buildIconButton(
                context,
                icon: Icon(Icons.person_add),
                label: Text('ยืนยัน'),
                onPressed: _.value ? null : submitCreatingPatient,
              ),
            ),
          );

          Widget normalStateBody() {
            if (properties.screenType == DeviceScreenType.mobile)
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: SimpleLayout(
                          lines: [
                            Line(child: header),
                            Line(child: formBody),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: button,
                    ),
                  ],
                ),
              );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SimpleLayout(
                          lines: [
                            Line(child: header),
                            Line(
                              child: formBody,
                            ),
                          ],
                        ),
                      ),
                      button,
                    ],
                  ),
                ),
              ),
            );
          }

          return ChangeNotifierProvider<BooleanNotifier>.value(
            value: _requesting,
            builder: (context, child) => Consumer<BooleanNotifier>(
              builder: (context, _, child) {
                if (_.value) return buildLoadingScreen(context);
                return normalStateBody();
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> showPatientEditingBottomSheet({
    required BuildContext context,
    required _Patient patientInstance,
  }) async {
    String _firstName = patientInstance.firstName;
    String _lastName = patientInstance.lastName;

    Future<void> editPatient(BuildContext context) async {
      try {
        PatientResult response = await VaccineRNCDatabaseWS.editPatient(
          id: patientInstance.id,
          firstName: _firstName,
          lastName: _lastName,
        );

        patientInstance.setInfo(
          firstName: response.firstName,
          lastName: response.lastName,
          id: response.id,
        );

        MessageNotification.push(
          message: 'แก้ไขรายชื่อสำเร็จ',
          context: this.context,
        );

        Navigator.of(context).pop();
      } catch (e) {
        if (e is UnauthorizedError) {
          await Alert.unauthorized(context: context);
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        } else {
          MessageNotification.editingPatientFailed(context: context);
        }

        throw e;
      }
    }

    await VaccineRNCAppBottomSheet.showModal(
      context: context,
      builder: (context) => ResponsiveBuilder(
        builder: (context, properties) {
          BooleanNotifier buttonDisabled = BooleanNotifier(true);
          BooleanNotifier _requesting = BooleanNotifier(false);

          Future<void> submitEditingPatient() async {
            _requesting.value = true;
            try {
              await editPatient(context);
            } catch (e) {
              _requesting.value = false;
            }
          }

          Text header = Text(
            'แก้ไขรายชื่อ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          );
          Widget formBody = buildPatientInfoEditor(
            context,
            properties,
            firstName: _firstName,
            lastName: _lastName,
            onInput: ({
              String firstName = '',
              String lastName = '',
            }) {
              _firstName = firstName;
              _lastName = lastName;
              buttonDisabled.value = _firstName.isEmpty || _lastName.isEmpty;
            },
          );
          Widget button = ChangeNotifierProvider<BooleanNotifier>.value(
            value: buttonDisabled,
            builder: (context, child) => Consumer<BooleanNotifier>(
              builder: (context, _, child) => buildIconButton(
                context,
                icon: Icon(Icons.edit),
                label: Text('ยืนยัน'),
                onPressed: _.value ? null : submitEditingPatient,
              ),
            ),
          );

          Widget normalStateBody() {
            if (properties.screenType == DeviceScreenType.mobile)
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(10),
                        child: SimpleLayout(
                          lines: [
                            Line(child: header),
                            Line(child: formBody),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.all(10),
                      child: button,
                    ),
                  ],
                ),
              );

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 500),
                child: Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: SimpleLayout(
                          lines: [
                            Line(child: header),
                            Line(
                              child: formBody,
                            ),
                          ],
                        ),
                      ),
                      button,
                    ],
                  ),
                ),
              ),
            );
          }

          return ChangeNotifierProvider<BooleanNotifier>.value(
            value: _requesting,
            builder: (context, child) => Consumer<BooleanNotifier>(
              builder: (context, _, child) {
                if (_.value) return buildLoadingScreen(context);
                return normalStateBody();
              },
            ),
          );
        },
      ),
    );
  }

  /// An elavated icon button.
  Widget buildIconButton(
    BuildContext context, {
    required void Function()? onPressed,
    required Icon icon,
    required Widget label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon,
      label: label,
      style: ButtonStyle(
        padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(10)),
      ),
    );
  }

  /// Useful container wrapper for being a [Row]'s child.
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

  /// The reuseable loading screen by [SimpleProgressIndicator].
  Widget buildLoadingScreen(BuildContext context) {
    return Center(
      child: SimpleProgressIndicator(
        size: ProgressIndicatorSize.large,
      ),
    );
  }

  /// Build the text that represents the [List] of [_Patient] is empty.
  Widget buildEmptyPatientList(BuildContext context) {
    return Center(
      child: Text(
        'ไม่พบรายชื่อ',
        textScaleFactor: MediaQuery.of(context).textScaleFactor,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  /// Build the patient list.
  ///
  /// Should calling this method when there is a [List] of [_Patient] at [patients].
  Widget buildPatientList(BuildContext context) {
    return Container(
      child: Column(
        children: patients!
            .map<ChangeNotifierProvider<_Patient>>(
              (e) => ChangeNotifierProvider<_Patient>.value(
                value: e,
                builder: (context, child) => Container(
                  margin: EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: Consumer<_Patient>(
                    builder: (context, _, child) => ExpansionPanelList(
                      expandedHeaderPadding: EdgeInsets.zero,
                      expansionCallback: (panelIndex, isExpanded) {
                        bool v = !isExpanded;
                        _Patient? _current = currentPatient;
                        currentPatient = v ? _ : null;
                        if (v) _current?.toggle(false);
                        _.toggle(v);
                      },
                      children: [
                        ExpansionPanel(
                          canTapOnHeader: true,
                          isExpanded: _.panelOpened,
                          headerBuilder: (context, isExpanded) => ListTile(
                            title: Text('${_.firstName} ${_.lastName}'),
                          ),
                          body: Container(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('แก้ไขข้อมูล'),
                                  onTap: () async =>
                                      await showPatientEditingBottomSheet(
                                    context: context,
                                    patientInstance: _,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget buildPatientCreationButton(BuildContext context) {
    return buildIconButton(
      context,
      label: Text('สร้างรายชื่อ'),
      icon: Icon(Icons.person_add),
      onPressed: () async => await showPatientCreationBottomSheet(context),
    );
  }

  Widget buildPatientInfoEditor(
    BuildContext context,
    DeviceScreenProperties properties, {
    String firstName = '',
    String lastName = '',
    void Function({
      String firstName,
      String lastName,
    })?
        onInput,
  }) {
    SimpleTextField _firstName = SimpleTextField(
      placeholder: 'ชื่อ',
      value: firstName,
      onInput: (value) {
        firstName = value;
        onInput?.call(
          firstName: firstName,
          lastName: lastName,
        );
      },
    );
    SimpleTextField _lastName = SimpleTextField(
      placeholder: 'นามสกุล',
      value: lastName,
      onInput: (value) {
        lastName = value;
        onInput?.call(
          firstName: firstName,
          lastName: lastName,
        );
      },
    );
    if (properties.screenType == DeviceScreenType.mobile &&
        properties.orientation == DeviceScreenOrientation.portrait)
      return SimpleLayout(
        lines: [
          Line(
            child: _firstName,
          ),
          Line(
            child: _lastName,
          ),
        ],
      );

    return SimpleLayout(
      lines: [
        Line(
          child: Row(
            children: [
              Expanded(child: _firstName),
              afterFirst(_lastName, isExpanded: true),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (requesting) {
      VaccineRNCDatabaseWS.getAvailablePatient()
          .then((list) {
            patients = list
                .map<_Patient>((e) => _Patient(
                      firstName: e.firstName,
                      lastName: e.lastName,
                      id: e.id,
                    ))
                .toList();
          })
          .catchError((err) {})
          .whenComplete(() {
            setState(() {
              requesting = false;
            });
          });

      return buildLoadingScreen(context);
    }

    return ResponsiveBuilder(
      builder: (BuildContext context, DeviceScreenProperties properties) {
        Widget buildBody() {
          if (patients == null || patients!.length == 0) {
            return buildEmptyPatientList(context);
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(10),
            child: buildPatientList(context),
          );
        }

        if (properties.screenType == DeviceScreenType.mobile) {
          return Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: buildBody(),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: buildPatientCreationButton(context),
                ),
              ],
            ),
          );
        }

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: buildBody(),
                ),
                Container(
                  margin: EdgeInsets.all(10),
                  child: buildPatientCreationButton(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// The [StatefulWidget] of the whole patient list.
class _PatientBody extends StatefulWidget {
  @override
  _PatientBodyState createState() => _PatientBodyState();
}

/// The page widget instance of parenting section.
class Parenting extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MessageNotification.scaffold(
      appBar: AppBar(
        title: Text('ดูแลรายชื่อ'),
      ),
      body: _PatientBody(),
    );
  }
}
