import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/chat_message.dart';

import '../data/repository/chat_repository.dart';

abstract class SendGroupMessageState {}

class SendGroupMessageInitial extends SendGroupMessageState {}

class SendGroupMessageInProgress extends SendGroupMessageState {}

class SendGroupMessageSuccess extends SendGroupMessageState {}

class SendGroupMessageFailure extends SendGroupMessageState {
  final String errorMessage;

  SendGroupMessageFailure(this.errorMessage);
}

class SendGroupMessageCubit extends Cubit<SendGroupMessageState> {
  final ChatRepository chatRepository;

  SendGroupMessageCubit(this.chatRepository) : super(SendGroupMessageInitial());

  Future<void> sendGroupMessage({
    required String groupId,
    required String senderId,
    required ChatMessage message,
  }) async {
    emit(SendGroupMessageInProgress());
    try {
      await chatRepository.sendGroupMessage(
        groupId: groupId,
        message: message,
      );
      emit(SendGroupMessageSuccess());
    } catch (e) {
      emit(SendGroupMessageFailure(e.toString()));
    }
  }
}