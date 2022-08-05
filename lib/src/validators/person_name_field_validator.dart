import 'package:formz/formz.dart';

/// Validation errors for the [PersonName] [FormzInput].
enum PersonNameValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template PersonName}
/// Form input for an PersonName input.
/// {@endtemplate}
class PersonNameFieldValidator
    extends FormzInput<String, PersonNameValidationError> {
  /// {@macro PersonName}
  const PersonNameFieldValidator.pure() : super.pure('');

  /// {@macro PersonName}
  const PersonNameFieldValidator.dirty([String value = ''])
      : super.dirty(value);

  // static final RegExp _PersonNameRegExp = RegExp('[0-9]');

  @override
  PersonNameValidationError? validator(String? value) {
    return (value ?? '').length >= 3 ? null : PersonNameValidationError.invalid;

    // return _PersonNameRegExp.hasMatch(value ?? '')
    //     ? null
    //     : PersonNameValidationError.invalid;
  }
}
