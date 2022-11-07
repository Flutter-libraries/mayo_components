import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

///
class Toast {
  ///
  static Future<bool?> showSuccess(BuildContext context, String message) =>
      Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Theme.of(context).colorScheme.surface,
        webBgColor: '#28c76f',
      );

  ///
  static Future<bool?> showError(BuildContext context, String message) =>
      Fluttertoast.showToast(
        msg: message,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 2,
        backgroundColor: Theme.of(context).colorScheme.error,
        webBgColor: '#ea5455',
      );
}
