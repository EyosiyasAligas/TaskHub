import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

import '../../data/models/group.dart';
import '../../data/repository/chat_repository.dart';

part 'fetch_groups_event.dart';
part 'fetch_groups_state.dart';

class FetchGroupsBloc extends Bloc<FetchGroupsEvent, FetchGroupsState> {
  final ChatRepository _chatRepository;
  StreamSubscription<List<Group>>? _groupSubscription;

  FetchGroupsBloc(this._chatRepository) : super(FetchGroupsInitial()) {
    on<FetchGroups>(_onFetchGroups);
  }

  Future<void> _onFetchGroups(FetchGroups event, Emitter<FetchGroupsState> emit) async {
    emit(FetchGroupsInProgress());

    try {
      // Cancel any existing subscription before creating a new one
      await _groupSubscription?.cancel();

      // Use `await for to listen to the stream directly
      await for (final groups in _chatRepository.fetchGroups()) {
        if (kDebugMode) {
          print('Groups fetched from bloc: ${groups.first.name}');
        }
        emit(FetchGroupsSuccess(groups));
      }
    } catch (e) {
      emit(FetchGroupsFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _groupSubscription?.cancel();
    return super.close();
  }
}
