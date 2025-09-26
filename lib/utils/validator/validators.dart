import 'package:flutter/material.dart';

abstract class Validators {
  Validators._();

  static FormFieldValidator<String>? getValidator(TextInputType? keyboardType) {
    return switch (keyboardType) {
      TextInputType.number => Validators.number,
      _ => Validators.required,
    };
  }

  static String? required(String? input) {
    if (input?.trim().isEmpty ?? true) {
      return 'Required';
    }
    return null;
  }

  static String? requiredTyped<T>(T? input) {
    if (input == null) {
      return 'Required';
    }
    return null;
  }

  static String? password(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }

    // Uncomment and adjust if needed
    if (password.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!password.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }

    return null;
  }

  static String? confirmPassword(String? confirmPassword, String password) {
    if (confirmPassword == null || confirmPassword.isEmpty) {
      return 'Password is required';
    } else if (confirmPassword != password) {
      return 'Passwords must match';
    }
    return null;
  }

  static String? number(String? input) {
    if (input == null) {
      return 'Required';
    }
    final number = num.tryParse(input);
    if (number == null) {
      return 'Enter a valid number';
    }
    return null;
  }

  static String? positiveInteger(String? input) {
    if (input == null) {
      return 'Required';
    }
    final integer = int.tryParse(input);
    if (integer == null || integer <= 0) {
      return 'Enter a positive integer';
    }
    return null;
  }

  static String? emailOrPhone(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Required';
    }
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    final phoneRegEx = RegExp(r'^\+?[0-9]{7,15}$');
    if (!emailRegEx.hasMatch(input) && !phoneRegEx.hasMatch(input)) {
      return 'Enter a valid email or phone number';
    }
    return null;
  }

  static String? emailOrPassword(String? input) {
    if (input == null || input.trim().isEmpty) {
      return 'Required';
    }
    final emailRegEx = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (emailRegEx.hasMatch(input)) {
      return null;
    }
    if (input.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (!input.contains(RegExp('[A-Z]'))) {
      return 'Password must contain at least one capital letter';
    }
    return 'Enter a valid email or password';
  }

}
