import 'package:Glowzel/module/diary/diary_page.dart';
import 'package:Glowzel/module/scan/scan_face1.dart';
import 'package:Glowzel/module/treatment/pages/treatment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../Home/pages/home_page.dart';
import '../../profile/profile_page.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/navbar.dart';


class DashboardPage extends StatefulWidget {
  final int initialPage;
  const DashboardPage({Key? key, required String userId, this.initialPage=1}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialPage);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DashboardCubit(initialIndex: widget.initialPage),
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ProfilePage(),
            const HomePage(),
            const ScanFace1(),
            const DiaryPage(),
            const TreatmentPage(),
          ],
        ),
        bottomNavigationBar: CustomBottomNavBar(pageController: _pageController),
      ),
    );
  }
}
