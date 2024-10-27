import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_hub/data/models/note.dart';

import '../data/repository/auth_repository.dart';
import '../data/repository/note_repository.dart';

abstract class CreateNoteState {}

class CreateNoteInitial extends CreateNoteState {}

class CreateNoteInProgress extends CreateNoteState {}

class CreateNoteSuccess extends CreateNoteState {}

class CreateNoteFailure extends CreateNoteState {
  final String errorMessage;

  CreateNoteFailure(this.errorMessage);
}

class CreateNoteCubit extends Cubit<CreateNoteState> {
  final NoteRepository _noteRepository;
  final AuthRepository _authRepository;

  CreateNoteCubit(this._noteRepository, this._authRepository)
      : super(CreateNoteInitial());

  Future<void> createNote({
    required Note note,
  }) async {
    emit(CreateNoteInProgress());
    try {
      _noteRepository.createNote(
        note: note,
        userId: _authRepository.getUserDetails().id,
      );
      print('userId: ${_authRepository.getUserDetails().id}');
      emit(CreateNoteSuccess());
    } catch (e) {
      emit(CreateNoteFailure(e.toString()));
    }
  }
}
