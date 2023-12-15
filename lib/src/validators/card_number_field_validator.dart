import 'package:formz/formz.dart';

/// Validation errors for the [CardNumber] [FormzInput].
enum CardNumberValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template CardNumber}
/// Form input for an CardNumber input.
/// {@endtemplate}
class CardNumberFieldValidator
    extends FormzInput<String, CardNumberValidationError> {
  /// {@macro CardNumber}
  const CardNumberFieldValidator.pure() : super.pure('');

  /// {@macro CardNumber}
  const CardNumberFieldValidator.dirty([String value = ''])
      : super.dirty(value);

  static final RegExp _cardNumberRegExp = RegExp('[0-9]');

  @override
  CardNumberValidationError? validator(String? value) {
    return (value ?? '').length >= 14 && _cardNumberRegExp.hasMatch(value ?? '')
        ? null
        : CardNumberValidationError.invalid;
  }
}

/// Validation errors for the [CardNumber] [FormzInput].
enum CardExpiryDateValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template CardNumber}
/// Form input for an CardNumber input.
/// {@endtemplate}
class CardExpiryDateFieldValidator
    extends FormzInput<String, CardExpiryDateValidationError> {
  /// {@macro CardNumber}
  const CardExpiryDateFieldValidator.pure() : super.pure('');

  /// {@macro CardNumber}
  const CardExpiryDateFieldValidator.dirty([String value = ''])
      : super.dirty(value);

  static final RegExp _cardNumberRegExp =
      RegExp(r'^(0[1-9]|1[0-2])\/[0-9]{2}$');

  @override
  CardExpiryDateValidationError? validator(String? value) {
    return _cardNumberRegExp.hasMatch(value ?? '')
        ? null
        : CardExpiryDateValidationError.invalid;
  }
}

/// Validation errors for the [CardNumber] [FormzInput].
enum CardCVCValidationError {
  /// Generic invalid error.
  invalid
}

/// {@template CardNumber}
/// Form input for an CardNumber input.
/// {@endtemplate}
class CardCVCFieldValidator extends FormzInput<String, CardCVCValidationError> {
  /// {@macro CardNumber}
  const CardCVCFieldValidator.pure() : super.pure('');

  /// {@macro CardNumber}
  const CardCVCFieldValidator.dirty([String value = '']) : super.dirty(value);

  static final RegExp _cardNumberRegExp = RegExp(r'^[0-9]{3}$');

  @override
  CardCVCValidationError? validator(String? value) {
    return _cardNumberRegExp.hasMatch(value ?? '')
        ? null
        : CardCVCValidationError.invalid;
  }
}

class ExpiryDate {
  final int month;
  final int year;

  ExpiryDate(this.month, this.year);
}

extension CardExpiryDateSplit on CardExpiryDateFieldValidator {
  ExpiryDate? getModel() {
    if (isValid) {
      var split = value.split(RegExp(r'(\/)'));
      return ExpiryDate(int.parse(split[0]), int.parse(split[1]));
    } else {
      return null;
    }
  }
}
