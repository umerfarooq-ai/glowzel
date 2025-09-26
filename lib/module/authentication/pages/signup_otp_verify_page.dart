import 'dart:async';

import 'package:Glowzel/module/authentication/pages/login_page.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
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
import '../../../utils/display/display_utils.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../cubit/signup/signup_cubit.dart';
import '../cubit/signup/signup_state.dart';
import '../model/profile_input.dart';
import '../model/signup_input.dart';
import '../widgets/reset_password_dialog.dart';

class SignupOtpVerifyPage extends StatefulWidget {
  final String email;
  final SignupInput signupInput;
  final ProfileInput profileInput;

  const SignupOtpVerifyPage({
    super.key,
    required this.email,
    required this.signupInput,
    required this.profileInput,
  });

  @override
  State<SignupOtpVerifyPage> createState() => _SignupOtpVerifyPageState();
}

class _SignupOtpVerifyPageState extends State<SignupOtpVerifyPage> {
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

  String otpValue = "";
  OtpFieldController otpController = OtpFieldController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(authRepository: sl()),
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.signupStatus == SignupStatus.otpVerifying) {
            DisplayUtils.showLoader();
          } else if (state.signupStatus == SignupStatus.otpVerified) {
            DisplayUtils.removeLoader();
            context.read<SignupCubit>().signup(widget.signupInput,
              context);
          } else if (state.signupStatus == SignupStatus.loading) {
            DisplayUtils.showLoader();
          }else if (state.signupStatus == SignupStatus.otpSent) {
            DisplayUtils.removeLoader();
            context.showSnackBar('OTP resent successfully!');
          }
          else if (state.signupStatus == SignupStatus.success) {
            DisplayUtils.removeLoader();
            NavRouter.push(
                context, LoginPage());
          } else if (state.signupStatus == SignupStatus.otpError ||
              state.signupStatus == SignupStatus.error) {
            DisplayUtils.removeLoader();
            context.showSnackBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomAppBar(showBackButton: true),
            body: Form(
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
                      'We have sent a code to ${widget.email}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: OTPTextField(
                        length: 6,
                        controller: otpController,
                        width: MediaQuery.of(context).size.width,
                        fieldWidth: 50,
                        margin: const EdgeInsets.only(right: 12),
                        outlineBorderRadius: 6,
                        style: GoogleFonts.poppins(
                            fontSize: 17,
                            color: context.colorScheme.onBackground),
                        keyboardType: TextInputType.number,
                        textFieldAlignment: MainAxisAlignment.center,
                        fieldStyle: FieldStyle.box,
                        otpFieldStyle: OtpFieldStyle(
                            backgroundColor: context.colorScheme.background,
                            borderColor: context.colorScheme.onSecondary,
                            enabledBorderColor:
                            context.colorScheme.onSecondary,
                            errorBorderColor: context.colorScheme.error),
                        onCompleted: (pin) {
                          setState(() {
                            otpValue = pin.toString();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Resend OTP section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          "Didn't receive code? ",
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: 14,
                          ),
                        ),
                        if (timerStatus)
                          Text(
                            'Resend in $_seconds seconds',
                            style: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          )
                        else
                          GestureDetector(
                            onTap: () {
                              // Resend OTP
                              context.read<SignupCubit>().resendOtpForSignup(widget.email);
                              _startTimer();
                            },
                            child:  Text(
                              'Resend',
                              style: GoogleFonts.poppins(
                                color: Colors.blue,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    SizedBox(
                      width: 280,
                      child: CustomElevatedButton(
                        text: 'Verify Now',
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        textColor: Colors.black,
                        onPressed: () {
                          if (otpValue.isEmpty || otpValue.length < 6) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Please enter a valid 6-digit OTP"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          if (_formKey.currentState!.validate()) {
                            // Verify OTP
                            context.read<SignupCubit>().verifyOtp(widget.email, otpValue, 'activation');
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}