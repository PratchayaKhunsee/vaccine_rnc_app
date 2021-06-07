import 'dart:io' show Platform;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

// [[ In-file Used Only Section ]]

enum _EnumPlatform {
  iOS,
  Android,
}

// [[ END ]]

// [[ Outside Enumeration Section ]]

/// There are allowed button types.
///
/// Android - [ButtonType.flat], [ButtonType.outlined] and [ButtonType.raised]
///
/// iOS - [ButtonType.iOSButton], [ButtonType.iOSAction] and [ButtonType.iOSDialogAction]
enum ButtonType {
  flat,
  raised,
  outlined,
  iOSButton,
  iOSDialogAction,
  iOSAction,
}

// [[ Widget Building Context Section ]]

/// Abstract context class of widget building.
abstract class WidgetContext {
  // WidgetContext _hostWidget;
  // void Function() onPageOpened;
  Widget build(
    BuildContext context, {
    @required _EnumPlatform platform,
  });
}

/// It represents a button.
class ButtonContext extends WidgetContext {
  String text;
  Icon icon;
  void Function() onPress;
  ButtonType buttonType;

  ButtonContext({
    this.text,
    this.icon,
    this.onPress,
    this.buttonType,
  }) : super();

  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
    WidgetContext hostWidget,
  }) {
    Text t = Text(this.text ?? '');
    Icon c = this.icon;
    void Function() pressed = this.onPress;

    switch (platform) {
      case _EnumPlatform.iOS:
        switch (this.buttonType) {
          case ButtonType.iOSDialogAction:
            return CupertinoDialogAction(
              child: t,
              onPressed: pressed,
            );
            break;
          case ButtonType.iOSAction:
            return CupertinoActionSheetAction(
              onPressed: pressed,
              child: t,
            );
            break;
          default:
            return CupertinoButton(
              child: t,
              onPressed: pressed,
            );
        }
        break;
      default:
        switch (this.buttonType) {
          case ButtonType.flat:
            if (this.icon != null) {
              return TextButton.icon(
                onPressed: pressed,
                icon: c,
                label: t,
              );
            }
            return TextButton(
              onPressed: pressed,
              child: t,
            );
          case ButtonType.outlined:
            if (this.icon != null) {
              return OutlinedButton.icon(
                onPressed: pressed,
                icon: c,
                label: t,
              );
            }
            return OutlinedButton(
              child: t,
              onPressed: pressed,
            );
          default:
            if (this.icon != null) {
              return ElevatedButton.icon(
                onPressed: pressed,
                icon: c,
                label: t,
              );
            }
            return ElevatedButton(
              onPressed: pressed,
              child: t,
            );
        }
    }
  }
}

/// It represent a bottom/action sheet.
class ActionSheetContext extends WidgetContext {
  List<ButtonContext> actions;

  /// Cancel button for iOS action sheet.
  ButtonContext cancelButton;

  /// A callback that being invoked when a Material bottom sheet is on closing.
  void Function() onClose;
  ActionSheetContext({
    @required this.actions,
    this.cancelButton,
    this.onClose,
  }) : super();
  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    List<Widget> ch;
    Widget cancelBtn;

    switch (platform) {
      case _EnumPlatform.iOS:
        ch = this.actions.map<Widget>((ButtonContext e) {
          e.buttonType = ButtonType.iOSAction;
          // e._hostWidget = this;
          return e.build(
            context,
            platform: platform,
            hostWidget: this,
          );
        }).toList();
        if (this.cancelButton != null) {
          cancelButton.buttonType = ButtonType.iOSAction;
          void Function() f = cancelButton.onPress;
          cancelButton.onPress = () {
            Navigator.of(context).pop();
            f();
          };

          // this.cancelButton._hostWidget = this;
          cancelBtn = this.cancelButton.build(
                context,
                platform: platform,
                hostWidget: this,
              );
        }

        return CupertinoActionSheet(
          actions: ch,
          cancelButton: cancelBtn,
        );
      default:
        ch = this.actions.map<Widget>((ButtonContext e) {
          e.buttonType = ButtonType.flat;
          return e.build(
            context,
            platform: platform,
            hostWidget: this,
          );
        }).toList();
        void Function() closed = this.onClose;
        Widget field = Container(
          child: Row(
            children: ch,
          ),
        );

        return BottomSheet(
          onClosing: closed,
          builder: (BuildContext context) => field,
        );
    }
  }
}

/// It represents a navigation bar.
class NavbarContext extends WidgetContext {
  String title;
  NavbarContext({
    this.title,
  });
  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    Text t = this.title != null ? Text(this.title) : null;

    switch (platform) {
      case _EnumPlatform.iOS:
        return CupertinoNavigationBar(
          middle: t,
        );
      default:
        return AppBar(
          title: t,
        );
    }
  }
}

/// It represents an indicator.
class IndicatorContext extends WidgetContext {
  /// The width and the height of indicator.
  double size;

  /// The value of Material's circular progress indicator.
  ///
  /// The allowed value is between 0.0 and 1.0. If null, the indicator is indeterminate.
  double value;

  /// The circle line width of Material's circular progress indicator.
  double strokeWidth;

  IndicatorContext({
    this.size,
    this.value,
    this.strokeWidth,
  });

  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    double px = this.size;
    double val = this.value;
    switch (platform) {
      case _EnumPlatform.iOS:
        return CupertinoActivityIndicator(
          radius: px ?? 10,
        );
      default:
        return Container(
          width: px ?? 16,
          height: px ?? 16,
          child: CircularProgressIndicator(
            value: val,
            strokeWidth: 2,
          ),
        );
    }
  }
}

/// It represents a button that containing a menu.
///
/// For Material Design, this context will create a floating button using [UnicornDialer] and [UnicornButton].
///
/// For iOS Apple Design, this context will create a [CupertinoButton] and using [CupertinoActionSheet] as a menu.
class ButtonWithMenuContext extends WidgetContext {
  String message;
  Icon icon;
  List<MenuItemContext> items;

  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    switch (platform) {
      case _EnumPlatform.iOS:
        List<CupertinoActionSheetAction> ch =
            this.items.map<CupertinoActionSheetAction>((MenuItemContext e) {
          // e._hostWidget = this;
          return e.build(
            context,
            platform: platform,
            hostWidget: this,
          );
        }).toList();
        CupertinoActionSheet menu = CupertinoActionSheet(
          actions: ch,
        );

        return CupertinoButton(
          child: Text(this.message ?? ''),
          onPressed: () async {
            await showCupertinoModalPopup(
              context: context,
              builder: (BuildContext context) => menu,
            );
          },
        );
      default:
        List<SpeedDialChild> ch =
            this.items.map<SpeedDialChild>((MenuItemContext e) {
          // e._hostWidget = this;
          return SpeedDialChild(
            label: e.message,
            child: e.icon,
            onTap: e.onPress,
          );
        }).toList();
        return SpeedDial(
          children: ch,
        );
    }
  }
}

/// It represents a menu item.
class MenuItemContext extends WidgetContext {
  void Function() onPress;
  Icon icon;
  String message;
  MenuItemContext({
    this.onPress,
    this.icon,
    this.message,
  });
  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
    WidgetContext hostWidget,
  }) {
    void Function() pressed = this.onPress;
    Icon c = this.icon;
    String msg = this.message;
    switch (platform) {
      case _EnumPlatform.iOS:
        return CupertinoActionSheetAction(
          onPressed: pressed,
          child: Text('$msg'),
        );
      default:
        if (hostWidget is ButtonWithMenuContext) {}
        return ListTile(
          onTap: pressed,
          title: Text('$msg'),
          leading: c,
        );
    }
  }
}

/// It represents a scaffold.
class ScaffoldContext extends WidgetContext {
  NavbarContext navbar;
  ButtonWithMenuContext pageButton;
  Widget body;

  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    Widget nav = this.navbar?.build(
          context,
          platform: platform,
        );
    Widget b = body;
    Widget btn = this.pageButton?.build(
          context,
          platform: platform,
        );
    switch (platform) {
      case _EnumPlatform.iOS:
        return CupertinoPageScaffold(
          navigationBar: nav,
          child: Container(
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: b,
                  ),
                ),
                btn
              ],
            ),
          ),
        );
      default:
        return Scaffold(
          appBar: nav,
          floatingActionButton: btn,
          body: SingleChildScrollView(
            child: b,
          ),
        );
    }
  }
}

/// It represent a text field.
class TextFieldContext extends WidgetContext {
  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    switch (platform) {
      case _EnumPlatform.iOS:
        return CupertinoTextField();
      default:
        return TextField();
    }
  }
}

/// It represents a page routes.
///
/// It also automatically change their page view if there is a keyboard usage from user.
class PageRouteContext extends WidgetContext {
  ScaffoldContext scaffold;
  PageRouteContext({
    @required this.scaffold,
  });
  @override
  Widget build(
    BuildContext context, {
    _EnumPlatform platform,
  }) {
    Widget c = this.scaffold.build(
          context,
          platform: platform,
        );
    return SingleChildScrollView(
      physics: NeverScrollableScrollPhysics(),
      child: Container(
        child: c,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
      ),
    );
  }
}

// [[ END ]]

// [[ Functional Widget Usage Section ]]

/// An asynchronous callback that requesting the app to show datepicker.
///
/// When user already confirmed picking the date, the callback returned [Future] that recieving [DateTime] object.
///
Future<DateTime> useDatePicker(
  BuildContext context, {
  _EnumPlatform platform,
  DateTime initialDate,
  DateTime minDate,
  DateTime maxDate,
}) async {
  DateTime date;
  DateTime init = initialDate ?? DateTime.now();
  DateTime min = minDate ?? DateTime(1900);
  DateTime max = maxDate ?? DateTime(2100);
  switch (platform) {
    case _EnumPlatform.iOS:
      CupertinoDatePicker picker = CupertinoDatePicker(
        onDateTimeChanged: (DateTime value) {
          date = value;
        },
        initialDateTime: init,
        maximumDate: max,
        minimumDate: min,
      );
      await showCupertinoModalPopup(
        context: context,
        builder: (context) => picker,
      );
      break;
    default:
      date = await showDatePicker(
        context: context,
        initialDate: init,
        firstDate: min,
        lastDate: max,
      );
  }

  return date;
}

/// An asynchronous callback that requesting the app to show timepicker.
///
/// When user already confirmed picking the time, the callback returned [Future] that recieving [TimeOfDay] object.
///
Future<TimeOfDay> useTimePicker(
  BuildContext context, {
  _EnumPlatform platform,
  TimeOfDay initialTime,
  int secondInterval,
  int minuteInterval,
}) async {
  TimeOfDay time;
  TimeOfDay init = initialTime ?? TimeOfDay.now();

  switch (platform) {
    case _EnumPlatform.iOS:
      CupertinoTimerPicker picker = CupertinoTimerPicker(
        initialTimerDuration: Duration(
          hours: init.hour,
          minutes: init.minute,
        ),
        secondInterval: secondInterval,
        minuteInterval: minuteInterval,
        onTimerDurationChanged: (Duration dur) {
          time = TimeOfDay(
            hour: dur.inHours % 24,
            minute: dur.inMinutes % 60,
          );
        },
      );

      await showCupertinoModalPopup(
        context: context,
        builder: (BuildContext context) => picker,
      );
      break;
    default:
      time = await showTimePicker(
        context: context,
        initialTime: init,
      );
  }

  return time;
}

// [[ END ]]

// [[ Useful Widget Section ]]

/// The widget builder for [WidgetContext].
class WidgetContextBuilder extends StatelessWidget {
  /// A widget building context.
  final WidgetContext widgetContext;

  const WidgetContextBuilder({
    Key key,
    @required this.widgetContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return this.widgetContext.build(
          context,
          platform: Platform.isIOS ? _EnumPlatform.iOS : _EnumPlatform.Android,
        );
  }
}

/// The main app structure. It automatically choose the app design depended on the current platform.
class AppBuilder extends StatelessWidget {
  final Map<String, PageRouteContext> routes;

  const AppBuilder({
    Key key,
    this.routes,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Widget> pages = routes.map((routeName, ctx) {
      return MapEntry<String, Widget>(
        routeName,
        WidgetContextBuilder(
          widgetContext: ctx,
        ),
      );
    });
    if (Platform.isIOS) {
      return CupertinoApp(
        routes: pages.map<String, Widget Function(BuildContext)>(
          (String routeName, Widget widget) => MapEntry(
            routeName,
            (BuildContext context) {
              return widget;
            },
          ),
        ),
      );
    }
    return MaterialApp(
      routes: pages.map<String, Widget Function(BuildContext)>(
        (String routeName, Widget widget) => MapEntry(
          routeName,
          (BuildContext context) {
            return widget;
          },
        ),
      ),
    );
  }
}

/// The wrapper [StatelessWidget] that being used for creating a platform-specific widget in one scope.
class MultiPlatformWidget extends StatelessWidget {
  final Widget iOS;
  final Widget android;
  final Widget other;

  const MultiPlatformWidget({
    Key key,
    this.iOS,
    this.android,
    this.other,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return iOS;
    }

    if (Platform.isAndroid) {
      return android;
    }

    return other;
  }
}

// [[ END ]]
