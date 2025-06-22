import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../search/search_page.dart'; // Optional, only if you're using Get.width

class SearchBarWidget extends StatelessWidget {
  final Function(String)? onChanged;

  const SearchBarWidget({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.to(() => SearchPage(false));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Search bar container
          Container(
            height: 40,
            width:
                Get.width * 0.7, // or MediaQuery.of(context).size.width * 0.5
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Search...',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
