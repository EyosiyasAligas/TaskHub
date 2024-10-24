import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/user.dart';

import '../data/repository/auth_repository.dart';

abstract class SignUpState {}

class SignUpInitial extends SignUpState {}

class SignUpInProgress extends SignUpState {}

class SignUpSuccess extends SignUpState {
  final String jwtToken;
  final UserModel user;

  SignUpSuccess({required this.jwtToken, required this.user});
}

class SignUpFailure extends SignUpState {
  final String errorMessage;

  SignUpFailure(this.errorMessage);
}

class SignUpCubit extends Cubit<SignUpState> {
  final AuthRepository _authRepository;

  SignUpCubit(this._authRepository) : super(SignUpInitial());

  Future<void> signUp({
    required String email,
    required String password,
  }) async {
    emit(SignUpInProgress());

    try {
      Map<String, dynamic> result =
      await _authRepository.signUp(email: email, password: password);

      emit(
        SignUpSuccess(
          jwtToken: result['jwtToken'],
          user: result['user'] as UserModel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(SignUpFailure(e.toString()));
    }
  }
}
