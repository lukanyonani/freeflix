// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../controllers/responsive_controller.dart';

// class ResponsiveLayout extends GetWidget<ResponsiveController> {
//   final Widget mobileLayout;
//   final Widget tabletLayout;
//   final Widget desktopLayout;

//   const ResponsiveLayout({
//     super.key,
//     required this.mobileLayout,
//     required this.tabletLayout,
//     required this.desktopLayout,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Obx(() {
//       if (controller.isPhone) {
//         return mobileLayout;
//       } else if (controller.isTablet) {
//         return tabletLayout;
//       } else {
//         return desktopLayout;
//       }
//     });
//   }
// }