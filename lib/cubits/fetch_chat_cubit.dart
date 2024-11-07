import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/chat_message.dart';

import '../data/repository/chat_repository.dart';

abstract class FetchChatState {}

class FetchChatInitial extends FetchChatState {}

class FetchChatInProgress extends FetchChatState {}

class FetchChatSuccess extends FetchChatState {
  final Stream<DatabaseEvent> chatMessages;

  FetchChatSuccess(this.chatMessages);
}

class FetchChatFailure extends FetchChatState {
  final String errorMessage;

  FetchChatFailure(this.errorMessage);
}

class FetchChatCubit extends Cubit<FetchChatState> {
  final ChatRepository _chatRepository;

  FetchChatCubit(this._chatRepository) : super(FetchChatInitial());

  // List<String> _fetchedChatMessages = [];
  //
  // List<String> get fetchedChatMessages => _fetchedChatMessages;
  //
  // Stream<List<String>> streamChatMessages = Stream.empty();

  void updateState(FetchChatState updatedState) {
    emit(updatedState);
  }

  Stream<DatabaseEvent> fetchChatMessages(
      {required String receiverId, required String senderId}) {
    emit(FetchChatInProgress());
    try {
      var chatMessages = _chatRepository.fetchPrivateMessages(
          receiverId: receiverId, senderId: senderId);

      emit(FetchChatSuccess(chatMessages));
      return chatMessages;
      // return dummy data
      // return [
      //   ChatMessage(
      //     content: 'Hello',
      //     receiverId: receiverId,
      //     senderId: senderId,
      //     timestamp: DateTime.now(),
      //     id: '',
      //     senderName: '',
      //   ),
      //   ChatMessage(
      //     content: 'Hi',
      //     receiverId: receiverId,
      //     senderId: senderId,
      //     timestamp: DateTime.now(),
      //     senderName: '',
      //     id: '',
      //   ),
      // ];
    } catch (e) {
      emit(FetchChatFailure(e.toString()));
      return const Stream.empty();
    }
  }
}
