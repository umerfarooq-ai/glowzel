import 'package:bot_toast/bot_toast.dart';

import 'loading_indicator.dart';

class ToastLoader {
  ToastLoader._();

  static void show() {
    BotToast.showCustomLoading(toastBuilder: (_) => const LoadingIndicator());
  }

  static void remove() {
    BotToast.closeAllLoading();
  }
}
