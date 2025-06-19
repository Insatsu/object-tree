part of 'note_bloc.dart';

sealed class NoteState extends Equatable {
  const NoteState();
}

class NoteInitial extends NoteState {
  const NoteInitial();

  @override
  List<Object?> get props => [];
}




class NoteLoadingNote extends NoteState {
  const NoteLoadingNote();
  @override
  List<Object?> get props => [Random().nextDouble()];
}

// ======================================================
// * Content
class NoteLoadingContent extends NoteState {
  const NoteLoadingContent();
  @override
  List<Object?> get props => [Random().nextDouble()];
}
class NoteLoadedContent extends NoteState {
  const NoteLoadedContent();
  @override
  List<Object?> get props => [];
}

class NoteLoadedTextContent extends NoteLoadedContent {
  const NoteLoadedTextContent({required this.content});
  final String content;

  @override
  List<Object?> get props => [content];
  // ? имеет ли вообще смысл, ведь если контента мало, то пусть перезагружается, а если много, то сравнивание может быть затратным
}

// * If file is media
class NoteLoadedMediaContent extends NoteLoadedContent {
  const NoteLoadedMediaContent({required this.filePath});
  final String filePath;

  @override
  List<Object?> get props => [Random().nextDouble()];
}

class NoteRawContent extends NoteState {
  const NoteRawContent();
  @override
  List<Object?> get props => [];
}

class NoteMdContent extends NoteState {
  const NoteMdContent();
  @override
  List<Object?> get props => [];
}

// ==============================================================
// * Title
class NoteChangedTitile extends NoteState {
  const NoteChangedTitile({required this.newTitle});

  final String newTitle;
  @override
  List<Object?> get props => [newTitle];
}


// ==============================================================
// * Create Note
class NoteCreated extends NoteState {
  const NoteCreated();
  @override
  List<Object?> get props => [];
}

// ==============================================================
// * Links
class NoteLoadedLinks extends NoteState {
  const NoteLoadedLinks({required this.notes});
  final List<NoteEntity> notes;

  @override
  List<Object?> get props => [notes];
}

class NoteLoadedBackLinkedList extends NoteLoadedLinks {
  const NoteLoadedBackLinkedList({required super.notes});
  @override
  List<Object?> get props => [notes];
}

class NoteLoadedForwardLinkedList extends NoteLoadedLinks {
  const NoteLoadedForwardLinkedList({required super.notes});
  @override
  List<Object?> get props => [notes];
}

// * Search
class NoteLoadedSearchList extends NoteState {
  const NoteLoadedSearchList(
      {required this.notes, this.noteRelPathsIsAdded = const <String, bool>{}});
  final List<NoteEntity> notes;
  final Map<String, bool> noteRelPathsIsAdded;
  @override
  List<Object?> get props => [notes, noteRelPathsIsAdded];
}

// ==============================================================
// ==============================================================
// ==============================================================
class NoteLinkFailure extends NoteState {
  const NoteLinkFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
class NoteContentFailure extends NoteState {
  const NoteContentFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}

class NoteTitleFailure extends NoteState {
  const NoteTitleFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
class NoteInclusiveTitleFailure extends NoteState {
  const NoteInclusiveTitleFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
class NoteBadTitleFailure extends NoteState {
  const NoteBadTitleFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
