import 'package:Glowzel/module/startup/splash_screen.dart';
import 'package:Glowzel/ui/widget/nav_router.dart';
import 'package:Glowzel/ui/widget/unfocus.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/app_cubit.dart';
import 'bloc/bloc_di.dart';


class GlowzelApp extends StatefulWidget {
  const GlowzelApp({super.key});

  @override
  State<GlowzelApp> createState() => _GlowzelAppState();
}

class _GlowzelAppState extends State<GlowzelApp> {
  @override
  void initState() {
    super.initState();
        NavRouter.navigationKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>  SplashScreen()),
              (route) => false,
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocDI(
      child: BlocBuilder<AppCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            navigatorKey: NavRouter.navigationKey,
            title: 'Glowzel App',
            debugShowCheckedModeBanner: false,
            themeMode: ThemeMode.light,
            builder: (BuildContext context, Widget? child) {
              child = BotToastInit()(context, child);
              child = UnFocus(child: child);
              return child;
            },
            navigatorObservers: [
              BotToastNavigatorObserver(),
            ],
            home: SplashScreen(),
          );
        },
      ),
    );
  }
}