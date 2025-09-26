import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/module/authentication/widgets/image_picker_widget.dart';
import 'package:Glowzel/module/profile/change_password.dart';
import 'package:Glowzel/module/profile/model/update_profile_input.dart';
import 'package:Glowzel/module/profile/update_dob_page.dart';
import 'package:Glowzel/module/profile/update_skin_sensitivty.dart';
import 'package:Glowzel/module/profile/update_skin_type.dart';
import 'package:Glowzel/module/profile/widget/logout_dailog.dart';
import 'package:Glowzel/module/profile/widget/profile_pafe_tile.dart';
import 'package:Glowzel/module/user/cubit/user_cubit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/exceptions/api_error.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../../ui/widget/custom_app_bar.dart';
import '../../ui/widget/nav_router.dart';
import '../authentication/model/auth_response.dart';
import '../authentication/model/skin_profile_model.dart';
import '../authentication/pages/login_page.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../user/models/user_model.dart';
import '../user/repository/user_account_repository.dart';
import 'delete_account.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late StorageService storageService;
  late AuthRepository authRepository;
  late SessionRepository sessionRepository;
  late Future<UserModel?> userFuture;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  File? selectedImage;
  final Map<String, String> _initialValues = {};

  @override
  void initState() {
    super.initState();
    sessionRepository = SessionRepository(
        storageService: GetIt.I<StorageService>(),
        authSecuredStorage: GetIt.I<AuthSecuredStorage>());
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

  int calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;
    if (today.month < dob.month || (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: userFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        else if (snapshot.hasError || snapshot.data == null) {
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
        return Scaffold(
          backgroundColor: AppColors.grey3,
          body:NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  backgroundColor: AppColors.grey3,
                  elevation: 0,
                  surfaceTintColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  scrolledUnderElevation: 0,
                  pinned: true,
                  floating: false,
                  snap: false,
                  // leading: IconButton(
                  //   onPressed: () => NavRouter.pop(context),
                  //   icon: Container(
                  //     width: 22,
                  //     height: 22,
                  //     decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.white,
                  //         boxShadow: [
                  //           BoxShadow(
                  //             color: Colors.black.withOpacity(0.25),
                  //             blurRadius: 4,
                  //             offset: const Offset(0, 2),
                  //           ),
                  //         ]
                  //     ),
                  //     child:  SvgPicture.asset(
                  //       'assets/images/svg/arrow.svg',fit: BoxFit.scaleDown,
                  //     ),
                  //   ),
                  // ),
                  title: Text(
                    'Profile',
                    style: GoogleFonts.montserrat(
                      color: AppColors.black,
                      fontSize: 25,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  centerTitle: true,
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 16, left: 20, right: 20, bottom: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ProfileImageWidget(
                      image: user.image,
                      onImageSelected: (File file) async {
                        selectedImage = file;
                        final input = UpdateProfileInput(
                          image: await MultipartFile.fromFile(file.path, filename: "profile.jpg"),
                        );

                        context.read<UserCubit>().updateProfile(input,selectedImage);
                      },
                    ),


                    Text('${user.firstname} ${user.lastname}',
                        style: GoogleFonts.montserrat(
                            color: AppColors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w400)),
                    SizedBox(height: 28),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Your info', style:
                      GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 361,
                      height: 480,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(17),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePageTile(
                            title: 'Skin Type',
                            imagePath: 'assets/images/svg/scan2.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                            trailingText:'${user.profile?.skinType}',
                            onTap: (){
                              NavRouter.push(context, UpdateSkinTypePage());
                            },
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Skin sensitivity',
                            imagePath: 'assets/images/svg/sens4.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                            trailingText: '${user.profile?.skinSensitivity}',
                            onTap: (){NavRouter.push(context, UpdateSkinSensitivityPage());},
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Age',
                            imagePath: 'assets/images/svg/age.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                            trailingText: user.profile?.dob != null
                                ? '${calculateAge(DateTime.parse(user.profile!.dob!))} years'
                                : 'N/A',
                            onTap: () {
                              NavRouter.push(context, DOBUpdatePage());
                            },
                          ),

                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Gender',
                            imagePath: 'assets/images/svg/gender.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                            trailingText: '${user.profile?.gender}',
                            onTap: (){NavRouter.push(context, DOBUpdatePage());},
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Your product shelf',
                            imagePath: 'assets/images/svg/product.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                            trailingText: '0 products',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Show UV index',
                            imagePath: 'assets/images/svg/uv.svg',
                          ),

                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Spread the love', style:
                      GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 361,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePageTile(
                            title: 'Share the app',
                            imagePath: 'assets/images/svg/share.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Leave a review',
                            imagePath: 'assets/images/svg/review.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Rate the app',
                            imagePath: 'assets/images/svg/rate.svg',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Reach us', style:
                      GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 361,
                      height: 230,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePageTile(
                            title: 'Send us an email',
                            imagePath: 'assets/images/svg/email.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Request a features or content',
                            imagePath: 'assets/images/svg/feature.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Report a bug',
                            imagePath: 'assets/images/svg/bug.svg',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text('Legal', style:
                      GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      )),
                    ),
                    SizedBox(height: 12),
                    Container(
                      width: 361,
                      height: 148,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePageTile(
                            title: 'Privacy policy',
                            imagePath: 'assets/images/svg/privacy.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Terms of use',
                            imagePath: 'assets/images/svg/terms.svg',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 11),
                    Container(
                      width: 361,
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(13),
                        color: Colors.white,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProfilePageTile(
                            title: 'Language',
                            imagePath: 'assets/images/svg/language.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Restore purchases',
                            imagePath: 'assets/images/svg/restore.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          // ProfilePageTile(
                          //   title: 'Change Password',
                          //   imagePath: 'assets/images/svg/product.svg',
                          //   trailingImagePath: 'assets/images/svg/arrow2.svg',
                          //   onTap: () {
                          //     NavRouter.push(context, ChangePassword());
                          //   },
                          // ),
                          // Divider(
                          //   color: AppColors.grey2,
                          //   thickness: 0.5,
                          // ),
                          // SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Account settings',
                            imagePath: 'assets/images/svg/profile2.svg',
                            trailingImagePath: 'assets/images/svg/arrow2.svg',
                          ),
                          Divider(
                            color: AppColors.grey2,
                            thickness: 0.5,
                          ),
                          SizedBox(height: 6),
                          ProfilePageTile(
                            title: 'Log out',
                            imagePath: 'assets/images/svg/logout.svg',
                            onTap: () {
                              _showLogoutDialog(context);
                            },
                          ),
                          // Divider(
                          //   color: AppColors.grey2,
                          //   thickness: 0.5,
                          // ),
                          // SizedBox(height: 6),
                          // ProfilePageTile(
                          //   title: 'Delete Account',
                          //   imagePath: 'assets/images/svg/product.svg',
                          //   onTap: () {
                          //     NavRouter.push(context, DeleteAccountPage());
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32),
                    Center(child: SvgPicture.asset('assets/images/svg/signup_logo.svg')),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const LogoutDialog(),
    );
  }
}

