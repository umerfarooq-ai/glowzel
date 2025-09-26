import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage_services/storage_service.dart';
import '../../../utils/logger/logger.dart';
part 'app_state.dart';

class AppCubit extends Cubit<AppState> {
  final _log = logger(AppCubit);
  final StorageService storageService;

  AppCubit(this.storageService) : super(AppState(locale: const Locale('nl')));

  void init() {
    String locale = storageService.getString('locale');
    _log.i('init get locale :: $locale');
    emit(state.copyWith(
      locale: locale.isEmpty ? const Locale('en') : Locale(locale),
    ));
  }

  void updateLanguage(String locale) async {
    _log.i('update locale :: $locale');
    await storageService.setString('locale', locale);
    emit(state.copyWith(locale: Locale(locale)));
  }
}
