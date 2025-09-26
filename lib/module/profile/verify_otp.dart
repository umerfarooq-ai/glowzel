import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glowzel/module/authentication/pages/signup_page.dart';
import 'package:glowzel/module/profile/widget/deleted_dailog.dart';
import 'package:glowzel/utils/extensions/extended_context.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:otp_text_field_v2/otp_field_style_v2.dart';
import 'package:otp_text_field_v2/otp_field_v2.dart';

import '../../ui/button/custom_elevated_button.dart';
import '../../ui/input/otp_field.dart';
import '../../ui/widget/custom_app_bar.dart';
import '../../ui/widget/nav_router.dart';

class DeleteAccountVerifyOtpPage extends StatefulWidget {
  final String email;

  const DeleteAccountVerifyOtpPage({super.key, required this.email});

  @override
  State<DeleteAccountVerifyOtpPage> createState() =>
      _DeleteAccountVerifyOtpPageState();
}

class _DeleteAccountVerifyOtpPageState
    extends State<DeleteAccountVerifyOtpPage> {
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
                style: GoogleFonts.montserrat(
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
                  text: 'Verify Now',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  textColor: Colors.black,
                  onPressed: () {
                    if (otpValue.isEmpty || otpValue.length < 6) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please enter a valid 6-digit OTP"),backgroundColor: Colors.red,),
                      );
                      return;
                    }
                    if (_formKey.currentState!.validate()) {
                      _showDeleteAccountDialog(context);
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
  }

  void _showDeleteAccountDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 70),
        child: const DeletedSuccessfullyDialog(),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      NavRouter.pushAndRemoveUntil(context, SignupPage());
    });
  }
}
