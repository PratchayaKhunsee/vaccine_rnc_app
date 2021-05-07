import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../global.dart' as global;
import './custom_button.dart';

class _Notifier extends ChangeNotifier {
  int _id = -1;
  String _firstname = '';
  String _lastname = '';
  bool _empty = true;
  bool _prefLoaded = false;
  int get id => _id;
  String get firstname => _firstname;
  String get lastname => _lastname;
  bool get empty => _empty;
  bool get prefLoaded => _prefLoaded;

  void update({
    int id,
    String firstname,
    String lastname,
    bool empty,
    bool prefLoaded,
  }) {
    bool changed = [id, firstname, lastname, empty, prefLoaded]
        .where((value) => value != null)
        .isNotEmpty;
    if (id != null) _id = id;
    if (firstname != null) _firstname = firstname;
    if (lastname != null) _lastname = lastname;
    if (empty != null) _empty = empty;
    if (prefLoaded != null) _prefLoaded = prefLoaded;
    if (changed) notifyListeners();
  }
}

class PatientSelector extends StatelessWidget {
  final String preferenceTarget;
  final void Function(Map<String, dynamic> selected) onSelect;
  final void Function(Map<String, dynamic> selected) onPreferenceLoaded;
  final _Notifier _notifier = _Notifier();

  PatientSelector({
    Key key,
    this.preferenceTarget,
    this.onSelect,
    this.onPreferenceLoaded,
  }) : super(key: key);

  Future<Map<String, dynamic>> _showSelector(BuildContext context) async {
    Map<String, dynamic> selected;
    List<Map<String, dynamic>> availableList;
    bool confirmed = false;
    bool requested = false;
    bool isAvailableListEmpty() =>
        !(availableList is List<Map<String, dynamic>>) ||
        availableList.length == 0;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            if (!requested)
              global.VaccineDatabaseSource.getAvailablePatient().then((value) {
                availableList = value;
              }).whenComplete(() {
                setState(() {
                  requested = true;
                });
              });

            return SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height - 250,
                  ),
                  child: Column(
                    crossAxisAlignment: requested
                        ? CrossAxisAlignment.stretch
                        : CrossAxisAlignment.center,
                    mainAxisAlignment: requested
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      // ===== [Loading Indicator] ===== //
                      Visibility(
                        visible: !requested,
                        child: Container(
                          // color: Color(0xfffe0000),
                          child: global.LoadingIcon.large(),
                        ),
                      ),
                      // ===== [List of Available Patient] ===== //
                      Visibility(
                        visible: requested && !isAvailableListEmpty(),
                        child: Expanded(
                          flex: 2,
                          child: StatefulBuilder(
                            builder: (context, _setState) {
                              return Container(
                                child: ListView(
                                  children: requested && !isAvailableListEmpty()
                                      ? availableList
                                          .map((e) => RadioListTile(
                                                value: e,
                                                groupValue: selected,
                                                title: Text(
                                                    '${e['firstname']} ${e['lastname']}'),
                                                onChanged: (Map<String, dynamic>
                                                    value) {
                                                  setState(() {
                                                    _setState(() {
                                                      selected = value;
                                                    });
                                                  });
                                                },
                                              ))
                                          .toList()
                                      : [],
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      // ===== [Confirm Button] ===== //
                      Visibility(
                        visible: requested && !isAvailableListEmpty(),
                        child: CustomButton(
                          child: Text('ตกลง'),
                          onPressed: selected != null
                              ? () {
                                  confirmed = true;
                                  Navigator.of(context).pop();
                                }
                              : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    return confirmed ? selected : null;
  }

  @override
  Widget build(BuildContext context) {
    if (preferenceTarget != null && !_notifier._prefLoaded)
      global.LocalStorage.instance().then((pref) {
        int id = pref.getInt('${preferenceTarget}_id');
        String firstname = pref.getString('${preferenceTarget}_firstname');
        String lastname = pref.getString('${preferenceTarget}_lastname');

        if (id != null && id != -1) {
          _notifier.update(
            id: id,
            firstname: firstname,
            lastname: lastname,
            empty: false,
            prefLoaded: true,
          );
        }

        onPreferenceLoaded?.call({
          'id': id,
          'firstname': firstname,
          'lastname': lastname,
        });
      });

    return ChangeNotifierProvider.value(
      value: _notifier,
      builder: (context, child) => Consumer<_Notifier>(
        builder: (context, notifier, child) => LargerCustomButton(
          heading: Icon(Icons.arrow_drop_down),
          content: Text(notifier._empty
              ? '<โปรดเลือกรายชื่อ>'
              : '${notifier.firstname} ${notifier.lastname}'),
          onPressed: () async {
            Map<String, dynamic> selected = await _showSelector(context);
            if (selected != null) {
              notifier.update(
                id: selected['id'],
                firstname: selected['firstname'],
                lastname: selected['lastname'],
                empty: false,
              );

              var pref = await global.LocalStorage.instance();

              if (pref != null) {
                await pref.setInt('${preferenceTarget}_id', selected['id']);
                await pref.setString(
                    '${preferenceTarget}_firstname', selected['firstname']);
                await pref.setString(
                    '${preferenceTarget}_lastname', selected['lastname']);
              }

              onSelect?.call({
                'id': selected['id'],
                'firstname': selected['firstname'],
                'lastname': selected['lastname'],
              });
            }
          },
        ),
      ),
    );
  }
}
