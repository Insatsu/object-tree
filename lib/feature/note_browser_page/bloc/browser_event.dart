part of './browser_bloc.dart';

sealed class BrowserEvent extends Equatable {
  const BrowserEvent();
}

class BrowserLoadNotesList extends BrowserEvent {
  const BrowserLoadNotesList();

  @override
  List<Object?> get props => [];
}

class BrowserLoadNote extends BrowserEvent {
  const BrowserLoadNote({required this.relativePath});

  final String relativePath;

  @override
  List<Object?> get props => [];
}

class BrowserCreateNote extends BrowserEvent {
  const BrowserCreateNote({required this.relativePath});

  final String relativePath;

  @override
  List<Object?> get props => [];
}

class BrowserCreateFolder extends BrowserEvent {
  const BrowserCreateFolder({required this.relativePath});

  final String relativePath;

  @override
  List<Object?> get props => [];
}

// * Rename part
class BrowserStartRenameItem extends BrowserEvent {
  const BrowserStartRenameItem({required this.relativePath});

  final String relativePath;

  @override
  List<Object?> get props => [];
}

class BrowserEndRenameItem extends BrowserEvent {
  const BrowserEndRenameItem(
      {required this.newTitle, required this.oldRelativePath});

  final String oldRelativePath;
  final String newTitle;

  @override
  List<Object?> get props => [];
}
// * End

// * NoteTree

class BrowserShowTreeWith extends BrowserEvent {
  const BrowserShowTreeWith({required this.note});

  final DbNote note;

  @override
  List<Object?> get props => [];
}

// * End

class BrowserUpdateLinks extends BrowserEvent {
  const BrowserUpdateLinks();

  @override
  List<Object?> get props => [];
}
