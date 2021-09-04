import 'package:flutter/widgets.dart';

import 'widgets/simple_alert_dialog.dart';

/// The namespace class that provide [SimpleAlertDialog] usage.
class Alert {
  /// Display an alert dialog with the message about "unauthorized"
  static Future<void> unauthorized({
    required BuildContext context,
    String routeNamedPath = '/login',
  }) async {
    await SimpleAlertDialog.show(
      context,
      body: Text(
          'คุณไม่สามารถเข้าถึงข้อมูลดังกล่าวได้ เนื่องจากเกิดข้อผิดพลาดบางอย่าง'),
      closeButtonText: 'ปิดหน้าต่าง',
      hasCloseButton: true,
    );
  }
}
