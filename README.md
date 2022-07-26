# Mayo components

This package contains common components like fields, text areas, etc. Shared between different applications

## Features

Fields:
- CustomTextFormFiel
- CustomTextArea

Fields validators:
- birthdate_field_validator
- checkbox_required_validator
- confirmed_password_field_validator
- email_field_validator
- password_field_validator
- person_name_field_validator
- phone_field_validator

## Getting started

Install mayo_component package

```yaml
mayo_components:
    git: https://github.com/Flutter-libraries/mayo_components
```

## Usage

Import mayo_component reference

```dart
import 'package:mayo_components/mayo_components.dart';
```

### Fields

- CustomTextFormFiel
```dart

class _EmailInput extends StatelessWidget {
  const _EmailInput({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.email != current.email,
      builder: (context, state) {
        return CustomTextFormField(
          keyboardType: TextInputType.emailAddress,
          autofillHints: [AutofillHints.email],
          title: 'Email address',
          label: 'Email',
          onChanged: context.read<LoginCubit>().emailChanged,
          // Submit form when enter key is pressed
          onFieldSubmitted: (value) =>
              context.read<LoginCubit>().logInWithCredentials(),
          errorText: state.email.invalid ? 'Invalid email' : null,
        );
      },
    );
  }
}
```

- CustomTextArea
```dart
class _SetupInstructions extends StatelessWidget {
  final String? text;
  const _SetupInstructions({Key? key, this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: screenWidth(context, dividedBy: 3),
            child: CustomTextArea(
              initialValue: text,
              hintText: 'Setup instrictions',
              onChanged: context.read<DemoEditorCubit>().updateDemoInstructions,
            )),
      ],
    );
  }
}
```

### Fields validators

In cubit add the validation for the field type

```dart
  void emailChanged(String value) {
    final email = EmailFieldValidator.dirty(value);
    emit(state.copyWith(
      email: email,
      status: Formz.validate([email, state.password]),
    ));
  }

  void passwordChanged(String value) {
    final password = PasswordFieldValidator.dirty(value);
    emit(state.copyWith(
      password: password,
      status: Formz.validate([state.email, password]),
    ));
  }
```