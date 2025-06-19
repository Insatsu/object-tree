import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/data/model/db_model.dart';
import 'package:object_tree/domain/models/note_content_type.dart';
import 'package:object_tree/domain/repositories/i_db_repository.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:object_tree/feature/note_browser_page/bloc/browser_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

part './note_event.dart';
part './note_state.dart';

class NoteBloc extends Bloc<NoteEvent, NoteState> {
  NoteBloc(
      {required IDbProvider dbProvider,
      required INodeRepository nodeRepository})
      : _dbProvider = dbProvider,
        _nodeRepository = nodeRepository,
        super(const NoteInitial()) {
    // Set listener
    _forwardLinkNotes.addListener(_fnListener);

    on<NoteInit>((event, emit) {
      emit(NoteInitial());
    });

    ///
    /// * Content part
    ///
    on<NoteLoadContent>((event, emit) {
      _onNoteLoadContent(emit);
    });
    on<NoteSaveContent>((event, emit) {
      _onNoteSaveContent(event, emit);
    });

    on<NoteChangeFormatToMd>((event, emit) {
      _onNoteToMd(emit);
    });

    on<NoteChangeFormatToRaw>((event, emit) {
      _onNoteToRaw(emit);
    });

    ///
    /// * Title part
    ///
    on<NoteChangeTitle>((event, emit) async {
      await _onNoteChangeTitle(event, emit);
    });

    ///
    /// * Search part
    ///
    on<NoteLoadSearchList>((event, emit) {
      _onNoteLoadSearchList(event, emit);
    });
    on<NoteSearchListWord>((event, emit) {
      _onNoteSearchListWord(event, emit);
    });
    on<NoteSearchListAddForwardLink>((event, emit) async {
      await _onNoteSearchListAddForwardLink(event, emit);
    });
    on<NoteSearchListDeleteForwardLink>((event, emit) async {
      await _onNoteSearchListDeleteForwardLink(event, emit);
    });

    ///
    /// * Link part
    ///
    on<NoteLoadBackLinkedNotesFromDb>((event, emit) async {
      await _onNoteLoadBackLinkedNotesFromDb(event, emit);
    });
    on<NoteLoadForwardLinkedNotesFromDb>((event, emit) async {
      await _onNoteLoadForwardLinkedNotesFromDb(event, emit);
    });

    on<NoteDeleteBackLinkedNoteFromDb>((event, emit) async {
      await _onNoteDeleteBackLinkedNoteFromDb(event, emit);
    });

    on<NoteDeleteForwardLinkedNoteFromDb>((event, emit) async {
      await _onNoteDeleteForwardLinkedNoteFromDb(event, emit);
    });
  }

  ///
  /// * Content part
  ///
  void _onNoteLoadContent(Emitter<NoteState> emit) {
    try {
      if (state is! NoteLoadedTextContent) {
        emit(const NoteLoadingContent());
      }
      (NoteContentType?, String) content = noteRepository!.getFileContent();
      GetIt.I<Talker>().info("NoteContent: ${content.$1}");

      switch (content.$1) {
        case NoteContentText():
          emit(NoteLoadedTextContent(content: content.$2));
          break;
        case NoteContentMedia():
          emit(NoteLoadedMediaContent(filePath: content.$2));
          break;
        case NoteContentUnknown():
        default:
          emit(const NoteContentFailure(exception: "Unknown type"));
          break;
      }
    } catch (e, st) {
      emit(NoteContentFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _onNoteSaveContent(NoteSaveContent event, Emitter<NoteState> emit) {
    try {
      // * If content is not text no save
      if (noteRepository!.contentType is! NoteContentText) {
        return;
      }

      String newContent = event.newContent;

      if (noteRepository!.getFileContent().$2 == newContent) {
        return;
      }

      noteRepository!.saveContent(newContent);
    } catch (e, st) {
      emit(NoteContentFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _onNoteToMd(Emitter<NoteState> emit) {
    try {
      emit(const NoteMdContent());
    } catch (e, st) {
      emit(NoteContentFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _onNoteToRaw(Emitter<NoteState> emit) {
    try {
      emit(const NoteRawContent());
    } catch (e, st) {
      emit(NoteContentFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  ///
  /// * Title part
  ///
  Future<void> _onNoteChangeTitle(
      NoteChangeTitle event, Emitter<NoteState> emit) async {
    try {
      // If new title is the same that before than not change it
      if (noteRepository!.title == event.title) {
        return;
      }
      String savedTitle = event.title;

      if (savedTitle.isEmpty) {
        savedTitle = p.withoutExtension(NOTE_TITLE_WITH_EXTANSION_DEFAULT);
      }

      savedTitle = noteRepository!.getExclusiveTitle(savedTitle);

      if (savedTitle == noteRepository!.title) {
        emit(NoteChangedTitile(newTitle: savedTitle));
        return;
      }

      await noteRepository!.renameNote(savedTitle);
      emit(NoteChangedTitile(newTitle: savedTitle));
      GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
    
    } on FileInclusiveTitle catch (e, st) {
      emit(NoteInclusiveTitleFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    
    } on FileSystemException catch (e, st) {
      emit(NoteBadTitleFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    
    } catch (e, st) {
      emit(NoteTitleFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  ///
  /// * Search part
  ///
  void _onNoteLoadSearchList(
      NoteLoadSearchList event, Emitter<NoteState> emit) {
    try {
      _initSearchList();
      _noteRelPathsIsAdded.clear();
      _searchWords = "";

      emit(NoteLoadedSearchList(
          notes: _searchedNotes, noteRelPathsIsAdded: _noteRelPathsIsAdded));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _onNoteSearchListWord(
      NoteSearchListWord event, Emitter<NoteState> emit) {
    try {
      _initSearchList();
      _searchWords = event.words;
      // If none return all notes
      if (_searchWords == '') {
        emit(NoteLoadedSearchList(
            notes: _searchedNotes, noteRelPathsIsAdded: _noteRelPathsIsAdded));
        return;
      }
      // If exist some letters change [searchNoted] and return it
      _searchedNotes = _searchedNotes.where((element) {
        return element.relativePath.contains(_searchWords);
      }).toList();

      emit(NoteLoadedSearchList(
          notes: _searchedNotes, noteRelPathsIsAdded: _noteRelPathsIsAdded));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNoteSearchListAddForwardLink(
      NoteSearchListAddForwardLink event, Emitter<NoteState> emit) async {
    try {
      var isAdded = await _nodeRepository.createDbsRelation(
          noteRepository!.relativePath, event.forwardLinkedNote.relativePath);
      if (!isAdded) {
        throw "Error on relation add";
      }

      _noteRelPathsIsAdded[event.forwardLinkedNote.relativePath] = true;

      // *
      GetIt.I<BrowserBloc>().add(const BrowserUpdateLinks());
      // *

      emit(NoteLoadedSearchList(
          notes: _searchedNotes, noteRelPathsIsAdded: _noteRelPathsIsAdded));
    } catch (e, st) {
      _noteRelPathsIsAdded[event.forwardLinkedNote.relativePath] = false;

      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNoteSearchListDeleteForwardLink(
      NoteSearchListDeleteForwardLink event, Emitter<NoteState> emit) async {
    try {
      await _nodeRepository.createDbsRelation(
          noteRepository!.relativePath, event.forwardLinkedNote.relativePath);

      _updateForwardLinkedNotes(note: event.forwardLinkedNote, isAdd: false);
      _noteRelPathsIsAdded[event.forwardLinkedNote.relativePath] = false;

      // *
      GetIt.I<BrowserBloc>().add(const BrowserUpdateLinks());
      // *

      emit(NoteLoadedSearchList(
          notes: _searchedNotes, noteRelPathsIsAdded: _noteRelPathsIsAdded));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  ///
  /// * Link part
  ///

  Future<void> _onNoteDeleteForwardLinkedNoteFromDb(
      NoteDeleteForwardLinkedNoteFromDb event, Emitter<NoteState> emit) async {
    try {
      await _nodeRepository.deleteDbsRelation(
          noteRepository!.relativePath, event.noteTo.relativePath);

      _updateForwardLinkedNotes(note: event.noteTo, isAdd: false);

      // *
      GetIt.I<BrowserBloc>().add(const BrowserUpdateLinks());
      // *

      emit(NoteLoadedForwardLinkedList(notes: _forwardLinkNotes.value));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNoteDeleteBackLinkedNoteFromDb(
      NoteDeleteBackLinkedNoteFromDb event, Emitter<NoteState> emit) async {
    try {
      await _nodeRepository.deleteDbsRelation(
          event.noteFrom.relativePath, noteRepository!.relativePath);
      _updateBackLinkedNotes(note: event.noteFrom, isAdd: false);

      // *
      GetIt.I<BrowserBloc>().add(const BrowserUpdateLinks());
      // *

      emit(NoteLoadedBackLinkedList(notes: _backLinkedNotes));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNoteLoadForwardLinkedNotesFromDb(
      NoteLoadForwardLinkedNotesFromDb event, Emitter<NoteState> emit) async {
    try {
      List<String> relativePaths =
          (await _dbProvider.getRelationsNotesFromByNoteTo(DbNote.relativePath(
                  relativePath: noteRepository!.relativePath)))
              .map((el) => el.relativePath)
              .toList();

      _forwardLinkNotes.value = relativePaths
          .map((element) => NoteEntity(relativePath: element))
          .toList();

      emit(NoteLoadedForwardLinkedList(notes: _forwardLinkNotes.value));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNoteLoadBackLinkedNotesFromDb(
      NoteLoadBackLinkedNotesFromDb event, Emitter<NoteState> emit) async {
    try {
      List<String> relativePaths =
          (await _dbProvider.getRelationsNotesToByNoteFrom(DbNote.relativePath(
                  relativePath: noteRepository!.relativePath)))
              .map((el) => el.relativePath)
              .toList();

      _backLinkedNotes = relativePaths
          .map((element) => NoteEntity(relativePath: element))
          .toList();

      emit(NoteLoadedBackLinkedList(notes: _backLinkedNotes));
    } catch (e, st) {
      emit(NoteLinkFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  ///
  /// * Common functions
  ///
  void _updateBackLinkedNotes({bool isAdd = true, required NoteEntity note}) {
    List<NoteEntity> temp = _backLinkedNotes.toList();

    if (isAdd) {
      temp.add(note);
      _backLinkedNotes = temp;
    } else {
      temp.remove(note);
      _backLinkedNotes = temp;
    }
  }

  void _updateForwardLinkedNotes(
      {bool isAdd = true, required NoteEntity note}) {
    List<NoteEntity> temp = _forwardLinkNotes.value.toList();

    if (isAdd) {
      temp.add(note);
      _forwardLinkNotes.value = temp;
    } else {
      temp.remove(note);
      _forwardLinkNotes.value = temp;
    }
  }

  void _initSearchList() {
    _searchedNotes = notes.toList();
    // ? maybe remove this part and put it in its init
    final thisNote = _searchedNotes.firstWhere(
        (thisNote) => thisNote.relativePath == noteRepository!.relativePath);
    _searchedNotes.remove(thisNote);
    // ?
    _searchedNotes.removeWhere((element) =>
        _forwardLinkNotes.value.contains(element) &&
        !_noteRelPathsIsAdded.containsKey(element.relativePath));
  }

  void _fnListener() {
    add(NoteSearchListWord(words: _searchWords));
  }

  ///
  /// * General Note part
  ///

  @override
  Future<void> close() {
    _forwardLinkNotes.removeListener(_fnListener);
    return super.close();
  }


  ///
  /// * Fileds
  ///

  NoteRepository? noteRepository;
  final INodeRepository _nodeRepository;
  final IDbProvider _dbProvider;

  List<NoteEntity> _searchedNotes = [];
  String _searchWords = "";
  final Map<String, bool> _noteRelPathsIsAdded = <String, bool>{};

  /// Set value out of bloc
  List<NoteEntity> notes = [];
  List<NoteEntity> _backLinkedNotes = [];
  final ValueNotifier<List<NoteEntity>> _forwardLinkNotes = ValueNotifier([]);
}