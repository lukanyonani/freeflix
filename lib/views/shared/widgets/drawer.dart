import 'package:flutter/material.dart';

Widget buildDrawerItem(IconData icon, String title, bool isSelected,
    {VoidCallback? onTap}) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: isSelected ? const Color(0xFFE50914) : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
    ),
    child: ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.white : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: () {
        onTap?.call();
      },
    ),
  );
}
