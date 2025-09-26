import 'package:flutter/material.dart';

import '../models/bottom_navbar_item_model.dart';

class DashboardState {
  final List<BottomNavbarItemModel> tabs;

  const DashboardState({required this.tabs});

  factory DashboardState.initial([int selectedIndex = 1]) {
    return DashboardState(tabs: [
      BottomNavbarItemModel(
          SvgImageAssets: 'assets/images/svg/profile.svg',
          text: 'Profile',
          isSelected: selectedIndex == 0),
      BottomNavbarItemModel(
          SvgImageAssets: 'assets/images/svg/home.svg',
          text: 'Today',
          isSelected: selectedIndex == 1),
      BottomNavbarItemModel(
          SvgImageAssets: 'assets/images/svg/scan.svg',
          text: 'Scan',
          isSelected: selectedIndex == 2),
      BottomNavbarItemModel(
          SvgImageAssets: 'assets/images/svg/diary.svg',
          text: 'Diary',
          isSelected: selectedIndex == 3),
      BottomNavbarItemModel(
          SvgImageAssets: 'assets/images/svg/treatment.svg',
          text: 'Treatments',
          isSelected: selectedIndex == 4),
    ]);
  }


  DashboardState copyWith({List<BottomNavbarItemModel>? tabs}) {
    return DashboardState(tabs: tabs ?? this.tabs);
  }
}