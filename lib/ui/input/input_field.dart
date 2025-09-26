import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../Constant/app_color.dart';

class InputField extends StatefulWidget {
  const InputField({
    required this.controller,
    required this.hint,
     this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.readOnly = false,
    this.onTap,
    this.fillColor = AppColors.grey,
    this.borderColor = AppColors.lightGreen,
    this.borderRadius = 30.0,
    this.iconColor = AppColors.black1,
    this.iconSize = 18.0,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputAction? textInputAction;
  final TextInputType keyboardType;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final bool readOnly;
  final VoidCallback? onTap;
  final Color fillColor;
  final Color borderColor;
  final double borderRadius;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Color iconColor;
  final double iconSize;

  @override
  State<InputField> createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {
  late bool _isObscure;

  @override
  void initState() {
    super.initState();
    _isObscure = widget.obscureText;
  }

  void _toggleObscureText() {
    setState(() {
      _isObscure = !_isObscure;
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isPasswordField = widget.obscureText;

    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      obscureText: isPasswordField ? _isObscure : false,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      onFieldSubmitted: widget.onFieldSubmitted,
      validator: widget.validator,
      style: GoogleFonts.poppins(
        color: Colors.black,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: GoogleFonts.poppins(
          color: AppColors.black,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        filled: true,
        isDense: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 12,
          horizontal: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: BorderSide(
            color: AppColors.lightGreen,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(
            color: Colors.black,
            width: 1,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 1.5,
          ),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: isPasswordField
            ? GestureDetector(
          onTap: _toggleObscureText,
          child: Icon(
            _isObscure ? Icons.visibility_off : Icons.visibility,
            color: widget.iconColor,
            size: widget.iconSize,
          ),
        )
            : widget.suffixIcon,
      ),
    );
  }
}