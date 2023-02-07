import 'package:formz/formz.dart';

/// Validation errors for the [ConfirmedPassword] [FormzInput].
enum ConfirmedPasswordValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template confirmed_password}
/// Form input for a confirmed password input.
/// {@endtemplate}
class ConfirmedPasswordFieldValidator
    extends FormzInput<String, ConfirmedPasswordValidationError> {
  /// {@macro confirmed_password}
  const ConfirmedPasswordFieldValidator.pure({this.password = ''})
      : super.pure('');

  /// {@macro confirmed_password}
  const ConfirmedPasswordFieldValidator.dirty(
      {required this.password, String value = ''})
      : super.dirty(value);

  /// The original password.
  final String password;

  @override
  ConfirmedPasswordValidationError? validator(String? value) {
    return password.isNotEmpty && password == value
        ? null
        : ConfirmedPasswordValidationError.invalid;
  }
}
