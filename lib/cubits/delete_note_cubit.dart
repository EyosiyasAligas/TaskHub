import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/repository/note_repository.dart';

abstract class DeleteNoteState {}

class DeleteNoteInitial extends DeleteNoteState {}

class DeleteNoteInProgress extends DeleteNoteState {}

class DeleteNoteSuccess extends DeleteNoteState {}

class DeleteNoteFailure extends DeleteNoteState {
  final String errorMessage;

  DeleteNoteFailure(this.errorMessage);
}

class DeleteNoteCubit extends Cubit<DeleteNoteState> {
  final NoteRepository _noteRepository;

  DeleteNoteCubit(this._noteRepository) : super(DeleteNoteInitial());

  Future<void> deleteNote({
    required String noteId,
  }) async {
    emit(DeleteNoteInProgress());
    try {
      await _noteRepository.deleteNote(
        noteId: noteId,
      );
      emit(DeleteNoteSuccess());
    } catch (e) {
      emit(DeleteNoteFailure(e.toString()));
    }
  }
}
