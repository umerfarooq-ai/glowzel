import 'dart:developer';
import 'dart:io';

import 'package:Glowzel/module/profile/model/update_profile_input1.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/exceptions/api_error.dart';
import '../../profile/model/update_profile_input.dart';
import '../models/user_model.dart';
import '../repository/user_account_repository.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  UserCubit({
    required UserAccountRepository userAccountRepository,
  })  : _userAccountRepository = userAccountRepository,
        super(UserState.initial());

  final UserAccountRepository _userAccountRepository;

  void loadUser() {
    UserModel userModel = _userAccountRepository.getUserFromDb();
    emit(state.copyWith(userModel: userModel, userStatus: UserStatus.success));
  }

  Future<void> logout() async {
    emit(state.copyWith(userStatus: UserStatus.loginOut));
    await Future.delayed(const Duration(seconds: 2));
    await _userAccountRepository.logout();
    emit(state.copyWith(
      userStatus: UserStatus.success,
      userModel: UserModel.empty,
    ));
  }

  void updateProfile(UpdateProfileInput input,File? selectedImage) async {
    emit(state.copyWith(userStatus: UserStatus.updating));
    try {
      UserModel userModel = await _userAccountRepository.updateProfile(input,selectedImage);
      emit(
          state.copyWith(userStatus: UserStatus.updated, userModel: userModel));
    } on ApiError catch (e) {

      emit(state.copyWith(
          userStatus: UserStatus.error, errorMessage: e.message));
    } catch (_) {}
  }

  void updateProfile1(UpdateProfileInput1 input,File? selectedImage) async {
    emit(state.copyWith(userStatus: UserStatus.updating));
    try {
      UserModel userModel = await _userAccountRepository.updateUserProfile1(input);
      emit(
          state.copyWith(userStatus: UserStatus.updated, userModel: userModel));
    } on ApiError catch (e) {

      emit(state.copyWith(
          userStatus: UserStatus.error, errorMessage: e.message));
    } catch (_) {}
  }

}
