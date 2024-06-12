import 'package:formz/formz.dart';

// Define input validation errors
enum EmptyFieldValidatorError { empty }

// Extend FormzInput and provide the input type and error type.
class EmptyFieldValidator extends FormzInput<String, EmptyFieldValidatorError> {
  // Call super.pure to represent an unmodified form input.
  const EmptyFieldValidator.pure() : super.pure('');

  // Call super.dirty to represent a modified form input.
  const EmptyFieldValidator.dirty([super.value = '']) : super.dirty();

  // Override validator to handle validating a given input value.
  @override
  EmptyFieldValidatorError? validator(String value) {
    return value.isNotEmpty == true ? null : EmptyFieldValidatorError.empty;
  }
}
