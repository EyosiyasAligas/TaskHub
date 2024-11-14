part of 'fetch_notes_bloc.dart';

@immutable
sealed class FetchNotesEvent {}

class FetchNotes extends FetchNotesEvent {
  final String userId;

  FetchNotes(this.userId);
}

class AddNote extends FetchNotesEvent {
  final Note note;

  AddNote(this.note);
}

class UpdateNote extends FetchNotesEvent {
  final Note note;

  UpdateNote(this.note);
}

class DeleteNote extends FetchNotesEvent {
  final String noteId;

  DeleteNote(this.noteId);
}
