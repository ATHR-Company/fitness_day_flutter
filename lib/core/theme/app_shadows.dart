import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  /// A soft, modern drop shadow typically used for cards, search bars, and menu items.
  static const List<BoxShadow> primaryShadow = [
    BoxShadow(
      color: Color(0x14000000), // 8% black
      blurRadius: 5,
      spreadRadius: 1,
      offset: Offset(0, 4),
    ),
  ];

  /// Shadow for profile items
  static const List<BoxShadow> profileItemShadow = [
    BoxShadow(
      color: Color(0x40000000), // 25% black
      blurRadius: 4,
      spreadRadius: 0,
      offset: Offset(0, 0),
    ),
  ];
}
