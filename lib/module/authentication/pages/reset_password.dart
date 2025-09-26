import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../Constant/app_color.dart';
import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../utils/display/display_utils.dart';
import '../../../utils/validator/validators.dart';
import '../cubit/forgotpassword/forgotPasswordCubit.dart';
import '../cubit/forgotpassword/forgotPasswordState.dart';
import '../widgets/reset_password_dialog.dart';
import 'login_page.dart';

class ResetPasswordView extends StatefulWidget {
  final String email;
  final String verifiedOtp;

  const ResetPasswordView({
    super.key,
    required this.email,
    required this.verifiedOtp,
  });

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isProcessing = false; // Add local loading state

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      if (newPasswordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Passwords do not match")),
        );
        return;
      }

      setState(() {
        _isProcessing = true;
      });

      final forgotPasswordCubit = context.read<ForgotPasswordCubit>();
      forgotPasswordCubit.verifyOtpAndResetPassword(
        email: widget.email,
        otpCode: widget.verifiedOtp,
        password: newPasswordController.text,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      resizeToAvoidBottomInset: false,
      appBar: CustomAppBar(showBackButton: true),
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
          listener: (context, state) {
            print('Cubit status: ${state.forgotPasswordStatus}');
            print('Message: ${state.message}');

            if (state.forgotPasswordStatus == ForgotPasswordStatus.verifying) {
              print('Verifying...');
            } else if (state.forgotPasswordStatus == ForgotPasswordStatus.updated) {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
              print('Password reset successful!');
              _showResetPasswordViewDialog(context);
            } else if (state.forgotPasswordStatus == ForgotPasswordStatus.failure) {
              if (mounted) {
                setState(() => _isProcessing = false);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Error: ${state.message ?? 'Password reset failed'}"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
          final isLoading = _isProcessing ||
              state.forgotPasswordStatus == ForgotPasswordStatus.verifying;
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      'Reset Your Password',
                      style: GoogleFonts.montserrat(
                        color: AppColors.black,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 15),
                     Text(
                      'Enter your new password below.',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 25),

                    // New password
                    InputField(
                      controller: newPasswordController,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        child: Icon(
                          _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                      hint: 'New Password',
                      obscureText: _obscurePassword,
                      textInputAction: TextInputAction.next,
                      validator: Validators.password,
                    ),

                    const SizedBox(height: 20),

                    // Confirm password
                    InputField(
                      controller: confirmPasswordController,
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
                        child: Icon(
                          _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.black,
                        ),
                      ),
                      hint: 'Confirm Password',
                      obscureText: _obscureConfirmPassword,
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm your password';
                        }
                        if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 45),

                    CustomElevatedButton(
                      text: isLoading ? 'Resetting...' : 'Reset Password',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      onPressed: isLoading ? null : _resetPassword,
                    ),

                    // Add loading indicator
                    if (isLoading) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showResetPasswordViewDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Padding(
        padding: EdgeInsets.only(top: 44),
        child: ResetPasswordDialog(),
      ),
    );
  }
}