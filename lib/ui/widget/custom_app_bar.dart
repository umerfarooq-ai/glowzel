import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../Constant/app_color.dart';
import 'nav_router.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showBackButton;
  final bool? showFrontButton;
  final List<Widget>? actions;
  final String? text;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    Key? key,
    this.showBackButton = true,
    this.showFrontButton,
    this.actions,
    this.prefixIcon,
    this.text,
    this.suffixIcon,
    this.bottom,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      centerTitle: true,
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
            ]
          ),
          child:  SvgPicture.asset(
            'assets/images/svg/arrow.svg',fit: BoxFit.scaleDown,
          ),
        ),
      )
          : null,
      title: text != null
          ? Text(
        text!,
        style: const TextStyle(
          color: AppColors.black,
          fontSize: 28,
          fontWeight: FontWeight.w600,
        ),
      )
          : null,
      actions: [
        if (showFrontButton == true)
          IconButton(
            onPressed: (){
              // NavRouter.push(context, SkinLogTrackScreen());
            },
            icon:Image.asset('assets/images/png/menu.png'),
          ),
        if (actions != null) ...actions!,
      ],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
