import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/chat_repository.dart';

abstract class FetchGroupMessageState {}

class FetchGroupMessageInitial extends FetchGroupMessageState {}

class FetchGroupMessageInProgress extends FetchGroupMessageState {}

class FetchGroupMessageSuccess extends FetchGroupMessageState {
  final Stream<DatabaseEvent> messages;

  FetchGroupMessageSuccess(this.messages);
}

class FetchGroupMessageFailure extends FetchGroupMessageState {
  final String errorMessage;

  FetchGroupMessageFailure(this.errorMessage);
}

class FetchGroupMessageCubit extends Cubit<FetchGroupMessageState> {
  final ChatRepository chatRepository;

  FetchGroupMessageCubit(this.chatRepository) : super(FetchGroupMessageInitial());

  Stream<DatabaseEvent> fetchGroupMessages({
    required String groupId,
  }) {
    emit(FetchGroupMessageInProgress());
    try {
      final messages = chatRepository.fetchGroupMessages(groupId: groupId);
      emit(FetchGroupMessageSuccess(messages));
      return messages;
    } catch (e) {
      emit(FetchGroupMessageFailure(e.toString()));
      return Stream.empty();
    }
  }
}

