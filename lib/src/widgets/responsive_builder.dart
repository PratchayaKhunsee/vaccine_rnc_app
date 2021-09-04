library responsive_builder;

import 'package:flutter/widgets.dart';

/// The enumberable of the device screen type.
enum DeviceScreenType {
  /// The screen resolution should be less than or equal to 480*853 pixels.
  mobile,

  /// The screen resolution should be greater than 480*853 pixels, and less than 720*1280 pixels.
  tablet,

  /// The screen resolution should be greater than or equal to 720*1280 pixels.
  desktop,
}

/// The device orientation.
enum DeviceScreenOrientation { portrait, landscape }

/// The summarized properties of the device screen.
class DeviceScreenProperties {
  /// The screen's current displaying width
  final double? width;

  /// The screen's current displaying height
  final double? height;

  /// The screen's orientation.
  final DeviceScreenOrientation? orientation;

  /// The screen's type determined by the screen resolution.
  final DeviceScreenType? screenType;

  const DeviceScreenProperties({
    this.width,
    this.height,
    this.orientation,
    this.screenType,
  });
}

/// The responsive builder widget.
///
/// It must have [ResponsiveBuilder.builder] function to build the responsive widget.
class ResponsiveBuilder extends StatelessWidget {
  /// The responsive widget builder function.
  ///
  /// - Required.
  final Widget Function(
      BuildContext context, DeviceScreenProperties properties)? builder;

  ResponsiveBuilder({
    Key? key,
    required this.builder,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    double h = MediaQuery.of(context).size.height;

    DeviceScreenType type;
    double width = w;
    double height = h;
    double resolution = width * height;
    bool isPortrait = width <= height;

    if (resolution >= 720 * 1280)
      type = DeviceScreenType.desktop;
    else if (resolution > 480 * 853)
      type = DeviceScreenType.tablet;
    else
      type = DeviceScreenType.mobile;

    return builder!(
      context,
      DeviceScreenProperties(
        width: width,
        height: height,
        screenType: type,
        orientation: isPortrait
            ? DeviceScreenOrientation.portrait
            : DeviceScreenOrientation.landscape,
      ),
    );
  }
}
