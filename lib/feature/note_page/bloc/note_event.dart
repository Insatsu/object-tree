part of 'note_bloc.dart';

sealed class NoteEvent extends Equatable {
  const NoteEvent();
}

class NoteInit extends NoteEvent {
  const NoteInit();
  @override
  List<Object?> get props => [Random().nextDouble()];
}

// * Content
class NoteLoadContent extends NoteEvent {
  const NoteLoadContent();

  @override
  List<Object?> get props => [];
}

class NoteChangeFormatToMd extends NoteEvent {
  const NoteChangeFormatToMd();

  @override
  List<Object?> get props => [];
}

class NoteChangeFormatToRaw extends NoteEvent {
  const NoteChangeFormatToRaw();

  @override
  List<Object?> get props => [];
}

class NoteSaveContent extends NoteEvent {
  const NoteSaveContent({required this.newContent});

  final String newContent;

  @override
  List<Object?> get props => [newContent];
}

class NoteDeleteContent extends NoteEvent {
  const NoteDeleteContent();

  @override
  List<Object?> get props => [];
}

// * Title
class NoteChangeTitle extends NoteEvent {
  const NoteChangeTitle({required this.title});

  final String title;

  @override
  List<Object?> get props => [title];
}


// * Drawer
// ** Search
class NoteLoadSearchList extends NoteEvent {
  const NoteLoadSearchList();

  @override
  List<Object?> get props => [];
}

class NoteSearchListWord extends NoteEvent {
  const NoteSearchListWord({required this.words});

  final String words;

  @override
  List<Object?> get props => [words];
}

class NoteSearchListAddForwardLink extends NoteEvent {
  const NoteSearchListAddForwardLink({required this.forwardLinkedNote});

  final NoteEntity forwardLinkedNote;

  @override
  List<Object?> get props => [forwardLinkedNote];
}

class NoteSearchListDeleteForwardLink extends NoteEvent {
  const NoteSearchListDeleteForwardLink({required this.forwardLinkedNote});

  final NoteEntity forwardLinkedNote;

  @override
  List<Object?> get props => [forwardLinkedNote];
}

// ** Link
class NoteLoadBackLinkedNotesFromDb extends NoteEvent {
  const NoteLoadBackLinkedNotesFromDb();

  @override
  List<Object?> get props => [];
}

class NoteDeleteBackLinkedNoteFromDb extends NoteEvent {
  const NoteDeleteBackLinkedNoteFromDb({required this.noteFrom});

  final NoteEntity noteFrom;

  @override
  List<Object?> get props => [];
}
//

class NoteLoadForwardLinkedNotesFromDb extends NoteEvent {
  const NoteLoadForwardLinkedNotesFromDb();

  @override
  List<Object?> get props => [];
}

class NoteDeleteForwardLinkedNoteFromDb extends NoteEvent {
  const NoteDeleteForwardLinkedNoteFromDb({required this.noteTo});

  final NoteEntity noteTo;

  @override
  List<Object?> get props => [];
}
