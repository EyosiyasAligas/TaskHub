part of 'fetch_groups_bloc.dart';

@immutable
sealed class FetchGroupsState {}

final class FetchGroupsInitial extends FetchGroupsState {}

final class FetchGroupsInProgress extends FetchGroupsState {}

 class FetchGroupsSuccess extends FetchGroupsState {
  final List<Group> groups;

  FetchGroupsSuccess(this.groups);
}

final class FetchGroupsFailure extends FetchGroupsState {
  final String errorMessage;

  FetchGroupsFailure(this.errorMessage);
}
