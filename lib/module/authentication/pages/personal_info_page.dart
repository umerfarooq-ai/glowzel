import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

import 'package:Glowzel/module/authentication/pages/login_page.dart';
import 'package:Glowzel/module/authentication/pages/signup_otp_verify_page.dart';
import 'package:Glowzel/module/authentication/pages/skin_type_page.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
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
import 'package:Glowzel/module/authentication/model/profile_input.dart';
import 'package:Glowzel/module/authentication/model/signup_input.dart';
import '../widgets/image_picker_widget.dart';

class PersonalInformationPage extends StatefulWidget {
  final String email;
  final String password;
  const PersonalInformationPage({super.key, required this.email, required this.password});

  @override
  State<PersonalInformationPage> createState() => _PersonalInformationPageState();
}

class _PersonalInformationPageState extends State<PersonalInformationPage> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedGender = '';

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
      genderController.text = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 54, left: 35, right: 35),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child:SvgPicture.asset('assets/images/svg/signup_logo.svg'),
                      ),
                      SizedBox(height: 28),
                      Center(
                        child: Text(
                          'Personal Information',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 47),
                      InputField(
                        controller: firstnameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        hint: 'First Name',
                        validator: Validators.required,
                      ),
                      const SizedBox(height: 15),
                      InputField(
                        controller: lastnameController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.text,
                        hint: 'Last Name',
                        validator: Validators.required,
                      ),
                      SizedBox(height: 18),
                      Text(
                        'Select your Gender',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => _selectGender('Male'),
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: selectedGender == 'Male'
                                      ? Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Male',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _selectGender('Female'),
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: selectedGender == 'Female'
                                      ? Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Female',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () => _selectGender('Non-Binary'),
                            child: Row(
                              children: [
                                Container(
                                  width: 15,
                                  height: 15,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 1,
                                    ),
                                  ),
                                  child: selectedGender == 'Non-Binary'
                                      ? Center(
                                    child: Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Colors.black,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  )
                                      : null,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Non-Binary',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Select your Dob',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      DobSelector(
                        onSelected: (month, day, year) {
                          dobController.text = "$month ${day}, $year";
                        },
                        child: InputField(
                          controller: dobController,
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.text,
                          hint: 'Dob',
                          suffixIcon:SvgPicture.asset('assets/images/svg/dob.svg',fit: BoxFit.scaleDown),
                          validator: Validators.required,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20, top: 10),
                child: CustomElevatedButton(
                  text: 'CONTINUE',
                  onPressed: _onSignUp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onSignUp() {
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();

      DateTime parsedDob = DateFormat("MMM dd, yyyy").parse(dobController.text);
      String backendDob = DateFormat("yyyy-MM-dd").format(parsedDob);
      final signupInput = SignupInput(
        email: widget.email,
        password: widget.password,
        firstName: firstnameController.text.trim(),
        lastName: lastnameController.text.trim(),
      );

      print('Navigating to SkinShineScreen with signup input: $signupInput');
      print('Navigating to SkinShineScreen with gender: $selectedGender');
      print('DOB (frontend): ${dobController.text.trim()}');
      print('DOB (backend): ${DateFormat("yyyy-MM-dd").format(parsedDob)}');

      NavRouter.push(
        context,
        SkinTypeScreen(
          signupInput: signupInput,
          dob: backendDob,
          gender: selectedGender,
        ),
      );
    } else {
      context.read<SignupCubit>().enableAutoValidateMode();
    }
  }

}

class DobSelector extends StatefulWidget {
  final void Function(String month, String day, String year) onSelected;
  final Widget child;

  const DobSelector({
    super.key,
    required this.onSelected,
    required this.child,
  });

  @override
  State<DobSelector> createState() => _DobSelectorState();
}

class _DobSelectorState extends State<DobSelector> {
  bool showPicker = false;

  int selectedMonthIndex = 0;
  int selectedDayIndex = 0;
  int selectedYearIndex = 20;

  final List<String> months = const [
    "Jan", "Feb", "Mar", "Apr", "May", "Jun",
    "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
  ];
  final List<String> days =
  List.generate(31, (i) => (i + 1).toString().padLeft(2, '0'));
  final List<String> years =
  List.generate(100, (i) => (DateTime.now().year - i).toString());

  Widget _buildPicker(List<String> items, int selectedIndex, Function(int) onSelected) {
    return Expanded(
      child: CupertinoPicker(
        scrollController: FixedExtentScrollController(initialItem: selectedIndex),
        itemExtent: 30,
        onSelectedItemChanged: (index) {
          onSelected(index);
          widget.onSelected(
            months[selectedMonthIndex],
            days[selectedDayIndex],
            years[selectedYearIndex],
          );
        },
        selectionOverlay: Container(),
        children: List.generate(items.length, (index) {
          final bool isSelected = index == selectedIndex;
          return Center(
            child: Container(
              width: 48,
              height: 22,
              decoration: isSelected
                  ? BoxDecoration(
                color: AppColors.lightGreen,
                borderRadius: BorderRadius.circular(10),
              )
                  : null,
              child: Center(
                child: Text(
                  items[index],
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black.withOpacity(isSelected ? 0.92 : 0.41),
                    fontWeight: isSelected ? FontWeight.w400 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  void _togglePicker() {
    setState(() {
      showPicker = !showPicker;
    });

    if (!showPicker) {
      widget.onSelected(
        months[selectedMonthIndex],
        days[selectedDayIndex],
        years[selectedYearIndex],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _togglePicker,
          child: AbsorbPointer(child: widget.child),
        ),
        if (showPicker)
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPicker(months, selectedMonthIndex, (index) {
                  setState(() => selectedMonthIndex = index);
                }),
                _buildPicker(days, selectedDayIndex, (index) {
                  setState(() => selectedDayIndex = index);
                }),
                _buildPicker(years, selectedYearIndex, (index) {
                  setState(() => selectedYearIndex = index);
                }),
              ],
            ),
          ),
      ],
    );
  }
}



