import 'package:flutter/widgets.dart';

/// Enum to represent different screen size categories
enum DeviceType { Phone, Tablet, Desktop }

/// Utility class for responsive breakpoints based solely on width
class ResponsiveUtil {
  /// Breakpoints for different device types
  static const double phoneBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  /// Determines the [DeviceType] based on the given [width]
  static DeviceType getDeviceType(double width) {
    if (width < phoneBreakpoint) {
      return DeviceType.Phone;
    } else if (width < tabletBreakpoint) {
      return DeviceType.Tablet;
    } else {
      return DeviceType.Desktop;
    }
  }

  /// Convenience getters for [MediaQuery]
  static DeviceType of(BuildContext context) {
    return getDeviceType(MediaQuery.of(context).size.width);
  }

  static bool isPhone(BuildContext context) {
    return of(context) == DeviceType.Phone;
  }

  static bool isTablet(BuildContext context) {
    return of(context) == DeviceType.Tablet;
  }

  static bool isDesktop(BuildContext context) {
    return of(context) == DeviceType.Desktop;
  }
}
