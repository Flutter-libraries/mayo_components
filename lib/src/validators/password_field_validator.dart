import 'package:formz/formz.dart';

/// Validation errors for the [Password] [FormzInput].
enum PasswordValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template password}
/// Form input for an password input.
/// {@endtemplate}
class PasswordFieldValidator
    extends FormzInput<String, PasswordValidationError> {
  /// {@macro password}
  const PasswordFieldValidator.pure() : super.pure('');

  /// {@macro password}
  const PasswordFieldValidator.dirty([super.value = '']) : super.dirty();

  // static final _passwordRegExp =
  //     RegExp(r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$');

  @override
  PasswordValidationError? validator(String? value) {
    return (value ?? '').length >= 6 ? null : PasswordValidationError.invalid;

    // return _passwordRegExp.hasMatch(value ?? '')
    //     ? null
    //     : PasswordValidationError.invalid;
  }
}
