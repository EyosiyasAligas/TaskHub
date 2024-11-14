import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/group.dart';
import '../data/repository/chat_repository.dart';

abstract class FetchGroupState {}

class FetchGroupInitial extends FetchGroupState {}

class FetchGroupInProgress extends FetchGroupState {}

class FetchGroupSuccess extends FetchGroupState {
  List<Group> groups;

  FetchGroupSuccess(this.groups);
}

class FetchGroupFailure extends FetchGroupState {
  final String errorMessage;

  FetchGroupFailure(this.errorMessage);
}

class FetchGroupCubit extends Cubit<FetchGroupState> {
  final ChatRepository chatRepository;

  FetchGroupCubit(this.chatRepository) : super(FetchGroupInitial());

  // final StreamController<List<Group>> _groupController = StreamController<List<Group>>.broadcast();
  Stream<List<Group>>? groupStream;

  void fetchGroups() async {
    emit(FetchGroupInProgress());
    try {
      groupStream = chatRepository.fetchGroups();
      groupStream!.listen((groups) {
        if (kDebugMode) {
          print('Groups from cubit: ${groups.first.name}');
        }
        emit(FetchGroupSuccess(groups));
      });
      // return _groupController.stream;
    } catch (e) {
      emit(FetchGroupFailure(e.toString()));
      // return Stream.empty();
    }
  }

  @override
  Future<void> close() {
    groupStream = null; // Clear stream on close
    return super.close();
  }
}

