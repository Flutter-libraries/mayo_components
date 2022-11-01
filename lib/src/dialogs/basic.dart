import 'package:flutter/material.dart';

///
/// [AlertDialogLayout.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Tuesday, November 1st, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class AlertDialogLayout extends StatelessWidget {
  /// Constructor
  const AlertDialogLayout({
    super.key,
    required this.title,
    this.actionIcon,
    this.showActionIcon = true,
    this.message,
    this.content,
    this.actions,
  });

  /// Confirm dialog with 2 buttons
  factory AlertDialogLayout.confirm({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? confirmButtonText,
    String? cancelButtonText,
    required void Function() onConfirmPressed,
    required void Function() oncancelPressed,
  }) {
    return AlertDialogLayout(
      title: title,
      actionIcon: Icons.warning_amber_rounded,
      message: message,
      content: content,
      actions: [
        ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: onConfirmPressed,
          child: Text(confirmButtonText ?? 'Confirm'),
        ),
        OutlinedButton(
          style: Theme.of(context).outlinedButtonTheme.style?.copyWith(
                foregroundColor: MaterialStatePropertyAll(
                  Theme.of(context).colorScheme.error,
                ),
                side: MaterialStatePropertyAll(
                  BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
          onPressed: oncancelPressed,
          child: Text(cancelButtonText ?? 'Cancel'),
        )
      ],
    );
  }

  /// Confirm dialog with 2 buttons
  factory AlertDialogLayout.info({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? buttonText,
    required void Function() onButtonPressed,
  }) {
    return AlertDialogLayout(
      title: title,
      actionIcon: Icons.warning_amber_rounded,
      message: message,
      content: content,
      actions: [
        ElevatedButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          onPressed: onButtonPressed,
          child: Text(buttonText ?? 'Accept'),
        ),
      ],
    );
  }

  /// Confirm dialog with custom actions
  factory AlertDialogLayout.customActions({
    required String title,
    required List<Widget> actions,
    String? message,
    Widget? content,
  }) {
    return AlertDialogLayout(
      title: title,
      actionIcon: Icons.warning_amber_rounded,
      message: message,
      content: content,
      actions: actions,
    );
  }

  ///
  /// [@var		final	String]
  ///
  final String title;

  ///
  /// [@var		final	String]
  ///
  final String? message;

  ///
  /// [@var		final	Widget]
  ///
  final IconData? actionIcon;

  ///
  /// [@var		final	bool]
  ///
  final bool showActionIcon;

  ///
  /// [@var		final	Widget]
  ///
  final Widget? content;

  ///
  /// [@var		mixed	actions]
  ///
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      iconColor: Theme.of(context).colorScheme.primary,
      actionsAlignment: MainAxisAlignment.center,
      actionsOverflowDirection: VerticalDirection.down,
      iconPadding: const EdgeInsets.fromLTRB(32, 32, 32, 8),
      titlePadding: const EdgeInsets.fromLTRB(32, 8, 32, 4),
      contentPadding: const EdgeInsets.fromLTRB(32, 4, 32, 8),
      actionsPadding: const EdgeInsets.fromLTRB(32, 32, 16, 32),
      titleTextStyle: Theme.of(context).textTheme.subtitle1,
      title: Text(
        title,
      ),
      icon: showActionIcon
          ? Icon(
              actionIcon,
              size: 80,
            )
          : null,
      content: IntrinsicHeight(
        child: Column(
          children: [
            if (message != null)
              Text(message!, style: Theme.of(context).textTheme.bodyText1),
            const SizedBox(height: 8),
            if (content != null) content!
          ],
        ),
      ),
      actions: actions,
    );
  }
}

///
/// [Dialog.]
///
/// [@author	Unknown]
/// [ @since	v0.0.1 ]
/// [@version	v1.0.0	Tuesday, November 1st, 2022]
/// [@see		StatelessWidget]
/// [@global]
///
class Dialog extends StatelessWidget {
  /// Constructor
  const Dialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
