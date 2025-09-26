import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../Constant/app_color.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';

class CustomBottomNavBar extends StatelessWidget {
  final PageController pageController;

  const CustomBottomNavBar({Key? key, required this.pageController}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 76,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(
                  color: Colors.white,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(state.tabs.length, (index) {
                  if (state.tabs[index].SvgImageAssets.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  final tab = state.tabs[index];
                  return GestureDetector(
                    onTap: () {
                      context.read<DashboardCubit>().changeNavSelection(index);
                      pageController.jumpToPage(index);

                    },
                    child: Column(
                      children: [
                        tab.isSelected
                            ? Transform.translate(
                          offset: Offset(0, -14),
                          child: _buildIcon(tab),
                        )
                            : _buildIcon(tab),
                        Text(
                          tab.text,
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: tab.isSelected
                                ? AppColors.lightGreen2
                                : Colors.black,
                            fontWeight:tab.isSelected? FontWeight.w600:FontWeight.w300,
                          ),
                        ),
                      ],
                    ),


                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }
}

Widget _buildIcon(tab) {
  return Container(
    width: 50,
    height: 50,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: tab.isSelected
          ? AppColors.lightGreen2
          : Colors.transparent,
    ),
    child: Center(
      child: SvgPicture.asset(tab.SvgImageAssets, color: tab.isSelected
          ? AppColors.white
          : Colors.black),
    ),
  );
}
