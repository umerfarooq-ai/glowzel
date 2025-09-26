import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:Glowzel/module/diary/widgets/date_widget1.dart';
import 'package:Glowzel/module/user/models/user_model.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../module/diary/widgets/greeting_widget.dart';
import 'nav_router.dart';

class CustomAppBar1 extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool? showFrontButton;
  final List<Widget>? actions;
  final String? text;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final PreferredSizeWidget? bottom;
  final UserModel user;

  const CustomAppBar1({
    Key? key,
    required this.user,
    required this.text,
    this.showBackButton = true,
    this.showFrontButton,
    this.actions,
    this.prefixIcon,
    this.suffixIcon,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true, // ✅ Force center alignment
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      leading: showBackButton
          ? IconButton(
        onPressed: () => NavRouter.pop(context),
        icon: Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child:SvgPicture.asset('assets/images/svg/arrow.svg',fit: BoxFit.scaleDown),
        ),
      )
          : null,

      title:  Text(
        text!,
        style: GoogleFonts.poppins(
          color: Colors.black,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),

      actions: [
        if (showFrontButton == true)
          Container(
            height: 28,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              children: [
                 GreetingWidget(),
                const SizedBox(width: 4),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: user.image != null && user.image!.isNotEmpty
                        ? (user.image!.startsWith('http')
                        ? Image.network(
                      user.image!,
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    )
                        : Image(
                      image: MemoryImage(
                        base64Decode(user.image!),
                      ),
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ))
                        : Image.asset(
                      'assets/images/png/women4.png',
                      fit: BoxFit.cover,
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(width: 14),
        if (actions != null) ...actions!,
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
