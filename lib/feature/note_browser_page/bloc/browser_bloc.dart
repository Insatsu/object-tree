import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/data/model/db_model.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:path/path.dart' as p;
part './browser_event.dart';
part './browser_state.dart';

class BrowserBloc extends Bloc<BrowserEvent, BrowserState> {
  BrowserBloc(this._nodeRepository) : super(const BrowserInitial()) {
    on<BrowserLoadNotesList>((event, emit) {
      _onLoadNotesList(emit);
    });
    on<BrowserCreateFolder>((event, emit) async {
      await _onCreateFolder(event, emit);
    });
    on<BrowserCreateNote>((event, emit) async {
      await _onCreateNote(event, emit);
    });
    on<BrowserStartRenameItem>((event, emit) {
      emit(BrowserBeginRenameObject(event.relativePath));
    });
    on<BrowserEndRenameItem>((event, emit) async {
      await _onBrowserEndRenameItem(event, emit);
    });

    on<BrowserUpdateLinks>((event, emit) {
      emit(BrowserUpdatedLinks());
    });

    on<BrowserShowTreeWith>((event, emit) {
      emit(BrowserUpdatedTree(note: event.note));
    });
  }

  Future<void> _onCreateFolder(
      BrowserCreateFolder event, Emitter<BrowserState> emit) async {
    try {
      String newExclusiveTitle = FileSystemRepository.getExclusiveTitle(
          event.relativePath, _nodeRepository.path);

      String newExclusiveRelPath =
          FileSystemRepository.changeTitleInPathWithExtension(
              event.relativePath, newExclusiveTitle);

      await _nodeRepository.createFolder(newExclusiveRelPath);

      add(BrowserLoadNotesList());

      await stream.firstWhere((element) => element is BrowserLoaded);

      emit(BrowserBeginRenameObject(newExclusiveRelPath));
    } catch (e, st) {
      emit(BrowserSomeFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onCreateNote(
      BrowserCreateNote event, Emitter<BrowserState> emit) async {
    try {
      String newExclusiveTitle = FileSystemRepository.getExclusiveTitle(
          event.relativePath, _nodeRepository.path);

      String newExclusiveRelPath =
          FileSystemRepository.changeTitleInPathWithExtension(
              event.relativePath, newExclusiveTitle);

      await _nodeRepository.createNote(newExclusiveRelPath);

      add(BrowserLoadNotesList());

      await stream.firstWhere((element) => element is BrowserLoaded);

      emit(BrowserBeginRenameObject(newExclusiveRelPath));
    } catch (e, st) {
      emit(BrowserSomeFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onBrowserEndRenameItem(
      BrowserEndRenameItem event, Emitter<BrowserState> emit) async {
    try {
      var newRelativePath = FileSystemRepository.changeTitleInPathWithExtension(
          event.oldRelativePath, event.newTitle);

      // If new title is the same as old one or empty or start with a dot do nothing and end renaming
      if (newRelativePath == event.oldRelativePath ||
          event.newTitle.isEmpty ||
          event.newTitle.startsWith('.')) {
        emit(BrowserComplitedRenameObject(event.oldRelativePath));
        return;
      }
      String oldFullPath = p.join(_nodeRepository.path, event.oldRelativePath);

      // If new title with no register sense is the same as old one not check for exclusive, rename and end it
      if (event.newTitle.toLowerCase() ==
          p.basenameWithoutExtension(event.oldRelativePath).toLowerCase()) {
        await _saveNewTitle(oldFullPath, event.newTitle);
        emit(BrowserComplitedRenameObject(event.newTitle));
        add(BrowserLoadNotesList());
        return;
      }

      String newExclusiveTitle = FileSystemRepository.getExclusiveTitle(
          newRelativePath, _nodeRepository.path,
          returnThisTitleIfWas:
              p.basenameWithoutExtension(event.oldRelativePath));

      if (newExclusiveTitle ==
          p.basenameWithoutExtension(event.oldRelativePath)) {
        emit(BrowserComplitedRenameObject(event.oldRelativePath));
        return;
      }

      await _saveNewTitle(oldFullPath, newExclusiveTitle);

      emit(BrowserComplitedRenameObject(newExclusiveTitle));
      add(BrowserLoadNotesList());
    } on FileSystemException catch (e, st) {
      emit(BrowserRenameFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    } catch (e, st) {
      emit(BrowserSomeFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  ///
  Future<void> _saveNewTitle(
      String oldFullPath, String newExclusiveTitle) async {
    if (FileSystemRepository.isFile(oldFullPath)) {
      await _nodeRepository.renameNote(oldFullPath, newExclusiveTitle);
    } else {
      await _nodeRepository.renameFolder(oldFullPath, newExclusiveTitle);
    }
  }

  void _onLoadNotesList(Emitter<BrowserState> emit) {
    try {
      if (state is BrowserInitial) {
        emit(const BrowserLoading());
      }
      if (!_nodeRepository.isInit.value) {
        _nodeRepository.isInit.addListener(_isInitListener);
        return;
      }

      _nodeRepository.isInit.removeListener(_isInitListener);

      final notesList =
          FileRepository(db: _nodeRepository.db, path: _nodeRepository.path)
              .getBItemNodeList();

      GetIt.I<Talker>()
          .info("browser bloc _onLoadNotesList: nodesList: $notesList");

      emit(BrowserLoaded(itemsList: notesList));
    } catch (e, st) {
      emit(BrowserLoadingFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  void _isInitListener() {
    GetIt.I<Talker>().debug("init listener");
    if (_nodeRepository.isInit.value) {
      add(const BrowserLoadNotesList());
    }
  }

  final INodeRepository _nodeRepository;
}
