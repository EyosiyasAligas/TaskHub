import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/user.dart';

import '../data/repository/auth_repository.dart';

abstract class SignInState {}

class SignInInitial extends SignInState {}

class SignInInProgress extends SignInState {}

class SignInSuccess extends SignInState {
  final String jwtToken;
  final UserModel user;

  SignInSuccess({required this.jwtToken, required this.user});
}

class SignInFailure extends SignInState {
  final String errorMessage;

  SignInFailure(this.errorMessage);
}

class SignInCubit extends Cubit<SignInState> {
  final AuthRepository _authRepository;

  SignInCubit(this._authRepository) : super(SignInInitial());

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(SignInInProgress());

    try {
      Map<String, dynamic> result =
      await _authRepository.signIn(email: email, password: password);
      print('selam');
      print(result['jwtToken']);
      print(result['user']);
      emit(
        SignInSuccess(
          jwtToken: result['jwtToken'],
          user: result['user'] as UserModel,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('lemn lemn');
        print(e);
      }
      emit(SignInFailure(e.toString()));
    }
  }
}
