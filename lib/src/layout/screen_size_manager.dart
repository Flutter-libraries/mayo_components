import 'package:flutter/material.dart';

///
/// [@var		number	kSmallScreen]
/// [@global]
///
const kSmallScreen = 576;

///
/// [@var		number	kMediumScreen]
/// [@global]
///
const kMediumScreen = 768;

///
/// [@var		number	kLargeScreen]
/// [@global]
///
const kLargeScreen = 992;

///
/// [@var		number	kSmallScreenHeight]
/// [@global]
///
const kSmallScreenHeight = 780;

///
/// [@var		number	kMediumScreenHeight]
/// [@global]
///
const kMediumScreenHeight = 914;

///
/// [ScreenSizeManager.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Tuesday, November 1st, 2022]
/// [@global]
///
class ScreenSizeManager {
  ///
  static Size screenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  ///
  static double devicePixelRatio(BuildContext context) {
    return MediaQuery.of(context).devicePixelRatio;
  }

  ///
  static double screenHeight(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).height - reducedBy) / dividedBy;
  }

  ///
  static double screenWidth(BuildContext context,
      {double dividedBy = 1, double reducedBy = 0.0}) {
    return (screenSize(context).width - reducedBy) / dividedBy;
  }

  ///
  static double screenWidthPercent(BuildContext context, double percent) {
    return screenSize(context).width * percent;
  }

  ///
  static double screenHeightExcludingToolbar(BuildContext context,
      {double dividedBy = 1}) {
    return screenHeight(context,
        dividedBy: dividedBy, reducedBy: kToolbarHeight);
  }

  ///
  static double heightFromRatio(BuildContext context, double x, double y) =>
      MediaQuery.of(context).size.width * y / x;

  ///

  double get physicalScreenWidth =>
      WidgetsBinding.instance.window.physicalSize.width;

  ///

  double get physicalScreenHeight =>
      WidgetsBinding.instance.window.physicalSize.height;

  ///
  static bool isSmallScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height <= kSmallScreenHeight;

  ///
  static bool isMediumScreenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height <= kMediumScreenHeight;

  ///
  static bool isSmallScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width <= kSmallScreen;

  ///
  static bool isMediumScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width <= kMediumScreen;

  ///
  static bool isLargeScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width > kMediumScreen;
}
