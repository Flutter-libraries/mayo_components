import 'package:flutter/material.dart';
import 'package:mayo_components/src/layout/screen_size_manager.dart';

class ScaffoldResponsive extends StatelessWidget {
  const ScaffoldResponsive({
    required this.leftMenuDrawer,
    required this.body,
    super.key,
  });
  final Widget leftMenuDrawer;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ScreenSizeManager.isMediumScreenWidth(context) ? AppBar() : null,
      drawer: ScreenSizeManager.isMediumScreenWidth(context)
          ? leftMenuDrawer
          : null,
      body: ScreenSizeManager.isMediumScreenWidth(context)
          ? body
          : Row(
              children: [leftMenuDrawer, Expanded(child: body)],
            ),
    );
  }
}
