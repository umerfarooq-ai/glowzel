import 'package:Glowzel/Constant/app_color.dart';
import 'package:Glowzel/core/di/service_locator.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../Dashboard/pages/dashboard_page.dart';
import '../startup/welcome_screen.dart';
import '../user/cubit/user_cubit.dart';
import 'cubit/startup_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => StartupCubit(
        dioClient: sl(),
        sessionRepository: sl(),
      )..init(),
      child: BlocListener<StartupCubit, StartupState>(
        listener: (context, state) {
          if (state.status == Status.authenticated) {
            context.read<UserCubit>().loadUser();
            final user = context.read<UserCubit>().state.userModel;
            print("Logged in user: ${user.toJson()}");
            NavRouter.pushAndRemoveUntil(
              context,
              DashboardPage(userId: user.id),
            );
          } else if (state.status == Status.unauthenticated) {
            NavRouter.pushAndRemoveUntil(context, WelcomeScreen());
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.white,
          body: Stack(
            children: [
              SizedBox.expand(
                child: Image.asset(
                  'assets/images/png/splash.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                bottom: 20,
                left: 8,
                child: Image.asset(
                  'assets/images/png/box.png',
                  fit: BoxFit.cover,
                ),
              ),
        Positioned(
          bottom: 24,
          left: 16,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Text(
                'GENTLE\nWAY TO\nCARE\nYOUR SKIN',
                style: GoogleFonts.montserrat(
                  fontSize: 58,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ),
        ),
        Positioned(
                bottom: 105,
                left: 200,
                child: Container(
                  width: 119,
                  height: 41,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Color(0xff264919),
                  ),
                  child: Center(child: Text('Discover',style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                  ),)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

