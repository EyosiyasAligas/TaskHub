import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
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

  Future<List<UserModel>> fetchUsers() async {
    try {
      return await authRepository.fetchUsers();
    } catch (e) {
      return [];
    }
  }

  UserModel getUserDetails() {
    if (state is Authenticated) {
      print('user from auth ${(state as Authenticated).user.id} gg');
      return (state as Authenticated).user;
    }
    return UserModel.fromJson({});
  }

  Future<void> setUserStatus(String userId, bool isOnline) async {
    await authRepository.setUserStatus(userId, isOnline);
  }

  Stream<DatabaseEvent>getUserStatus(String receiverId) {
    return authRepository.getUserStatus(receiverId);
  }

  Stream<DatabaseEvent> fetchUserStream(String userId) {
    return authRepository.fetchUserStream(userId);
  }

  void signOut() {
    authRepository.signOut(state is Authenticated ? (state as Authenticated).jwtToken : "");
    emit(Unauthenticated());
  }
}
