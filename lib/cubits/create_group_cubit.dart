import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/group.dart';
import '../data/repository/chat_repository.dart';

abstract class CreateGroupState {}

class CreateGroupInitial extends CreateGroupState {}

class CreateGroupInProgress extends CreateGroupState {}

class CreateGroupSuccess extends CreateGroupState {}

class CreateGroupFailure extends CreateGroupState {
  final String errorMessage;

  CreateGroupFailure(this.errorMessage);
}

class CreateGroupCubit extends Cubit<CreateGroupState> {
  final ChatRepository chatRepository;

  CreateGroupCubit(this.chatRepository) : super(CreateGroupInitial());

  Future<void> createGroup({
    required Group groupData,
  }) async {
    emit(CreateGroupInProgress());
    try {
      await chatRepository.createGroup(groupData: groupData);
      emit(CreateGroupSuccess());
    } catch (e) {
      emit(CreateGroupFailure(e.toString()));
    }
  }

  Future addMemberToGroup({
    required String groupId,
    required List<String> memberIds,
  }) async {
    try {
      await chatRepository.addMemberToGroup(groupId: groupId,  memberIds: memberIds);
    } catch (e) {
      emit(CreateGroupFailure(e.toString()));
    }
  }
}