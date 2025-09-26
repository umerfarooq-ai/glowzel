import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

class NavRouter {
  static final GlobalKey<NavigatorState> navigationKey =
      GlobalKey<NavigatorState>();

  static Future push(
    BuildContext context,
    Widget route, {
    bool bottomToTop = false,
  }) {
    return Navigator.push(
      context,
      MaterialPageRoute(fullscreenDialog: bottomToTop, builder: (_) => route),
    );
  }

  static Future pushWithAnimation(BuildContext context, Widget route,
      {PageTransitionType type = PageTransitionType.rightToLeft,
      bool hasAlignment = false}) {
    return Navigator.push(
        context,
        PageTransition(
            type: type,
            child: route,
            duration: Duration(milliseconds: 450),
            alignment: hasAlignment ? Alignment.center : null));
  }

  /// Push Replacement
  static Future pushReplacement(
    BuildContext context,
    Widget route, {
    bool bottomToTop = false,
  }) {
    return Navigator.pushReplacement(
        context,
        CupertinoPageRoute(
            fullscreenDialog: bottomToTop, builder: (context) => route));
  }

  static Future pushReplacementWithAnimation(
    BuildContext context,
    Widget route, {
    PageTransitionType type = PageTransitionType.rightToLeft,
  }) {
    return Navigator.pushReplacement(
        context, PageTransition(type: type, child: route));
  }

  /// Pop
  static void pop(BuildContext context, [result]) {
    return Navigator.of(context).pop(result);
  }

  /// Push and remove until
  static Future pushAndRemoveUntil(BuildContext context, Widget route) {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => route,
        ),
        (Route<dynamic> route) => false);
  }

  static Future pushAndRemoveUntilWithAnimation(
      BuildContext context, Widget route,
      {PageTransitionType type = PageTransitionType.rightToLeft,
      bool hasAlignment = false}) {
    return Navigator.pushAndRemoveUntil(
        context,
        PageTransition(
            type: type,
            child: route,
            duration: Duration(milliseconds: 1000),
            alignment: hasAlignment ? Alignment.center : null),
        (Route<dynamic> route) => false);
  }

  /// Push and remove until
  static Future pushAndRemoveUntilFirst(BuildContext context, Widget route) {
    return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => route,
        ),
        (Route<dynamic> route) => route.isFirst);
  }

  static Future pushAndRemoveUntilFirstWithAnimation(
    BuildContext context,
    Widget route, {
    PageTransitionType type = PageTransitionType.rightToLeft,
  }) {
    return Navigator.pushAndRemoveUntil(
        context,
        PageTransition(type: type, child: route),
        (Route<dynamic> route) => route.isFirst);
  }
}
