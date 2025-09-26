import 'dart:async';

import 'package:Glowzel/module/authentication/cubit/forgotpassword/forgotPasswordState.dart';
import 'package:Glowzel/module/authentication/pages/reset_password.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/input/otp_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../cubit/forgotpassword/forgotPasswordCubit.dart';
import '../widgets/reset_password_dialog.dart';

class ForgotPasswordVerifyOtpPage extends StatelessWidget {
  final String email;
  const ForgotPasswordVerifyOtpPage({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ForgotPasswordCubit>(
      create: (context) => ForgotPasswordCubit(sl()),
      child: ForgotPasswordVerifyOtpPageView(email: email),
    );
  }
}

class ForgotPasswordVerifyOtpPageView extends StatefulWidget {
  final String email;

  const ForgotPasswordVerifyOtpPageView({super.key, required this.email});

  @override
  State<ForgotPasswordVerifyOtpPageView> createState() =>
      _ForgotPasswordVerifyOtpPageViewState();
}

class _ForgotPasswordVerifyOtpPageViewState
    extends State<ForgotPasswordVerifyOtpPageView> {
  String? otp;
  int _seconds = 40;
  Timer? _timer;
  bool timerStatus = false;

  void _startTimer() {
    timerStatus = true;
    setState(() {
      _seconds = 40;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          timerStatus = false;
          _seconds = 40;
          _timer!.cancel();
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  final List<String> _verificationCode = ["", "", "", "", "", ""];
  String otpValue = "";
  OtpFieldController otpController = OtpFieldController();

  final _formKey = GlobalKey<FormState>();

  void _onCodeChanged(List<String> newCode) {
    setState(() {
      otpValue = newCode.join();
      _verificationCode.setAll(0, newCode);
    });
  }

  void _onVerifyPressed() {
    if (otpValue.length == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: context.read<ForgotPasswordCubit>(),
            child: ResetPasswordView(
              email: widget.email,
              verifiedOtp: otpValue,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit code")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(showBackButton: true),
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state.forgotPasswordStatus == ForgotPasswordStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Error: ${state.message}")),
            );
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Enter Verification Code',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'We have sent a code to your email',
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: OTPTextField(
                      length: 6,
                      controller: otpController,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: 50,
                      margin: EdgeInsets.only(right: 12),
                      outlineBorderRadius: 6,
                      style: GoogleFonts.poppins(
                          fontSize: 17, color: context.colorScheme.onBackground),
                      keyboardType: TextInputType.number,
                      textFieldAlignment: MainAxisAlignment.center,
                      fieldStyle: FieldStyle.box,
                      otpFieldStyle: OtpFieldStyle(
                          backgroundColor: context.colorScheme.background,
                          borderColor: context.colorScheme.onSecondary,
                          enabledBorderColor: context.colorScheme.onSecondary,
                          errorBorderColor: context.colorScheme.error),
                      onCompleted: (pin) {
                        setState(() {
                          otpValue = pin.toString();
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 75),
                  SizedBox(
                    width: 280,
                    child: CustomElevatedButton(
                      text: state.forgotPasswordStatus == ForgotPasswordStatus.verifying
                          ? 'Verifying...'
                          : 'Verify Now',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      textColor: Colors.black,
                      onPressed: state.forgotPasswordStatus == ForgotPasswordStatus.verifying
                          ? null
                          : _onVerifyPressed,
                    ),
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}