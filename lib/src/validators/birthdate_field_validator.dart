import 'package:formz/formz.dart';

/// Validation errors for the [BirthDate] [FormzInput].
enum BirthDateValidationError {
  /// Generic invalid error.
  empty
}

/// {@template BirthDate}
/// Form input for an BirthDate input.
/// {@endtemplate}
class BirthDateFieldValidator extends FormzInput<DateTime?, BirthDateValidationError> {
  /// {@macro BirthDate}
  const BirthDateFieldValidator.pure() : super.pure(null);

  /// {@macro BirthDate}
  const BirthDateFieldValidator.dirty([DateTime? value]) : super.dirty(value);

  @override
  BirthDateValidationError? validator(DateTime? value) {
    return value != null ? null : BirthDateValidationError.empty;
  }
}
