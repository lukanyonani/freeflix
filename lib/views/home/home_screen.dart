import 'package:flutter/material.dart';
import '../../controllers/responsive_controller.dart';
import 'layouts/mobile_homescreen.dart';
import 'layouts/desktop_homescreen.dart';
import 'layouts/tablet_homescreen.dart';

class HomePage extends StatelessWidget {
  final Map<String, dynamic> apiData;
  const HomePage({Key? key, required this.apiData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determine the current device type based on width only
    final deviceType = ResponsiveUtil.of(context);

    switch (deviceType) {
      case DeviceType.Phone:
        return MobileHomePage(
          apiData: apiData,
          title: 'FreeFlix',
        );
      case DeviceType.Tablet:
        return TabletHomescreen();
      case DeviceType.Desktop:
        return DesktopHomescreen();
    }
  }
}
