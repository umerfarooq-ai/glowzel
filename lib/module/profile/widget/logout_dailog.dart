import 'package:Glowzel/module/authentication/pages/login_page.dart';
import 'package:Glowzel/ui/button/custom_elevated_button.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get_it/get_it.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage_services/storage_service.dart';
import '../../authentication/repository/session_repository.dart';

class LogoutDialog extends StatefulWidget {
  const LogoutDialog({super.key});

  @override
  State<LogoutDialog> createState() =>
      _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  late final StorageService storageService;
  late final SessionRepository sessionRepository;
  late final DioClient dioClient;

  @override
  void initState() {
    super.initState();
    storageService = GetIt.I<StorageService>();
    sessionRepository = GetIt.I<SessionRepository>();
    dioClient = GetIt.I<DioClient>();
  }

  Future<void> logout() async {
    try {
      await sessionRepository.setLoggedIn(false);
      await sessionRepository.removeToken();
      await sessionRepository.clearLocalStorage();
      NavRouter.pushAndRemoveUntil(context, const LoginPage());
    } catch (e) {
      print("Logout error: $e");
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 337,
        height: 434,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 103,
                height: 103,
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  shape: BoxShape.circle,
                ),
                child:SvgPicture.asset('assets/images/svg/logout2.svg',fit: BoxFit.scaleDown),

              ),
              const SizedBox(height: 25),
              Text(
                'Are you sure to log out of your account?',
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 50),
              SizedBox(
                width: 215,
                child: CustomElevatedButton(text: 'Logout',
                    onPressed:logout,
              ),
              ),
              SizedBox(height: 10),
              SizedBox(
                width: 215,
                child: CustomElevatedButton(text: 'Cancel',
                    onPressed: (){
                      NavRouter.pop(context);
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
