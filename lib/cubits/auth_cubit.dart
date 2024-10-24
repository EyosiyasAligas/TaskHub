import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/user.dart';

import '../data/repository/auth_repository.dart';

abstract class AuthState {}

class AuthInitial extends AuthState {}

class Unauthenticated extends AuthState {}

class Authenticated extends AuthState {
  final String jwtToken;
  final UserModel user;

  Authenticated({required this.jwtToken, required this.user});
}

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository authRepository;

  AuthCubit(this.authRepository) : super(AuthInitial()) {
    checkIsAuthenticated();
  }

  void checkIsAuthenticated() {
    if (authRepository.getIsLogIn()) {
      emit(
        Authenticated(
          user: authRepository.getUserDetails(),
          jwtToken: authRepository.getJwtToken(),
        ),
      );
    } else {
      emit(Unauthenticated());
    }
  }

  void authenticateUser({required String jwtToken, required UserModel user}) {
    //
    authRepository.setJwtToken(jwtToken);
    authRepository.setIsLogIn(true);
    authRepository.setUserDetails(user);

    //emit new state
    emit(Authenticated(
      user: user,
      jwtToken: jwtToken,
    ),);
  }

  UserModel getUserDetails() {
    if (state is Authenticated) {
      print('user from auth');
      // print((state as Authenticated).user.userName);
    }
    return UserModel.fromJson({});
  }

  void signOut() {
    authRepository.signOut(state is Authenticated ? (state as Authenticated).jwtToken : "");
    emit(Unauthenticated());
  }
}
