part of 'fetch_notes_bloc.dart';

@immutable
sealed class FetchNotesState {}

final class FetchNotesInitial extends FetchNotesState {}

final class FetchNotesInProgress extends FetchNotesState {}

final class FetchNotesSuccess extends FetchNotesState {
  final Stream<List<Note>> notes;

  FetchNotesSuccess(this.notes);
}

final class FetchNotesFailure extends FetchNotesState {
  final String errorMessage;

  FetchNotesFailure(this.errorMessage);
}
