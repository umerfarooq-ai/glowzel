import 'package:Glowzel/module/Home/widget/progress_line_widget.dart';
import 'package:Glowzel/module/authentication/pages/skin_care_routine.dart';
import 'package:flutter/material.dart';
import 'package:Glowzel/module/authentication/pages/skin_sensitive_page.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/input/custom_elevated_input_field.dart';
import '../../../ui/input/custom_input_field.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../utils/validator/email_validator.dart';
import '../../../utils/validator/validators.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../model/signup_input.dart';

class SkinTypeScreen extends StatefulWidget {
  final String dob;
  final String gender;
  final SignupInput signupInput;

  const SkinTypeScreen({super.key, required this.dob, required this.gender, required this.signupInput});

  @override
  State<SkinTypeScreen> createState() => _SkinTypeScreenState();
}

class _SkinTypeScreenState extends State<SkinTypeScreen> {
  final TextEditingController skinTypeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedSkinType = '';

  void _selectSkinType(String skinType) {
    setState(() {
      selectedSkinType = skinType;
      skinTypeController.text = skinType;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20,left: 16,right: 16,top: 50),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProgressLineWidget(score: 30),
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
                    'Select your skin type',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Text(
                    'Every skin is unique, let’s find the right\ncare for yours.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.only(left: 9,right: 9),
                  child: Column(
                    children: [
                      CustomElevatedInputField(
                        hint: 'Oily',
                        isSelected: selectedSkinType == 'Oily',
                        onTap: () => _selectSkinType('Oily'),
                        text: 'Often feels shiny or greasy, especially\non the T-zone.',
                        prefixIcon:SvgPicture.asset('assets/images/svg/oily.svg'),
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedInputField(
                        hint: 'Dry',
                        isSelected: selectedSkinType == 'Dry',
                        onTap: () => _selectSkinType('Dry'),
                        text: 'Tight, rough, or flaky at times. Benefits\nfrom deep nourishment.',
                        prefixIcon:SvgPicture.asset('assets/images/svg/dry.svg'),

                      ),
                      const SizedBox(height: 20),
                      CustomElevatedInputField(
                        hint: 'Normal',
                        isSelected: selectedSkinType == 'Normal',
                        onTap: () => _selectSkinType('Normal'),
                        text: 'Balanced and comfortable, with\nminimal issues',
                        prefixIcon:SvgPicture.asset('assets/images/svg/normal.svg'),
                      ),
                      const SizedBox(height: 20),
                      CustomElevatedInputField(
                        hint: 'Combination',
                        isSelected: selectedSkinType == 'Combination',
                        onTap: () => _selectSkinType('Combination'),
                        text: 'Oily in some areas (like the T-zone),\n dry in others.',
                        prefixIcon:SvgPicture.asset('assets/images/svg/comb.svg'),

                      ),
                      const SizedBox(height: 20),
                      CustomElevatedInputField(
                        hint: 'Don’t know?',
                        isSelected: selectedSkinType == 'Don’t know, let’s find out together',
                        onTap: () => _selectSkinType('Don’t know, let’s find out together'),
                        text: 'Let’s discover it together with a quick\nskin check.',
                        prefixIcon:Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            border: Border.all(color: AppColors.black, width: 1),
                          ),
                          child:SvgPicture.asset('assets/images/svg/dn.svg'),

                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 20,left: 16,right: 16),                        child: CustomElevatedButton(
        text: 'Continue',
        onPressed: () {
          if (_formKey.currentState!.validate() && selectedSkinType.isNotEmpty) {
            print('Navigating with dob: ${widget.dob}');
            print('Navigating with gender: ${widget.gender}');
            print('Navigating with skin type: $selectedSkinType');
            print('Navigating with signup input: ${widget.signupInput}');

            if (selectedSkinType == "Don’t know, let’s find out together") {
              NavRouter.push(
                context,
                SkinSensitivePage(
                  dob: widget.dob,
                  gender: widget.gender,
                  skinType: selectedSkinType,
                  signupInput: widget.signupInput,
                ),
              );
            } else {
              NavRouter.push(
                context,
                SkinCareRoutineScreen(
                  dob: widget.dob,
                  gender: widget.gender,
                  skinType: selectedSkinType,
                  signupInput: widget.signupInput, skinSensitivity: '',
                ),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select skin type'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      ),
      ),
    );
  }
}