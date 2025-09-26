import 'package:Glowzel/module/authentication/cubit/forgotpassword/forgotPasswordState.dart';
import 'package:Glowzel/module/authentication/pages/verify_otp_page.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../ui/widget/toast_loader.dart';
import '../../../utils/validator/email_validator.dart';
import '../cubit/forgotpassword/forgotPasswordCubit.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatelessWidget {
  const ForgotPasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ForgotPasswordCubit(sl()),
      child: ForgotPasswordView(),
    );
  }
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var forgotPasswordCubit = context.read<ForgotPasswordCubit>();
    return BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
      listener: (context, state) {
        if (state.forgotPasswordStatus == ForgotPasswordStatus.sending) {
          ToastLoader.show();
        }
        if (state.forgotPasswordStatus == ForgotPasswordStatus.sent) {
          ToastLoader.remove();
          NavRouter.push(
            context,
            ForgotPasswordVerifyOtpPage(email: emailController.text.trim()),
          );
        }
        if (state.forgotPasswordStatus == ForgotPasswordStatus.failure) {
          ToastLoader.remove();
          context.showSnackBar(state.message, isError: true);
          print("Forgot Password Error: ${state.message}");
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.white,
          appBar: CustomAppBar(
            showBackButton: true,
          ),
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(left: 30, right: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Forgot Password?',
                        style: GoogleFonts.montserrat(
                          color: Colors.black,
                          fontSize: 25,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        textAlign: TextAlign.center,
                        'Enter your email to reset your password',
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 20,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      SizedBox(height: 30),
                      InputField(
                        controller: emailController,
                        hint: 'Email',
                        textInputAction: TextInputAction.done,
                        validator: EmailValidator.validate,
                      ),
                      SizedBox(height: 30),
                      CustomElevatedButton(
                          text: 'Continue',
                        onPressed: () => _onSubmit(forgotPasswordCubit),
                      ),
                      SizedBox(height: 15),
                      CustomElevatedButton(
                        text: 'Cancel',
                        onPressed: () {
                          NavRouter.push(context, LoginPage());
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _onSubmit(ForgotPasswordCubit cubit) {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      cubit.forgotPassword(emailController.text.trim());
    } else {
      cubit.enableAutoValidateMode();
    }
  }
}
