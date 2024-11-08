import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/chat_repository.dart';

abstract class FetchGroupState {}

class FetchGroupInitial extends FetchGroupState {}

class FetchGroupInProgress extends FetchGroupState {}

class FetchGroupSuccess extends FetchGroupState {
  final Stream<DatabaseEvent> groups;

  FetchGroupSuccess(this.groups);
}

class FetchGroupFailure extends FetchGroupState {
  final String errorMessage;

  FetchGroupFailure(this.errorMessage);
}

class FetchGroupCubit extends Cubit<FetchGroupState> {
  final ChatRepository chatRepository;

  FetchGroupCubit(this.chatRepository) : super(FetchGroupInitial());

  Stream<DatabaseEvent> fetchGroups() {
    emit(FetchGroupInProgress());
    try {
      final groups = chatRepository.fetchGroups();
      emit(FetchGroupSuccess(groups));
      return groups;
    } catch (e) {
      emit(FetchGroupFailure(e.toString()));
      return Stream.empty();
    }
  }
}

