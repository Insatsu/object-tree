part of 'nt_bloc.dart';

sealed class NtEvent extends Equatable {
  const NtEvent();
}

// * Tree

class NtUpdateTree extends NtEvent {
  const NtUpdateTree();

  @override
  List<Object?> get props => [];
}

class NtLoadAll extends NtEvent {
  const NtLoadAll();

  @override
  List<Object?> get props => [];
}

class NtLoadRelative extends NtEvent {
  const NtLoadRelative({required this.note});

  final DbNote note;

  @override
  List<Object?> get props => [note];
}

// * Drawer
class NtLoadSearchList extends NtEvent {
  const NtLoadSearchList({required this.word});

  final String word;

  @override
  List<Object?> get props => [Random().nextDouble()];
}
