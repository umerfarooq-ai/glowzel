import 'dart:convert';
import 'dart:developer';

import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/exceptions/api_error.dart';
import 'package:Glowzel/core/network/dio_client.dart';
import 'package:Glowzel/core/security/secure_auth_storage.dart';
import 'package:Glowzel/core/storage_services/storage_service.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/authentication/repository/session_repository.dart';
import 'package:Glowzel/module/profile/model/update_profile_input1.dart';
import 'package:Glowzel/module/user/cubit/user_cubit.dart';
import 'package:Glowzel/module/user/models/user_model.dart';
import 'package:Glowzel/module/user/repository/user_account_repository.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/input/custom_input_field.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:Glowzel/ui/widget/toast_loader.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class UpdateSkinSensitivityPage extends StatefulWidget {
  const UpdateSkinSensitivityPage({super.key});

  @override
  State<UpdateSkinSensitivityPage> createState() => _UpdateSkinSensitivityPageState();
}

class _UpdateSkinSensitivityPageState extends State<UpdateSkinSensitivityPage> {
  final TextEditingController skinSensitivityController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedSkinSensitivity = '';

  final Map<String, String> _initialValues = {};
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;
  File? selectedImage;

  void _selectSkinSensitivity(String skinSensitivity) {
    setState(() {
      selectedSkinSensitivity = skinSensitivity;
      skinSensitivityController.text = skinSensitivity;
    });
  }

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
    userFuture = fetchUserData();
  }

  Future<UserModel?> fetchUserData() async {
    try {
      String? token = await sessionRepository.getToken();

      if (token != null) {
        UserModel user = await authRepository.getMe(); // ✅ Updated type
        return user;
      } else {
        throw ApiError(message: 'Token not found');
      }
    } catch (e, stackTrace) {
      log('Error fetching user data: $e\nStackTrace: $stackTrace');
      return null;
    }
  }


  void _updateProfile() {
    final updatedFields = {
      if (skinSensitivityController.text != _initialValues['skin_sensitivity']) 'skin_sensitivity': skinSensitivityController.text,
    };

    final updateInput = UpdateProfileInput1(
      skinSensitivity: updatedFields['skin_sensitivity'] ?? _initialValues['skin_sensitivity'] ?? '',
    );


    context.read<UserCubit>().updateProfile1(updateInput,selectedImage);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) {
          return Center(
            child: Text(
              snapshot.hasError
                  ? "Failed to fetch user data"
                  : "No User Data Found",
              style: GoogleFonts.poppins(
                  color: Colors.white),
            ),
          );
        }

        final user = snapshot.data!;
        _initialValues['skin_sensitivity'] = user.profile?.skinSensitivity ?? '';

        if (selectedSkinSensitivity.isEmpty) {
          selectedSkinSensitivity = _initialValues['skin_sensitivity'] ?? '';
        }


        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(right: 20,left: 20,bottom: 20,top: 0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/png/logo2.png'),
                    SizedBox(height: 28),
                    Text(
                      'Select your skin type',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 100),
                    CustomInputField(
                      hint: 'Sensitive',
                      isSelected: selectedSkinSensitivity == 'Sensitive',
                      onTap: () => _selectSkinSensitivity('Sensitive'),
                      prefixIcon: Image.asset('assets/images/png/sensitive.png'),
                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Somewhat sensitive',
                      isSelected: selectedSkinSensitivity == 'Somewhat sensitive',
                      onTap: () => _selectSkinSensitivity('Somewhat sensitive'),
                      prefixIcon: Image.asset('assets/images/png/somewhatsensitive.png'),

                    ),
                    const SizedBox(height: 20),
                    CustomInputField(
                      hint: 'Not sensitive at all',
                      isSelected: selectedSkinSensitivity == 'Not sensitive at all',
                      onTap: () => _selectSkinSensitivity('Not sensitive at all'),
                      prefixIcon: Image.asset('assets/images/png/notsensitive.png'),
                    ),

                    SizedBox(height: 165),
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
          ),
        );
      },
    );
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



