part of 'fetch_groups_bloc.dart';

@immutable
sealed class FetchGroupsEvent {}

class FetchGroups extends FetchGroupsEvent {
  FetchGroups();
}

class AddGroup extends FetchGroupsEvent {
  final Group group;

  AddGroup(this.group);
}
