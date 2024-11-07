import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/chat_message.dart';

import '../data/repository/chat_repository.dart';

abstract class SendChatState {}

class SendChatInitial extends SendChatState {}

class SendChatInProgress extends SendChatState {}

class SendChatSuccess extends SendChatState {}

class SendChatFailure extends SendChatState {
  final String errorMessage;

  SendChatFailure(this.errorMessage);
}

class SendChatCubit extends Cubit<SendChatState> {
  final ChatRepository _chatRepository;

  SendChatCubit(this._chatRepository) : super(SendChatInitial());

  Future<void> sendChatMessage({
    required receiverId,
    required senderId,
    required ChatMessage chatMessage,
  }) async {
    emit(SendChatInProgress());
    try {
      await _chatRepository.sendPrivateMessage(
        receiverId: receiverId,
        senderId: senderId,
        message: chatMessage,
      );
      emit(SendChatSuccess());
    } catch (e) {
      emit(SendChatFailure(e.toString()));
    }
  }

  Future<String?> uploadMedia(String path, String filePath) async {
    return await _chatRepository.uploadMedia(path, filePath);
  }
}