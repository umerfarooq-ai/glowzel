
import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/network/dio_client.dart';
import 'package:Glowzel/core/security/secure_auth_storage.dart';
import 'package:Glowzel/utils/validator/validators.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../ui/button/custom_elevated_button.dart';
import '../../ui/input/input_field.dart';
import '../../ui/widget/custom_app_bar.dart';
import '../authentication/repository/auth_repository.dart';
import '../authentication/repository/session_repository.dart';
import '../user/repository/user_account_repository.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({super.key});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late AuthRepository authRepository;
  bool _isLoading = false;


  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );
  }
  Future<void> _changePassword() async {
    String oldPassword = oldPasswordController.text;
    String newPassword = newPasswordController.text;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await authRepository.changePassword(oldPassword, newPassword);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Password changed successfully!"),
            backgroundColor: AppColors.lightGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to change password."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: $error"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: CustomAppBar(
        showBackButton: true,
      ),
      body: Center(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              children: [
                Text(
                  'Change Your Password',
                  style: GoogleFonts.montserrat(
                    color: AppColors.black,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 40),
                InputField(
                  controller: oldPasswordController,
                  prefixIcon: Image.asset('assets/images/png/lk.png',color: Colors.black),
                  suffixIcon: Icon(Icons.visibility_off),
                  iconColor: Colors.black,
                  iconSize: 22,
                  hint: "Enter your old password",
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: Validators.required,
                ),
                SizedBox(height: 30),
                InputField(
                  controller: newPasswordController,
                  prefixIcon: Image.asset('assets/images/png/lk.png',color: Colors.black),
                  suffixIcon: Icon(Icons.visibility_off),
                  iconColor: Colors.black,
                  iconSize: 22,
                  hint: "Enter your new password",
                  textInputAction: TextInputAction.done,
                  obscureText: true,
                  validator: Validators.required,
                ),
                SizedBox(height: 30),
                if (_isLoading)
                  CircularProgressIndicator(color: Colors.lightGreen)
                else
                  CustomElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _changePassword();
                      }
                    },
                    text: 'Change Password',
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
