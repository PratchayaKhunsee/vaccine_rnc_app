import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import '../src/webservice/vaccine-rnc.dart';
import '../src/widgets.dart';

/// The state management instance of the radio item.
class _RadioNotifier extends ChangeNotifier {
  void rebuild() {
    notifyListeners();
  }
}

/// The instance of patient information being used in [PatientSelector].
class Patient {
  final int id;
  final String firstName;
  final String lastName;

  Patient({
    required this.id,
    required this.firstName,
    required this.lastName,
  });
}

abstract class VaccineRNCAppBottomSheet {
  static Future<void> showModal({
    required BuildContext context,
    required Widget Function(BuildContext context) builder,
    bool draggable = true,
  }) =>
      SimpleBottomSheet.showModal(
        maxWidth: 500,
        maxHeight: 450,
        context: context,
        builder: builder,
        draggable: true,
      );
}

/// The state of [PatientSelector].
class PatientSelectorState extends State<PatientSelector> {
  Patient? _selected;
  List<Patient>? _list;
  @override
  Widget build(BuildContext context) {
    Future<void> showModal() async {
      bool requesting = true;
      bool confirmed = false;
      Patient? current;

      await VaccineRNCAppBottomSheet.showModal(
        context: context,
        builder: (context) => StatefulBuilder(
          builder: (context, _setState) {
            // This scope is used when initially opening the modal.
            if (requesting) {
              _list = null;
              VaccineRNCDatabaseWS.getAvailablePatient().then(
                (l) {
                  _list = l
                      .map<Patient>(
                        (e) => Patient(
                          id: e.id,
                          firstName: e.firstName,
                          lastName: e.lastName,
                        ),
                      )
                      .toList();
                },
              ).catchError(
                (err) {
                  _list = [];
                },
              ).whenComplete(
                () {
                  _setState(() {
                    requesting = false;
                  });
                },
              );
              return Container(
                child: Center(
                  child: SimpleProgressIndicator(
                    size: ProgressIndicatorSize.large,
                  ),
                ),
              );
            }

            // This widget will be displayed when no patient is available.
            if (_list == null || _list!.length == 0) {
              return Container(
                child: Center(
                  child: Text(
                    'ไม่พบรายชื่อ',
                    textScaleFactor: MediaQuery.of(context).textScaleFactor,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            }

            // The current instance of picked radio item. Not the selected radio item.
            _RadioNotifier? currentRadio;
            ValueNotifier<bool> confirmButtonDisabled = ValueNotifier(true);

            void onComfirmButtonPressed() {
              confirmed = true;
              Navigator.of(context).pop();
            }

            return Container(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ListView(
                      children: _list!.map(
                        (e) {
                          // Create notifier for wrapping the radio item widget.
                          // When user picked the radio item, notify the radio item
                          // widget to rebuild the widget.
                          _RadioNotifier radio = _RadioNotifier();

                          // Set the selected radio item as the current radio item.
                          if (_selected?.id == e.id) currentRadio = radio;

                          return ChangeNotifierProvider.value(
                            value: radio,
                            builder: (context, child) =>
                                Consumer<_RadioNotifier>(
                              builder: (context, _, child) =>
                                  RadioListTile<_RadioNotifier>(
                                value: radio,
                                groupValue: currentRadio,
                                title: Text('${e.firstName} ${e.lastName}'),
                                onChanged: (_) {
                                  if (currentRadio != null) {
                                    currentRadio!.rebuild();
                                  }

                                  currentRadio = radio;
                                  radio.rebuild();

                                  current = e;
                                  confirmButtonDisabled.value = false;
                                },
                              ),
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 10),
                    child: ChangeNotifierProvider.value(
                      value: confirmButtonDisabled,
                      builder: (context, _) => Consumer<ValueNotifier<bool>>(
                        builder: (context, v, _) => ElevatedButton.icon(
                          onPressed: v.value ? null : onComfirmButtonPressed,
                          icon: Icon(Icons.done),
                          label: Text('เลือก'),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      );

      if (confirmed && current != null) {
        setState(() {
          _selected = current;
        });

        widget.onConfirmed?.call(current!);
      }
    }

    // The main button.
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(10),
      textStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
        fontStyle: _selected == null ? FontStyle.italic : FontStyle.normal,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 500,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          gradient: LinearGradient(
            colors: [
              Colors.lightBlue,
              Colors.blueAccent,
            ],
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 20,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    _selected != null
                        ? '${_selected?.firstName} ${_selected?.lastName}'
                        : '<โปรดเลือกรายชื่อ>',
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            showModal();
          },
        ),
      ),
    );
  }
}

// The widget for selecting the current patient.
class PatientSelector extends StatefulWidget {
  /// Triggered when the user confirms the patient selection.
  final void Function(Patient selected)? onConfirmed;

  PatientSelector({
    Key? key,
    this.onConfirmed,
  }) : super(key: key);

  @override
  PatientSelectorState createState() => PatientSelectorState();

  /// Trying to get the state of [PatientSelector] from the build context's widget tree.
  ///
  /// It should be used inside of the [PatientSelector] instance.
  PatientSelectorState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<PatientSelectorState>();
}

class _DatePickerRebuilder extends ChangeNotifier {
  DateTime? date;
  _DatePickerRebuilder({
    this.date,
  }) : super();

  void set(DateTime d) {
    if (d != date) {
      date = d;
      notifyListeners();
    }
  }
}

/// The widget wrapper for using the date picker.
class DatePickerWrapper extends StatelessWidget {
  final DateTime? initialDate;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final Widget Function(BuildContext context, DateTime? selectedDate) builder;
  final void Function(DateTime selected)? onDatePicked;

  DatePickerWrapper({
    Key? key,
    this.initialDate,
    this.firstDate,
    this.lastDate,
    this.onDatePicked,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    _DatePickerRebuilder rebuild = _DatePickerRebuilder(
      date: initialDate,
    );

    Future<void> _press(BuildContext context) async {
      DateTime? selected = await showDatePicker(
        context: context,
        initialDate: initialDate ?? DateTime.now(),
        firstDate: firstDate ?? DateTime(0),
        lastDate: lastDate ?? DateTime.now(),
      );

      if (selected != null) {
        rebuild.set(selected);
        onDatePicked?.call(selected);
      }
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _press(context),
        child: ChangeNotifierProvider<_DatePickerRebuilder>.value(
          value: rebuild,
          builder: (context, child) => Consumer<_DatePickerRebuilder>(
            builder: (context, _, child) => builder(context, _.date),
          ),
        ),
      ),
    );
  }
}

class DummyTextField extends StatelessWidget {
  /// The maximum number of the value length. If it is null, there is no limit for the range.
  final int? maxLength;
  final String? value;

  /// The text displaying for the empty text field.
  final String? placeholder;
  DummyTextField({
    Key? key,
    this.maxLength,
    this.placeholder,
    this.value,
  }) : super();
  @override
  Widget build(BuildContext context) {
    return TextField(
      maxLength: maxLength,
      enabled: false,
      decoration: InputDecoration(
        hintText: placeholder,
      ),
      controller: TextEditingController(
        text: value,
      ),
    );
  }
}

Future<Uint8List?> showImagePickerBottomSheet({
  required BuildContext context,
}) async {
  Uint8List? value;
  await VaccineRNCAppBottomSheet.showModal(
    context: context,
    draggable: false,
    builder: (context) => ConstrainedBox(
      constraints: BoxConstraints(),
      child: CombinedImagePicker(
        onPicked: (imageBytes) {
          value = imageBytes;
          Navigator.of(context);
        },
      ),
    ),
  );

  return value;
}
