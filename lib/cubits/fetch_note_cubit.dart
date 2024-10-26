import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/note.dart';
import '../data/repository/note_repository.dart';

abstract class FetchNoteState {}

class FetchNoteInitial extends FetchNoteState {}

class FetchNoteInProgress extends FetchNoteState {}

class FetchNoteSuccess extends FetchNoteState {
  final List<Note> notes;

  FetchNoteSuccess(this.notes);
}

class FetchNoteFailure extends FetchNoteState {
  final String errorMessage;

  FetchNoteFailure(this.errorMessage);
}

class FetchNoteCubit extends Cubit<FetchNoteState> {
  final NoteRepository _noteRepository;

  FetchNoteCubit(this._noteRepository) : super(FetchNoteInitial());

  void updateState(FetchNoteState updatedState) {
    emit(updatedState);
  }

  Future<void> fetchNotes() async {
    emit(FetchNoteInProgress());
    try {
      emit(FetchNoteSuccess(
        await _noteRepository.fetchNotes(),
      ));
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
    }
  }

}