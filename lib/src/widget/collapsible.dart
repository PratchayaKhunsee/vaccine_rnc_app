import 'package:flutter/material.dart';
import '_base.dart';

class _Data {
  Widget header;
  Widget content;
  bool isOpened = false;
  bool isToggleable = true;
}

class _CollapsibleState extends BaseState<Collapsible> {
  _CollapsibleState(Collapsible widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              if (this.widget._data.isToggleable) {
                this.setState(() {
                  this.widget._data.isOpened = !this.widget._data.isOpened;
                });
              }
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xffdfdfdf),
                    Color(0xffbfbfbf),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                // color: Colors.blueAccent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomLeft:
                      Radius.circular(this.widget._data.isOpened ? 0 : 5),
                  bottomRight:
                      Radius.circular(this.widget._data.isOpened ? 0 : 5),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 5,
                    color: Color(0x2f000000),
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: this.widget._data.header,
              padding: EdgeInsets.all(5),
              width: double.infinity,
            ),
          ),
          Visibility(
            visible: this.widget._data.isOpened,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 2,
                  color: Color(0xffbfbfbf),
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                gradient: LinearGradient(
                  colors: [
                    Color(0xffcfcfcf),
                    Color(0xffefefef),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1f000000),
                    blurRadius: 5,
                  ),
                ],
              ),
              padding: EdgeInsets.all(5),
              width: double.infinity,
              child: this.widget._data.content,
            ),
          ),
        ],
      ),
    );
  }
}

class Collapsible extends BaseWidget {
  final _Data _data = _Data();

  Collapsible({
    Widget content,
    Widget header,
    bool toggleable = true,
    bool opened = false,
  }) : super() {
    this._data.content = content;
    this._data.header = header;
    this._data.isToggleable = toggleable;
    this._data.isOpened = opened;
  }

  @override
  _CollapsibleState createState() => _CollapsibleState(this);
}
