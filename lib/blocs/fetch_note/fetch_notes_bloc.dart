import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/note.dart';
import '../../data/repository/note_repository.dart';

part 'fetch_notes_event.dart';

part 'fetch_notes_state.dart';

class FetchNotesBloc extends Bloc<FetchNotesEvent, FetchNotesState> {
  final NoteRepository _noteRepository;

  FetchNotesBloc(this._noteRepository) : super(FetchNotesInitial()) {
    on<FetchNotesEvent>((event, emit) {
      emit(FetchNotesInProgress());
      event = event as FetchNotes;
      _fetchNotes(event.userId, emit);
    });
  }

  void _fetchNotes(String userId, Emitter<FetchNotesState> emit) async {
    try {
      var notes = await _noteRepository.fetchNotes(userId: userId);

      emit(FetchNotesSuccess(Stream.value(notes)));
    } catch (e) {
      emit(FetchNotesFailure(e.toString()));
    }
  }
}
