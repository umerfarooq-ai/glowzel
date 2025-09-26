
import 'package:Glowzel/module/profile/widget/deleted_dailog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Constant/app_color.dart';
import '../../core/network/dio_client.dart';
import '../../core/security/secure_auth_storage.dart';
import '../../core/storage_services/storage_service.dart';
import '../../ui/button/custom_elevated_button.dart';
import '../../ui/widget/custom_app_bar.dart';
import '../../ui/widget/nav_router.dart';
import '../../utils/validator/email_validator.dart';
import '../authentication/pages/signup_page.dart';
import '../authentication/repository/session_repository.dart';
import '../user/repository/user_account_repository.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  final authStorage = AuthSecuredStorage();
  late final UserAccountRepository userRepository;
  late final DioClient _dioClient;

  @override
  void initState() {
    super.initState();
    _dioClient = GetIt.I<DioClient>();
    userRepository = UserAccountRepository(
      storageService: GetIt.I<StorageService>(),
      sessionRepository: GetIt.I<SessionRepository>(),
      dioClient: GetIt.I<DioClient>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(showBackButton: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Delete Account',
                  style: GoogleFonts.montserrat(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Enter your email, we will send you confirmation code.',
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 50),
                SizedBox(
                  width: 267,
                  child: CustomElevatedButton(
                    text: 'Delete Account',
                    onPressed: () async {
                      final token = await authStorage.readToken();
                      _dioClient.setToken(token);
                        await userRepository.deleteAccount();
                      await authStorage.clear();
                        _showDeleteAccountDialog(context);
                    },
                  ),

                ),
                SizedBox(height: 15),
                SizedBox(
                  width: 267,
                  child: CustomElevatedButton(
                    text: 'Cancel',
                    onPressed: () {
                      NavRouter.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showDeleteAccountDialog(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Padding(
        padding: const EdgeInsets.only(top: 70),
        child: const DeletedSuccessfullyDialog(),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      NavRouter.pushAndRemoveUntil(context, SignupPage());
    });
  }
}
