import 'package:Glowzel/module/Home/widget/progress_line_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Glowzel/module/authentication/cubit/signup/signup_cubit.dart';
import 'package:Glowzel/module/authentication/cubit/signup/signup_state.dart';
import 'package:Glowzel/module/authentication/pages/signup_otp_verify_page.dart';
import 'package:Glowzel/module/welcome/pages/weclome_aboard.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../Constant/app_color.dart';
import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/input/custom_input_field.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../utils/validator/email_validator.dart';
import '../../../utils/validator/validators.dart';
import '../../Dashboard/pages/dashboard_page.dart';


import '../../welcome/pages/scan_face.dart';
import 'package:Glowzel/module/authentication/model/profile_input.dart';
import 'package:Glowzel/module/authentication/model/signup_input.dart';

class SkinCareRoutineScreen extends StatefulWidget {
  final String dob;
  final String gender;
  final String skinType;
  final String skinSensitivity;
  final SignupInput signupInput;
  final ProfileInput? profileInput;
  const SkinCareRoutineScreen({super.key, required this.dob, required this.gender, required this.skinType, required this.skinSensitivity, required this.signupInput, this.profileInput});

  @override
  State<SkinCareRoutineScreen> createState() => _SkinCareRoutineScreenState();
}

class _SkinCareRoutineScreenState extends State<SkinCareRoutineScreen> {
  final TextEditingController skinCareController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedSkinCareRoutine = '';
  ProfileInput? _createdProfileInput;
  void _selectSkinCareRoutine(String skinCareRoutine) {
    setState(() {
      selectedSkinCareRoutine = skinCareRoutine;
      skinCareController.text = skinCareRoutine;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SignupCubit>(
          create: (_) => SignupCubit(authRepository: sl()),
        ),
      ],
      child: BlocConsumer<SignupCubit, SignupState>(
        listener: (context, state) {
          if (state.signupStatus == SignupStatus.success) {
            if (_createdProfileInput != null) {
              NavRouter.pushAndRemoveUntil(
                context,
                SignupOtpVerifyPage(
                  email: widget.signupInput.email,
                  signupInput: widget.signupInput,
                  profileInput: _createdProfileInput!,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Profile not completed yet")),
              );
            }
          }
          else if (state.signupStatus == SignupStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Something went wrong'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: AppColors.white,
            body: Padding(
              padding: const EdgeInsets.only(bottom: 20,left: 16,right: 16,top: 50),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ProgressLineWidget(score: 100),
                    SizedBox(height: 15),
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ]
                        ),
                        child:SvgPicture.asset('assets/images/svg/arrow.svg',fit: BoxFit.scaleDown),

                      ),
                    ),
                    Center(child:SvgPicture.asset('assets/images/svg/signup_logo.svg'),
                    ),
                    SizedBox(height: 28),
                    Center(
                      child: Text(
                        'Skincare routine',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    const SizedBox(height: 60),
                    Padding(
                      padding: const EdgeInsets.only(left: 9,right: 9),
                      child: Column(
                        children: [
                          CustomInputField(
                            hint: 'I do it regularly',
                            isSelected: selectedSkinCareRoutine == 'I do it regularly',
                            prefixIcon:SvgPicture.asset('assets/images/svg/sens3.svg'),
                            onTap: () => _selectSkinCareRoutine('I do it regularly'),
                          ),
                          const SizedBox(height: 20),

                          CustomInputField(
                            hint: 'I tried a few times',
                            isSelected: selectedSkinCareRoutine == 'I tried a few times',
                            prefixIcon:SvgPicture.asset('assets/images/svg/sens2.svg'),
                            onTap: () => _selectSkinCareRoutine('I tried a few times'),
                          ),
                          const SizedBox(height: 20),

                          CustomInputField(
                            hint: 'I have no idea',
                            isSelected: selectedSkinCareRoutine == 'I have no idea',
                            prefixIcon:SvgPicture.asset('assets/images/svg/sens.svg'),
                            onTap: () => _selectSkinCareRoutine('I have no idea'),
                          ),
                          // SizedBox(height: 192),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.only(bottom: 20,left: 16,right: 16),
                child: state.signupStatus == SignupStatus.loading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomElevatedButton(
                  text: 'Continue',
                  onPressed: () {
                    if (_formKey.currentState!.validate() &&
                        selectedSkinCareRoutine.isNotEmpty) {
                      final profileInput = ProfileInput(
                        dob: widget.dob,
                        gender: widget.gender,
                        skinType: widget.skinType,
                        skinSensitivity: widget.skinSensitivity,
                        skinRoutine: selectedSkinCareRoutine,
                      );
                      _createdProfileInput = profileInput;
                      widget.signupInput.profile = profileInput;

                      context.read<SignupCubit>().signup(
                        widget.signupInput,
                        context,
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Please tell your skin goals'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                ),

              ),
          );
        },
      ),
    );
  }
}