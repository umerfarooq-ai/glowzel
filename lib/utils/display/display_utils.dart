import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../Constant/app_color.dart';
import '../../ui/widget/loading_indicator.dart';

class DisplayUtils {
  static void showSnackBar(BuildContext context, String title) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            title,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 3),
        ),
      );
  }

  static void showToast(BuildContext context, String title) {
    Fluttertoast.showToast(
      msg: title,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      fontSize: 16.0,
    );
  }

  static void showLoader() {
    BotToast.showCustomLoading(
      toastBuilder: (_) => const LoadingIndicator(),
    );
  }

  static void removeLoader() {
    BotToast.closeAllLoading();
  }
}
