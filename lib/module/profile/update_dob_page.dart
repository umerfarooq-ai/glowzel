import 'dart:developer';
import 'dart:io';
import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/network/dio_client.dart';
import 'package:Glowzel/core/security/secure_auth_storage.dart';
import 'package:Glowzel/core/storage_services/storage_service.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/authentication/repository/session_repository.dart';
import 'package:Glowzel/module/profile/model/update_profile_input.dart';
import 'package:Glowzel/module/profile/model/update_profile_input1.dart';
import 'package:Glowzel/module/user/cubit/user_cubit.dart';
import 'package:Glowzel/module/user/models/user_model.dart';
import 'package:Glowzel/module/user/repository/user_account_repository.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/input/input_field.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:Glowzel/ui/widget/toast_loader.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:Glowzel/utils/validator/validators.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class DOBUpdatePage extends StatefulWidget {
  const DOBUpdatePage({super.key});

  @override
  State<DOBUpdatePage> createState() => _DOBUpdatePageState();
}

class _DOBUpdatePageState extends State<DOBUpdatePage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? selectedImage;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  UserModel? user;
  String selectedGender = '';
  String selectedDobApiFormat = '';

  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
      storageService: GetIt.I<StorageService>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
    );
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      user = await authRepository.getMe();
      if (user != null) {
        firstNameController.text = user!.firstname ?? '';
        lastNameController.text = user!.lastname ?? '';
        selectedGender = user!.profile?.gender ?? '';
        selectedDobApiFormat = user!.profile?.dob ?? '';
        dobController.text = selectedDobApiFormat;
        setState(() {});
      }
    } catch (e, st) {
      log('Error fetching user data: $e\n$st');
    }
  }

  void _updateProfile() {
    final updateInput = UpdateProfileInput(
      firstName: firstNameController.text,
      lastName: lastNameController.text,
    );

    final updateInput1 = UpdateProfileInput1(
      gender: selectedGender,
      dob: selectedDobApiFormat, // send backend format
    );

    context.read<UserCubit>().updateProfile(updateInput, selectedImage);
    context.read<UserCubit>().updateProfile1(updateInput1, selectedImage);
  }

  void _selectGender(String gender) {
    setState(() {
      selectedGender = gender;
      genderController.text = gender;
    });
  }

  void _onDobSelected(String uiDate, String apiDate, String year) {
    setState(() {
      dobController.text = uiDate;
      selectedDobApiFormat = apiDate; // store backend format
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 54, left: 35, right: 35),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Image.asset('assets/images/png/logo2.png')),
              const SizedBox(height: 28),
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
                controller: firstNameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                hint: 'First Name',
                validator: Validators.required,
              ),
              const SizedBox(height: 15),
              InputField(
                controller: lastNameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                hint: 'Last Name',
                validator: Validators.required,
              ),
              const SizedBox(height: 18),
              Text(
                'Select your Gender',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
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
              const SizedBox(height: 10),
              Text(
                'Select your DOB',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              DobSelector(
                onSelected: _onDobSelected,
                child: InputField(
                  controller: dobController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  hint: 'Dob',
                  suffixIcon: Image.asset('assets/images/png/dob.png'),
                  validator: Validators.required,
                ),
              ),
              const SizedBox(height: 50),
              CustomElevatedButton(
                text: 'UPDATE',
                onPressed: _updateProfile,
              ),
              BlocListener<UserCubit, UserState>(
                listener: (context, userState) {
                  if (userState.userStatus == UserStatus.updating) {
                    ToastLoader.show();
                  } else if (userState.userStatus == UserStatus.updated) {
                    ToastLoader.remove();
                    context.showSnackBar('User Updated Successfully');
                    NavRouter.pop(context);
                  } else if (userState.userStatus == UserStatus.error) {
                    ToastLoader.remove();
                    context.showSnackBar(userState.errorMessage);
                  }
                },
                child: Container(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DobSelector extends StatefulWidget {
  final void Function(String uiDate, String apiDate, String year) onSelected;
  final Widget child;

  const DobSelector({super.key, required this.onSelected, required this.child});

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
        onSelectedItemChanged: onSelected,
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
                    fontWeight: FontWeight.w400,
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
      final String month = months[selectedMonthIndex];
      final String day = days[selectedDayIndex];
      final String year = years[selectedYearIndex];

      final pickedDate = DateTime(
        int.parse(year),
        selectedMonthIndex + 1,
        int.parse(day),
      );

      final uiFormat = DateFormat("MMM-dd-yyyy").format(pickedDate);
      final apiFormat = DateFormat("yyyy-MM-dd").format(pickedDate);

      widget.onSelected(uiFormat, apiFormat, year);
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
