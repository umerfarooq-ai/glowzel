import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/network/dio_client.dart';
import 'package:Glowzel/core/security/secure_auth_storage.dart';
import 'package:Glowzel/module/authentication/pages/signup_page.dart';
import 'package:Glowzel/module/authentication/repository/auth_repository.dart';
import 'package:Glowzel/module/authentication/repository/session_repository.dart';
import 'package:Glowzel/module/user/repository/user_account_repository.dart';
import 'package:Glowzel/module/welcome/pages/scan_face.dart';
import 'package:Glowzel/utils/extensions/extended_context.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/di/service_locator.dart';
import '../../../ui/button/custom_elevated_button.dart';
import '../../../ui/button/custom_gradient_button.dart';
import '../../../ui/input/input_field.dart';
import '../../../ui/widget/custom_app_bar.dart';
import '../../../ui/widget/nav_router.dart';
import '../../../ui/widget/toast_loader.dart';
import '../../../utils/validator/email_validator.dart';
import '../../../utils/validator/validators.dart';
import '../../Dashboard/pages/dashboard_page.dart';
import '../cubit/login/login_cubit.dart';
import '../model/login_input.dart';
import 'forgot_password.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(authRepository: sl()),
      child:LoginPageView(),
    );
  }
}


class LoginPageView extends StatefulWidget {
  const LoginPageView({super.key});

  @override
  State<LoginPageView> createState() => _LoginPageViewState();
}

class _LoginPageViewState extends State<LoginPageView> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool IsSelected = false;
  late AuthRepository authRepository;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(
      dioClient: GetIt.I<DioClient>(),
      authSecuredStorage: GetIt.I<AuthSecuredStorage>(),
      userAccountRepository: GetIt.I<UserAccountRepository>(),
      sessionRepository: GetIt.I<SessionRepository>(),
    );  }


  Future<String?> _getDeviceToken() async {
    try {
      String? token = await FirebaseMessaging.instance.getToken();
      print("FCM Device Token: $token");
      return token;
    } catch (e) {
      print("Error getting device token: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) async {
        if (state.loginStatus == LoginStatus.loading) {
          ToastLoader.show();
        }
        else if (state.loginStatus == LoginStatus.success) {
          ToastLoader.remove();
          print('user id is ${state.userId}');
          final token = await _getDeviceToken();
          debugPrint("📲 Device token before sending: $token");
          if (token != null) {
            await authRepository.updateDeviceToken(token);
          }
        NavRouter.pushAndRemoveUntil(
              context, ScanFace());
        }
        else if (state.loginStatus == LoginStatus.error) {
          ToastLoader.remove();
          print('Login error: ${state.errorMessage}');
          context.showSnackBar(state.errorMessage,backgroundColor: AppColors.red);
        }
      },
      builder: (context, state) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: AppColors.white,
          body: SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 54, left: 38, right: 35,bottom: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SvgPicture.asset('assets/images/svg/signup_logo.svg'),
                      SizedBox(height: 28),
                      Text(
                        'Welcome',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Login in to your account',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputField(
                        hint: 'Email',
                        controller: emailController,
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.emailAddress,
                        validator: EmailValidator.validate,
                      ),
                      const SizedBox(height: 15),
                      InputField(
                        controller: passwordController,
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.black1,
                            size: 18,
                          ),
                        ),
                        iconColor: AppColors.black1,
                        iconSize: 18,
                        hint: "Password",
                        textInputAction: TextInputAction.done,
                        obscureText: _obscurePassword,
                        validator: Validators.required,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Transform.scale(
                                scale: 0.8,
                                child: Checkbox(
                                  value: IsSelected,
                                  onChanged: (value) {
                                    setState(() {
                                      IsSelected = value!;
                                    });
                                  },
                                  activeColor: AppColors.lightGreen2,
                                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap, // keeps hitbox tight
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                ),
                              ),
                              Text(
                                'Remember me',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              NavRouter.push(context, ForgotPasswordPage());
                            },
                            child: Text(
                              'Forgot Password?',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.lightGreen2,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      CustomElevatedButton(
                        text: 'Login',
                        onPressed: _onLoggedIn,
                      ),
                      SizedBox(height: 87),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don’t have an account?',style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          )),
                          IconButton(
                            onPressed: () {
                              NavRouter.push(context, SignupPage());
                            },
                            icon:Text('Sign up now',style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.lightGreen2,
                            )),
                          ),
                        ],
                      ),
                      SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                              width: 50,
                              child: Divider(color: AppColors.black,thickness: 1)),
                          SizedBox(width: 8),
                          Text('or login with',style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: AppColors.black,
                          )),
                          SizedBox(width: 8),
                          SizedBox(
                              width: 50,
                              child: Divider(color: AppColors.black,thickness: 1)),                      ],
                      ),
                      SizedBox(height: 28),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/google.svg')),
                            IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/facebook.svg')),
                            IconButton(onPressed: (){}, icon:SvgPicture.asset('assets/images/svg/apple.svg')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  void _onLoggedIn() async{
    if (_formKey.currentState!.validate()) {
      FocusManager.instance.primaryFocus?.unfocus();
      LoginInput loginInput = LoginInput(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginMethod', 'app');
      context.read<LoginCubit>().login(loginInput,context);
    } else {
      context.read<LoginCubit>().enableAutoValidateMode();
    }
  }
}
