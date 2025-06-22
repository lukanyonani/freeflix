/// Defines size constants and breakpoints for responsive design throughout the app
class AppSizes {
  // Responsive breakpoints
  /// Maximum width for a device to be considered a phone
  static const double PHONE_BREAKPOINT = 600;
  
  /// Maximum width for a device to be considered a tablet
  static const double TABLET_BREAKPOINT = 1200;
  
  // Padding and margin constants
  /// Extra small padding/margin size
  static const double PADDING_XS = 4.0;
  
  /// Small padding/margin size
  static const double PADDING_S = 8.0;
  
  /// Medium padding/margin size
  static const double PADDING_M = 16.0;
  
  /// Large padding/margin size
  static const double PADDING_L = 24.0;
  
  /// Extra large padding/margin size
  static const double PADDING_XL = 32.0;
  
  // Font sizes
  /// Small text size
  static const double TEXT_S = 12.0;
  
  /// Default text size
  static const double TEXT_M = 14.0;
  
  /// Large text size
  static const double TEXT_L = 16.0;
  
  /// Extra large text size
  static const double TEXT_XL = 18.0;
  
  /// Heading size
  static const double TEXT_HEADING = 20.0;
  
  /// Title size
  static const double TEXT_TITLE = 24.0;
  
  // Component sizes
  /// Default border radius for components
  static const double BORDER_RADIUS = 8.0;
  
  /// Small border radius
  static const double BORDER_RADIUS_S = 4.0;
  
  /// Large border radius
  static const double BORDER_RADIUS_L = 12.0;
  
  /// Default card elevation
  static const double CARD_ELEVATION = 2.0;
  
  /// Button height
  static const double BUTTON_HEIGHT = 48.0;
  
  /// Small button height
  static const double BUTTON_HEIGHT_S = 36.0;
  
  /// Input field height
  static const double INPUT_HEIGHT = 56.0;
  
  /// App bar height
  static const double APPBAR_HEIGHT = 60.0;
  
  /// Size of icon buttons
  static const double ICON_BUTTON_SIZE = 44.0;
  
  /// Avatar size (medium)
  static const double AVATAR_SIZE = 40.0;
  
  /// Small avatar size
  static const double AVATAR_SIZE_S = 32.0;
  
  /// Large avatar size
  static const double AVATAR_SIZE_L = 56.0;
  
  // Layout sizes
  /// Drawer width for tablets
  static const double DRAWER_WIDTH_TABLET = 300.0;
  
  /// Sidebar width for desktop layout
  static const double SIDEBAR_WIDTH_DESKTOP = 250.0;
  
  /// Bottom navigation bar height
  static const double BOTTOM_NAV_HEIGHT = 60.0;
  
  /// Height for header sections
  static const double HEADER_HEIGHT = 200.0;
  
  /// Responsive multipliers (can be used for responsive calculations)
  static const double PHONE_MULTIPLIER = 1.0;
  static const double TABLET_MULTIPLIER = 1.5;
  static const double DESKTOP_MULTIPLIER = 2.0;
  
  // Get multiplier based on width
  static double getMultiplier(double width) {
    if (width < PHONE_BREAKPOINT) {
      return PHONE_MULTIPLIER;
    } else if (width < TABLET_BREAKPOINT) {
      return TABLET_MULTIPLIER;
    } else {
      return DESKTOP_MULTIPLIER;
    }
  }
}