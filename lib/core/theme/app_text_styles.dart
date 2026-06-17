import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextStyleManager {
  // Prevent instantiation
  TextStyleManager._();

  static const String fontFamily = "Bukra";

  static TextStyle style12Regular = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w400,
  );

  // ============= Named Styles =============
  static TextStyle heading1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle heading2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle heading3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle text2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle text3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle dataCard = TextStyle(
    fontFamily: fontFamily,
    fontWeight: FontWeight.w500,
  );

  static TextStyle sideBarText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle smallButtons = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
  );

  // ============= Generic Styles =============
  static TextStyle style7Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 7.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style8Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style8Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 8.sp,
    fontWeight: FontWeight.w700,
  );

  static TextStyle style9Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 9.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style10Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style11Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 11.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style14Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style15Medium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15.sp,
    fontWeight: FontWeight.w500,
  );

  static TextStyle style28Bold = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
  );
}