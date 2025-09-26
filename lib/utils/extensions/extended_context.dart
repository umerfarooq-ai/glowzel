import 'package:flutter/material.dart';

extension ExtendedContext on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;

  TextTheme get primaryTextTheme => Theme.of(this).primaryTextTheme;


  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  void closeKeyboard() => FocusScope.of(this).unfocus();

  void showSnackBar(
      String message, {
        bool isError = false,
        Color? backgroundColor,
        Color? foregroundColor,
        TextStyle? textStyle,
      }) {
    final theme = Theme.of(this);

    backgroundColor ??= isError ? theme.colorScheme.error : null;
    foregroundColor ??= isError ? theme.colorScheme.onError : null;

    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        backgroundColor: backgroundColor,
        content: Text(
          message,
          style: textStyle ??
              TextStyle(
                color: foregroundColor,
              ),
        ),
      ),
    );
  }
}
