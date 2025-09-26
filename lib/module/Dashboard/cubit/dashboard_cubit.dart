import 'package:flutter_bloc/flutter_bloc.dart';

import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit({int initialIndex = 1})
      : super(DashboardState.initial(initialIndex));

  void changeNavSelection(int index) {
    var tabs = state.tabs.map((tab) => tab.copyWith(isSelected: false)).toList();
    tabs[index] = tabs[index].copyWith(isSelected: true);
    emit(state.copyWith(tabs: tabs));
  }
}



