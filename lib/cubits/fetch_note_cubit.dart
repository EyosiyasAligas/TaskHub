import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/models/note.dart';
import '../data/repository/note_repository.dart';

abstract class FetchNoteState {}

class FetchNoteInitial extends FetchNoteState {}

class FetchNoteInProgress extends FetchNoteState {}

class FetchNoteSuccess extends FetchNoteState {
  final Stream<List<Note>> notes;

  FetchNoteSuccess(this.notes);
}

class FetchNoteFailure extends FetchNoteState {
  final String errorMessage;

  FetchNoteFailure(this.errorMessage);
}

class FetchNoteCubit extends Cubit<FetchNoteState> {
  final NoteRepository _noteRepository;

  FetchNoteCubit(this._noteRepository) : super(FetchNoteInitial());

  List<Note> _fetchedNotes = [];

  List<Note> get fetchedNotes => _fetchedNotes;

  void updateState(FetchNoteState updatedState) {
    emit(updatedState);
  }

  Future<void> fetchNotesOnce({required String userId}) async {
    emit(FetchNoteInProgress());
    try {
      var notes = await _noteRepository.fetchNotes(userId: userId);
      _fetchedNotes = notes;
      emit(FetchNoteSuccess(Stream.value(notes)));
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
    }
  }

  Stream<void>? fetchNotes({required String userId})  {
    emit(FetchNoteInProgress());
    try {
      var streamNote =_noteRepository.fetchNotesStream(userId: userId);
      fetchNotesOnce(userId: userId);
      // emit(FetchNoteSuccess(streamNote));
      print('streamNote: ${streamNote}');
    } catch (e) {
      emit(FetchNoteFailure(e.toString()));
    }
    return null;
  }

   Stream<List<Note>> getNotes() {
    if (state is FetchNoteSuccess) {
      List<Note> notes = [];
      return (state as FetchNoteSuccess).notes;
    }
    return const Stream.empty();
  }

}