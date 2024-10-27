import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/note.dart';
import '../data/repository/note_repository.dart';

abstract class EditNoteState {}

class EditNoteInitial extends EditNoteState {}

class EditNoteInProgress extends EditNoteState {}

class EditNoteSuccess extends EditNoteState {}

class EditNoteFailure extends EditNoteState {
  final String errorMessage;

  EditNoteFailure(this.errorMessage);
}

class EditNoteCubit extends Cubit<EditNoteState> {
  final NoteRepository _noteRepository;

  EditNoteCubit(this._noteRepository) : super(EditNoteInitial());

  Future<void> editNote({
    required Note note,
  }) async {
    emit(EditNoteInProgress());
    try {
      await _noteRepository.updateNote(
        note: note,
      );
      emit(EditNoteSuccess());
    } catch (e) {
      emit(EditNoteFailure(e.toString()));
    }
  }
}