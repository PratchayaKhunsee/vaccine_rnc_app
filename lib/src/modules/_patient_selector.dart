import 'package:flutter/material.dart';
import '../widget/custom_button.dart';
import '../../global.dart' as global;

class PatientSelector extends StatelessWidget {
  final Map<String, dynamic> _data = {
    'id': -1,
    'firstname': '',
    'lastname': '',
    'empty': true,
  };
  final String prefrenceTarget;
  final Function(Map<String, dynamic> selected) onSelect;
  final Function() onInstantiate;

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
                          child: SizedBox(
                            width: 175,
                            height: 175,
                            child: CircularProgressIndicator(
                              strokeWidth: 10,
                            ),
                          ),
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
    return StatefulBuilder(
      builder: (context, setState) {
        if (_data['empty'] == true) {
          global.LocalStorage.instance().then((pref) {
            int id = pref.getInt('${prefrenceTarget}_id');

            if (id != null) {
              setState(() {
                _data['id'] = id;
                _data['firstname'] =
                    pref.getString('${prefrenceTarget}_firstname');
                _data['lastname'] =
                    pref.getString('${prefrenceTarget}_lastname');
                _data['empty'] = false;
              });

              if (onSelect is Function)
                onSelect({
                  'id': _data['id'],
                  'firstname': _data['firstname'],
                  'lastname': _data['lastname'],
                });
            }
          });
        }

        return LargerCustomButton(
          heading: Icon(Icons.arrow_drop_down),
          content: Text(_data['empty']
              ? '<โปรดเลือกรายชื่อ>'
              : '${_data['firstname']} ${_data['lastname']}'),
          onPressed: () async {
            Map<String, dynamic> selected = await _showSelector(context);
            if (selected != null) {
              setState(() {
                this._data.addAll(selected);
                this._data['empty'] = false;
              });

              if (prefrenceTarget == null || prefrenceTarget.isEmpty) return;

              var pref = await global.LocalStorage.instance();
              if (pref != null) {
                await pref.setInt('${prefrenceTarget}_id', _data['id']);
                await pref.setString(
                    '${prefrenceTarget}_firstname', _data['firstname']);
                await pref.setString(
                    '${prefrenceTarget}_lastname', _data['lastname']);
              }

              if (selected != null && onSelect is Function) onSelect(selected);
            }
          },
        );
      },
    );
  }

  PatientSelector({
    this.prefrenceTarget,
    this.onSelect,
    this.onInstantiate,
    Map<String, dynamic> selected,
  }) : super() {
    if (selected != null) {
      _data['id'] = selected['id'] as int;
      _data['firstname'] = '${selected['firstname']}';
      _data['lastname'] = '${selected['lastname']}';
      _data['empty'] = false;
    }
  }
}
