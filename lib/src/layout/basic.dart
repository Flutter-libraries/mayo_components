import 'package:flutter/material.dart';
import 'package:mayo_components/src/layout/screen_size_manager.dart';

///
/// [RowAutoLayout.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Sunday, October 30th, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class RowAutoLayout extends StatelessWidget {
  /// Constructor
  RowAutoLayout({
    super.key,
    required this.children,
    this.spacing = 0.0,
    this.padding = 0.0,
    this.widthsPercent,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  })  : assert(spacing >= 0, 'Spacing must be greatter than 0'),
        assert(padding >= 0, 'Spacing must be greatter than 0'),
        assert(
          widthsPercent == null || widthsPercent.length == children.length,
          'Widths lenght must match with children lenght',
        ),
        assert(
          widthsPercent == null ||
              widthsPercent.reduce((value, element) => value + element) == 1.0,
          'Widths must sum 1.0 (100%)',
        );

  /// Uniform distribution of cells
  factory RowAutoLayout.distributed({
    required List<Widget> children,
    double spacing = 0,
    double padding = 0,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return RowAutoLayout(
      spacing: spacing,
      padding: padding,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children
          .map(
            (e) => Expanded(
              child: e,
            ),
          )
          .toList(),
    );
  }

  /// Distribution of cells by percents in widths list
  factory RowAutoLayout.widthPercent({
    required List<Widget> children,
    required List<double> widths,
    double spacing = 0,
    double padding = 0,
    MainAxisAlignment? mainAxisAlignment,
    CrossAxisAlignment? crossAxisAlignment,
  }) {
    return RowAutoLayout(
      spacing: spacing,
      padding: padding,
      widthsPercent: widths,
      mainAxisAlignment: mainAxisAlignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }

  ///
  /// [@var		mixed	children]
  ///
  final List<Widget> children;

  ///
  /// [@var		final	double]
  ///
  final double spacing;

  ///
  /// [@var		final	double]
  ///
  final double padding;

  ///
  /// Custom percents for cells width.
  /// Eg. for 3 cells: first with 50%  width, latest two with 25% width each
  /// one: [.5, .25, .25]
  /// [@var		mixed	widths]
  ///
  final List<double>? widthsPercent;

  ///
  /// [@var		final	MainAxisAlignment]
  ///
  final MainAxisAlignment? mainAxisAlignment;

  ///
  /// [@var		final	CrossAxisAlignment]
  ///
  final CrossAxisAlignment? crossAxisAlignment;

  ///
  /// Calculate cell width using percent, spacing and padding
  ///
  double getCellWidth(BuildContext context, double percent) =>
      ScreenSizeManager.screenWidthPercent(
        context,
        percent,
      ) -
      padding -
      spacing / 2;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...{
          if (widthsPercent != null)
            SizedBox(
              width: getCellWidth(
                context,
                widthsPercent!.elementAt(i),
              ),
              child: padding > 0
                  ? Padding(
                      padding: EdgeInsets.all(padding),
                      child: children[i],
                    )
                  : children[i],
            )
          else
            padding > 0
                ? Padding(
                    padding: EdgeInsets.all(padding),
                    child: children[i],
                  )
                : children[i],
          if (i != children.length - 1)
            SizedBox(
              width: spacing,
            )
        },
      ],
    );
  }
}

///
/// [ColumnAutoLayout.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Sunday, October 30th, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class ColumnAutoLayout extends StatelessWidget {
  /// Constructor
  const ColumnAutoLayout({
    super.key,
    required this.children,
    this.spacing = 0,
    this.padding = 0,
    this.mainAxisAlignment,
    this.crossAxisAlignment,
  })  : assert(spacing >= 0, 'Spacing must be greatter than 0'),
        assert(padding >= 0, 'Spacing must be greatter than 0');

  ///
  /// [@var		mixed	children]
  ///
  final List<Widget> children;

  ///
  /// [@var		final	double]
  ///
  final double spacing;

  ///
  /// [@var		final	double]
  ///
  final double padding;

  ///
  /// [@var		final	MainAxisAlignment]
  ///
  final MainAxisAlignment? mainAxisAlignment;

  ///
  /// [@var		final	CrossAxisAlignment]
  ///
  final CrossAxisAlignment? crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: mainAxisAlignment ?? MainAxisAlignment.start,
      crossAxisAlignment: crossAxisAlignment ?? CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < children.length; i++) ...{
          if (padding > 0)
            Padding(
              padding: EdgeInsets.all(padding),
              child: children[i],
            )
          else
            children[i],
          if (i != children.length - 1)
            SizedBox(
              height: spacing,
            )
        },
      ],
    );
  }
}

///
/// Displays a Row in larger screens and a column in small screens
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Tuesday, November 1st, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class RowResponsive extends StatelessWidget {
  /// Constructor
  const RowResponsive({
    super.key,
    required this.children,
    this.spacing = 0,
    this.padding = 0,
    this.widthsPercent,
    this.rowCrossAxisAlignment,
    this.rowMainAxisAlignment,
    this.columnCrossAxisAlignment,
    this.columnMainAxisAlignment,
  })  : assert(spacing >= 0, 'Spacing must be greatter than 0'),
        assert(padding >= 0, 'Spacing must be greatter than 0');

  ///
  /// [@var		mixed	children]
  ///
  final List<Widget> children;

  ///
  /// [@var		final	double]
  ///
  final double padding;

  ///
  /// [@var		final	double]
  ///
  final double spacing;

  ///
  /// Custom percents for cells width.
  /// Eg. for 3 cells: first with 50%  width, latest two with 25% width each
  /// one: [.5, .25, .25]
  /// [@var		mixed	widths]
  ///
  final List<double>? widthsPercent;

  ///
  /// [@var		final	CrossAxisAlignment]
  ///
  final CrossAxisAlignment? rowCrossAxisAlignment;

  ///
  /// [@var		final	MainAxisAlignment]
  ///
  final MainAxisAlignment? rowMainAxisAlignment;

  ///
  /// [@var		final	CrossAxisAlignment]
  ///
  final CrossAxisAlignment? columnCrossAxisAlignment;

  ///
  /// [@var		final	MainAxisAlignment]
  ///
  final MainAxisAlignment? columnMainAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return ScreenSizeManager.isMediumScreenWidth(context)
        ? ColumnAutoLayout(
            spacing: spacing,
            padding: padding,
            crossAxisAlignment:
                columnCrossAxisAlignment ?? CrossAxisAlignment.start,
            mainAxisAlignment:
                columnMainAxisAlignment ?? MainAxisAlignment.start,
            children: children,
          )
        : RowAutoLayout(
            spacing: spacing,
            padding: padding,
            widthsPercent: widthsPercent,
            crossAxisAlignment:
                rowCrossAxisAlignment ?? CrossAxisAlignment.start,
            mainAxisAlignment: rowMainAxisAlignment ?? MainAxisAlignment.start,
            children: children,
          );
  }
}
