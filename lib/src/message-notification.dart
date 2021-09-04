import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'widgets/simple_snackbar.dart';

/// The namespace class that provides the asynchronous of [SimpleSnackbar] usage as
/// bottom-side messege notifications.
class MessageNotification {
  /// Create a scaffold wrapped by [ScaffoldMessenger] to make sure that
  /// the [SnackBar] can only appear inside of this created scaffold.
  ///
  /// The named parameters of this method are the same of [Scaffold]'s
  /// constructor named parameters.
  static ScaffoldMessenger scaffold({
    Widget? body,
    Key? key,
    PreferredSizeWidget? appBar,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    Widget? drawer,
    void Function(bool isOpened)? onDrawerChanged,
    Widget? endDrawer,
    void Function(bool isOpened)? onEndDrawerChanged,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    Color? backgroundColor,
    bool? resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    Color? drawerScrimColor,
    double? drawerEdgeDragWidth,
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true,
    String? restorationId,
  }) {
    return ScaffoldMessenger(
      child: Scaffold(
        appBar: appBar,
        body: body,
        backgroundColor: backgroundColor,
        bottomNavigationBar: bottomNavigationBar,
        bottomSheet: bottomSheet,
        drawer: drawer,
        drawerDragStartBehavior: drawerDragStartBehavior,
        drawerEdgeDragWidth: drawerEdgeDragWidth,
        drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
        drawerScrimColor: drawerScrimColor,
        endDrawer: endDrawer,
        endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
        extendBody: extendBody,
        extendBodyBehindAppBar: extendBodyBehindAppBar,
        floatingActionButton: floatingActionButton,
        floatingActionButtonAnimator: floatingActionButtonAnimator,
        floatingActionButtonLocation: floatingActionButtonLocation,
        key: key,
        onDrawerChanged: onDrawerChanged,
        onEndDrawerChanged: onEndDrawerChanged,
        persistentFooterButtons: persistentFooterButtons,
        primary: primary,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        restorationId: restorationId,
      ),
    );
  }

  /// Display the snackbar inside of the [ScaffoldMessenger] scope depending on
  /// [context]'s build context or [scaffoldMessengerStateKey]'s global key.
  static Future<void> push({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
    required String message,
  }) async {
    var snackbar = SnackBar(
      content: Text(message),
    );
    if (scaffoldMessengerStateKey != null)
      await scaffoldMessengerStateKey.currentState
          ?.showSnackBar(snackbar)
          .closed;
    if (context != null)
      await ScaffoldMessenger.of(context).showSnackBar(snackbar).closed;
  }

  /// Calling [push] with the message about the "bad request" response.
  static Future<void> badRequest({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'เกิดข้อผิดพลาด โปรดตรวจสอบข้อมูลก่อน',
    );
  }

  /// Calling [push] with the message about the "password incorrect" response.
  static Future<void> passwordIncorrect({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'รหัสผ่านไม่ถูกต้อง',
    );
  }

  /// Calling [push] with the message about the "user not found" response.
  static Future<void> userNotFound({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'ไม่พบชื่อบัญชีผู้ใช้',
    );
  }

  /// Calling [push] with the message about the "user not found" response.
  static Future<void> usernameExist({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'ชื่อบัญชีผู้ใช้นี้ถูกใช้งานแล้ว',
    );
  }

  /// Calling [push] with the message about the "patient creating failed" response.
  static Future<void> creatingPatientFailed({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'เกิดข้อผิดพลาดระหว่างการสร้างรายชื่อใหม่',
    );
  }

  /// Calling [push] with the message about the "patient modifying failed" response.
  static Future<void> editingPatientFailed({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'เกิดข้อผิดพลาดระหว่างการแก้ไขรายชื่อ',
    );
  }

  /// Calling [push] with the message about the "unexpected" response.
  static Future<void> unexpected({
    BuildContext? context,
    GlobalKey<ScaffoldMessengerState>? scaffoldMessengerStateKey,
  }) async {
    await push(
      context: context,
      scaffoldMessengerStateKey: scaffoldMessengerStateKey,
      message: 'พบข้อผิดพลาดบางอย่าง ขออภัยในความไม่สะดวก',
    );
  }
}
