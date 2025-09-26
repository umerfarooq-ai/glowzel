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
import 'package:Glowzel/ui/input/custom_elevated_input_field.dart';
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

class UpdateSkinTypePage extends StatefulWidget {
  const UpdateSkinTypePage({super.key});

  @override
  State<UpdateSkinTypePage> createState() => _UpdateSkinTypePageState();
}

class _UpdateSkinTypePageState extends State<UpdateSkinTypePage> {
  final TextEditingController skinTypeController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String selectedSkinType = '';

  final Map<String, String> _initialValues = {};
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;
  File? selectedImage;

  void _selectSkinType(String skinType) {
    setState(() {
      selectedSkinType = skinType;
      skinTypeController.text = skinType;
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
        UserModel user = await authRepository.getMe();
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
      if (skinTypeController.text != _initialValues['skin_type']) 'skin_type': skinTypeController.text,
    };

    final updateInput = UpdateProfileInput1(
      skinType: updatedFields['skin_type'] ?? _initialValues['skin_type'] ?? '',
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
        _initialValues['skin_type'] = user.profile?.skinType ?? '';

        if (selectedSkinType.isEmpty) {
          selectedSkinType = _initialValues['skin_type'] ?? '';
        }


        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20,left: 20,right: 20,top: 0),
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
                    SizedBox(height: 5),
                    Text(
                      'Every skin is unique, let’s find the right\ncare for yours.',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    CustomElevatedInputField(
                      hint: 'Oily',
                      isSelected: selectedSkinType == 'Oily',
                      onTap: () => _selectSkinType('Oily'),
                      text: 'Often feels shiny or greasy, especially on the\nT-zone. Needs balancing and oil-control care.',
                      prefixIcon: Image.asset('assets/images/png/oily.png'),
                    ),
                    const SizedBox(height: 20),

                    CustomElevatedInputField(
                      hint: 'Dry',
                      isSelected: selectedSkinType == 'Dry',
                      onTap: () => _selectSkinType('Dry'),
                      text: 'Tight, rough, or flaky at times. Benefits\nfrom deep hydration and nourishment.',
                      prefixIcon: Image.asset('assets/images/png/dry.png'),
                    ),
                    const SizedBox(height: 20),
                    CustomElevatedInputField(
                      hint: 'Normal',
                      isSelected: selectedSkinType == 'Normal',
                      onTap: () => _selectSkinType('Normal'),
                      text: 'Balanced and comfortable, with minimal\nissues. Just keep maintaining the glow.',
                      prefixIcon: Image.asset('assets/images/png/norm.png'),
                    ),
                    const SizedBox(height: 20),

                    CustomElevatedInputField(
                      hint: 'Combination',
                      isSelected: selectedSkinType == 'Combination',
                      onTap: () => _selectSkinType('Combination'),
                      text: 'Oily in some areas (like the T-zone), dry in\nothers. Needs targeted, balanced care.',
                      prefixIcon: Image.asset('assets/images/png/comb.png'),
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
                        child: Image.asset('assets/images/png/q.png'),
                      ),
                    ),
                    SizedBox(height: 44),
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



