import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../home/layouts/desktop_homescreen.dart';
import '../../tv/desktop_tv_screen.dart';
import '../widgets/drawer.dart';

class DrawerWidget extends StatelessWidget {
  const DrawerWidget({
    super.key,
    required this.sidebarWidth,
    this.isMovie,
    this.isTv,
    this.isAnime,
  });

  final double sidebarWidth;
  final bool? isMovie;
  final bool? isTv;
  final bool? isAnime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sidebarWidth,
      color: const Color(0xFF1E1E1E),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          SizedBox(
            height: 40,
          ),
          Container(
              height: 60,
              width: 60,
              alignment: Alignment.center,
              child: Image.asset('assets/images/logo.png')),
          SizedBox(
            height: 40,
          ),
          InkWell(
            onTap: () => Get.to(() => const DesktopHomescreen()),
            child: buildDrawerItem(
              Icons.home,
              'Home',
              isMovie!,
            ),
          ),
          InkWell(
            onTap: () => Get.to(() => const DesktopTVHomescreen()),
            child: buildDrawerItem(Icons.tv, 'TV Shows', isTv!),
          ),
          InkWell(
            //onTap: () => Get.to(() => const DesktopRecentlyAddedHomescreen()),
            child: buildDrawerItem(Icons.new_releases, 'Recently Added', false),
          ),
          InkWell(
            //onTap: () => Get.to(() => const DesktopMyFavoritesHomescreen()),
            child: buildDrawerItem(Icons.bookmark, 'My Favorites', false),
          ),
          const Divider(
            color: Colors.grey,
            thickness: 0.1,
          ),
          buildDrawerItem(Icons.help, 'FAQ', false),
          buildDrawerItem(Icons.support, 'Help Center', false),
          buildDrawerItem(Icons.description, 'Terms of Use', false),
          buildDrawerItem(Icons.privacy_tip, 'Privacy', false),
        ],
      ),
    );
  }
}
