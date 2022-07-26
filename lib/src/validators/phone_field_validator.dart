import 'package:formz/formz.dart';

/// Validation errors for the [Phone] [FormzInput].
enum PhoneValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template phone}
/// Form input for an phone input.
/// {@endtemplate}
class PhoneFieldValidator extends FormzInput<String, PhoneValidationError> {
  /// {@macro phone}
  const PhoneFieldValidator.pure() : super.pure('');

  /// {@macro phone}
  const PhoneFieldValidator.dirty([String value = '']) : super.dirty(value);

  static final RegExp _phoneRegExp = RegExp('[0-9]');

  @override
  PhoneValidationError? validator(String? value) {
    return _phoneRegExp.hasMatch(value ?? '')
        ? null
        : PhoneValidationError.invalid;
  }
}
