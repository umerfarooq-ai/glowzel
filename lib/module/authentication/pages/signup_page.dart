import 'dart:convert';

import 'package:Glowzel/module/authentication/pages/login_page.dart';
import 'package:Glowzel/module/authentication/pages/personal_info_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../../../Constant/app_color.dart';
import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../utils/display/display_utils.dart';
import '../../../utils/validator/email_validator.dart';
import '../../../utils/validator/validators.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../cubit/signup/signup_cubit.dart';
import '../cubit/signup/signup_state.dart';
import '../model/profile_input.dart';
import '../model/signup_input.dart';
import '../widgets/image_picker_widget.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _agreeToTerms = false;
  bool _imageSelected = false;
  bool _isUploading = false;
  File? selectedImage;
  List<int> imageBytes = [];

  Future<void> compressImage(File imageFile) async {
    var result = await FlutterImageCompress.compressWithFile(
      imageFile.absolute.path,
      minWidth: 800,
      minHeight: 600,
      quality: 90,
      rotate: 0,
    );
    if (result != null) {
      setState(() {
        imageBytes = result;
      });
      print('Compressed image bytes length: ${imageBytes.length}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(top: 54, left: 38, right: 35),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/images/svg/signup_logo.svg'),
                    SizedBox(height: 28),
                    Text(
                      'Welcome',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      'Sign up in to your account',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20),
                    InputField(
                      controller: emailController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.text,
                      hint: 'Email',
                      validator: EmailValidator.validate,
                    ),
                    const SizedBox(height: 15),
                    InputField(
                      controller: passwordController,
                      textInputAction: TextInputAction.next,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      hint: 'Password',
                      validator: Validators.password,
                    ),
                    const SizedBox(height: 15),
                    InputField(
                      controller: confirmPasswordController,
                      textInputAction: TextInputAction.done,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      hint: ' Confirm Password',
                      validator: (value) => Validators.confirmPassword(
                        value,
                        passwordController.text,
                      ),
                    ),
                    SizedBox(height: 44),
                    CustomElevatedButton(
                        text: 'CONTINUE',
                      onPressed: (){
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      print('Navigating to SkinShineScreen with email: ${emailController.text.trim()}');
      print('Navigating to SkinShineScreen with password: ${passwordController.text.trim()}');
      NavRouter.push(context, PersonalInformationPage(email: emailController.text.trim(), password: passwordController.text.trim()));
    }
                      },
                    ),
                    SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Already have an account?',style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.black,
                        )),
                        IconButton(
                          onPressed: () {
                            NavRouter.push(context, LoginPage());
                          },
                          icon:Text('Login now',style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.lightGreen2,
                          )),
                        ),
                      ],
                    ),
                    SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                            width: 50,
                            child: Divider(color: AppColors.black,thickness: 1)),
                        SizedBox(width: 8),
                        Text('or sign up with',style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppColors.black,
                        )),
                        SizedBox(width: 8),
                        SizedBox(
                            width: 50,
                            child: Divider(color: AppColors.black,thickness: 1)),                      ],
                    ),
                    SizedBox(height: 28),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/google.svg')),
                          IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/facebook.svg')),
                          IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/apple.svg')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
