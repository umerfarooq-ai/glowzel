import 'package:Glowzel/module/Home/widget/progress_line_widget.dart';
import 'package:Glowzel/module/authentication/pages/skin_care_routine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

import '../../../Constant/app_color.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/input/custom_input_field.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../utils/validator/email_validator.dart';
import '../../../utils/validator/validators.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../model/signup_input.dart';

class SkinSensitivePage extends StatefulWidget {
  final String dob;
  final String gender;
  final String skinType;
  final SignupInput signupInput;
  const SkinSensitivePage({super.key, required this.dob, required this.gender, required this.skinType,required this.signupInput});

  @override
  State<SkinSensitivePage> createState() => _SkinSensitivePageState();
}

class _SkinSensitivePageState extends State<SkinSensitivePage> {
  final TextEditingController skinSensitivityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedSkinSensitivity = '';

  void _selectSkinSensitivity(String skinSensitivity) {
    setState(() {
      selectedSkinSensitivity = skinSensitivity;
      skinSensitivityController.text = skinSensitivity;
    });
  }

  @override
  Widget build(BuildContext context) {
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
              ProgressLineWidget(score: 60),
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
              Center(child: SvgPicture.asset('assets/images/svg/signup_logo.svg'),),
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
              const SizedBox(height: 60),
              Padding(
                padding: const EdgeInsets.only(left: 9,right: 9),
                child: Column(
                  children: [
                    CustomInputField(
                      hint: 'Sensitive',
                      isSelected: selectedSkinSensitivity == 'Sensitive',
                      onTap: () => _selectSkinSensitivity('Sensitive'),
                      prefixIcon: SvgPicture.asset('assets/images/svg/sens.svg'),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Somewhat sensitive',
                      isSelected: selectedSkinSensitivity == 'Somewhat sensitive',
                      onTap: () => _selectSkinSensitivity('Somewhat sensitive'),
                      prefixIcon:SvgPicture.asset('assets/images/svg/sens2.svg'),

                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Not sensitive at all',
                      isSelected: selectedSkinSensitivity == 'Not sensitive at all',
                      onTap: () => _selectSkinSensitivity('Not sensitive at all'),
                      prefixIcon:SvgPicture.asset('assets/images/svg/sens3.svg'),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar:Padding(
        padding: const EdgeInsets.only(bottom: 20,left: 16,right: 16),
        child: CustomElevatedButton(
            text: 'Continue',
            onPressed: () {
              if (_formKey.currentState!.validate() && selectedSkinSensitivity.isNotEmpty) {
                print('Navigating to SkinConcernScreen with dob: ${widget.dob}');
                print('Navigating to SkinConcernScreen with gender: ${widget.gender}');
                print('Navigating to SkinConcernScreen with gender: ${widget.signupInput}');
                print('Navigating to SkinConcernScreen with skin type: ${widget.skinType}');
                print('Navigating to SkinConcernScreen with skin sensitivity: $selectedSkinSensitivity');
                NavRouter.push(context, SkinCareRoutineScreen(
                  dob: widget.dob,
                  gender:widget.gender,
                  skinType:widget.skinType,
                  skinSensitivity:selectedSkinSensitivity,
                  signupInput: widget.signupInput,
                ));
              }
              else{
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please tell your skin sensitivity'),backgroundColor: Colors.red),
                );
              }
            }
        ),
      ),
    );
  }
}