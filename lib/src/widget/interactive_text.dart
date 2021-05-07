import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import '_base.dart';

class _CTextData {
  String text;
  bool pressed = false;
  Function onPress;
  Color color;
  Color unfocusColor;
  Color focusColor;
  FontWeight fontWeight;
  double fontSize;
  TextOverflow overflow;
  TextAlign textAlign;
}

class _TextState extends BaseState<InteractiveText> {
  _TextState(InteractiveText widget) : super(widget);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Text(
        this.widget._data.text ?? '',
        style: TextStyle(
          color: this.widget._data.onPress == null
              ? (this.widget._data.color ?? Color(0xff000000))
              : (this.widget._data.pressed
                  ? (this.widget._data.focusColor ??
                      Theme.of(context).focusColor)
                  : this.widget._data.unfocusColor ??
                      Theme.of(context).primaryColor),
          decoration:
              (this.widget._data.pressed && this.widget._data.onPress != null)
                  ? TextDecoration.underline
                  : null,
          fontWeight: this.widget._data.fontWeight,
          fontSize: this.widget._data.fontSize,
        ),
        overflow: this.widget._data.overflow,
        textAlign: this.widget._data.textAlign,
        textScaleFactor: 1,
      ),
      onTapDown: (details) {
        setState(() {
          this.widget._data.pressed = true;
        });
      },
      onTapUp: (details) {
        setState(() {
          this.widget._data.pressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          this.widget._data.pressed = false;
        });
      },
      onTap: () {
        this.widget._data.onPress?.call();
      },
    );
  }
}

/// A text widget that have interactive response.
class InteractiveText extends BaseWidget {
  final _CTextData _data = _CTextData();

  InteractiveText(
    dynamic text, {
    void onPress(),
    Color color,
    Color focusColor,
    Color unfocusColor,
    FontWeight fontWeight,
    double fontSize,
    TextOverflow overflow,
    TextAlign textAlign,
  }) : super() {
    this._data.text = text as String;
    this._data.onPress = onPress;
    this._data.color = color ?? Color(0xff000000);
    this._data.unfocusColor = unfocusColor;
    this._data.focusColor = focusColor;
    this._data.fontWeight = fontWeight;
    this._data.fontSize = fontSize;
    this._data.overflow = overflow;
    this._data.textAlign = textAlign;
  }

  Function() get onPress => this._data.onPress;
  set onPress(void f()) {
    this._data.onPress = f;
  }

  @override
  _TextState createState() => _TextState(this);
}
