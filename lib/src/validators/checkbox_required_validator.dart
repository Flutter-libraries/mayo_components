import 'package:formz/formz.dart';

/// Validation errors for the [CheckboxRequired] [FormzInput].
enum CheckboxRequiredValidationError {
  /// Generic invalid error.
  required
}

/// {@template CheckboxRequired}
/// Form input for an CheckboxRequired input.
/// {@endtemplate}
class CheckboxRequiredFieldValidator
    extends FormzInput<bool?, CheckboxRequiredValidationError> {
  /// {@macro CheckboxRequired}
  const CheckboxRequiredFieldValidator.pure() : super.pure(null);

  /// {@macro CheckboxRequired}
  const CheckboxRequiredFieldValidator.dirty([bool? value]) : super.dirty(value);

  @override
  CheckboxRequiredValidationError? validator(bool? value) {
    return value != null ? null : CheckboxRequiredValidationError.required;
  }
}
