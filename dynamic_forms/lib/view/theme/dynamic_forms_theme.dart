import 'package:flutter/material.dart';

class DynamicFormsThemeData {
  const DynamicFormsThemeData({
    this.headerBackgroundColor,
    this.headerTextStyle,
    this.rowTextStyle,
    this.gridLineColor,
    this.selectionColor,
    this.rowHoverColor,
    this.pagerItemColor,
    this.pagerSelectedItemColor,
  this.footerBackgroundColor,
  });

  final Color? headerBackgroundColor;
  final TextStyle? headerTextStyle;
  final TextStyle? rowTextStyle;
  final Color? gridLineColor;
  final Color? selectionColor;
  final Color? rowHoverColor;
  final Color? pagerItemColor;
  final Color? pagerSelectedItemColor;
  final Color? footerBackgroundColor;

  DynamicFormsThemeData copyWith({
    Color? headerBackgroundColor,
    TextStyle? headerTextStyle,
    TextStyle? rowTextStyle,
    Color? gridLineColor,
    Color? selectionColor,
    Color? rowHoverColor,
    Color? pagerItemColor,
    Color? pagerSelectedItemColor,
    Color? footerBackgroundColor,
  }) {
    return DynamicFormsThemeData(
      headerBackgroundColor: headerBackgroundColor ?? this.headerBackgroundColor,
      headerTextStyle: headerTextStyle ?? this.headerTextStyle,
      rowTextStyle: rowTextStyle ?? this.rowTextStyle,
      gridLineColor: gridLineColor ?? this.gridLineColor,
      selectionColor: selectionColor ?? this.selectionColor,
      rowHoverColor: rowHoverColor ?? this.rowHoverColor,
      pagerItemColor: pagerItemColor ?? this.pagerItemColor,
      pagerSelectedItemColor:
          pagerSelectedItemColor ?? this.pagerSelectedItemColor,
      footerBackgroundColor: footerBackgroundColor ?? this.footerBackgroundColor,
    );
  }
}

class DynamicFormsTheme extends InheritedWidget {
  const DynamicFormsTheme({
    super.key,
    required this.data,
    required super.child,
  });

  final DynamicFormsThemeData data;

  static DynamicFormsThemeData? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DynamicFormsTheme>()?.data;
  }

  static DynamicFormsThemeData of(BuildContext context) {
    final data = maybeOf(context);
    assert(data != null, 'No DynamicFormsTheme found in context');
    return data!;
  }

  @override
  bool updateShouldNotify(DynamicFormsTheme oldWidget) => data != oldWidget.data;
}
