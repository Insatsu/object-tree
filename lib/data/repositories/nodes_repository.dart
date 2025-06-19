import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NodesRepository implements INodeRepository {
  final String _titleBrowserRepository = 'NodesRepository';
  bool __initDbCompleter = false;

  set _initDbCompleter(bool value) {
    __initDbCompleter = value;
    isInit.value = __initDbCompleter && __initSPCompleter;
  }

  bool __initSPCompleter = false;
  set _initSPCompleter(bool value) {
    __initSPCompleter = value;
    isInit.value = __initDbCompleter && __initSPCompleter;
  }

  String get _dbPath => p.join(path, DB_FOLDER, DB_NAME);

  NodesRepository({required this.db});

  // * On init set prefs and then set path to value from prefs.
  // * If it's null('') on main page will displayed page with request to set it.
  @override
  late SharedpreferencesRepository sharedPref;

  @override
  IDbProvider db;

  String? _path;

  @override
  String get path => _path ?? '-1';
  @override
  ValueNotifier<bool> isInit = ValueNotifier(false);

  // * ========================================================
  // * Init part
  // * ========================================================
  @override
  Future<bool> initDb() async {
    // ? посмотреть, где используется
    if (path.isEmpty) {
      return false;
    }
    GetIt.I<Talker>().log("$_titleBrowserRepository-initDb");

    _initDbCompleter = false;

    try {
      await db.close();
      await db.open(_dbPath);
    } on DatabaseException catch (_) {
      return false;
    }

    _initDbCompleter = true;

    GetIt.I<Talker>().log("$_titleBrowserRepository-initDb complete");
    return true;
  }

  @override
  Future<void> initFilePermissionIfNot() async {
    await FileSystemRepository().getPermissionIfNot();
  }

  // * Init
  @override
  Future<bool> init() async {
    if (isInit.value) {
      return true;
    }

    await _initSharedPreferences();

    _path = sharedPref.getPath();

    //
    if (await initDb()) {
      GetIt.I<Talker>()
          .debug('$_titleBrowserRepository init with:\npath:$_path');
      return true;
    }

    return false;
  }

  // * Set path and notify bloc
  @override
  Future<bool> setPath(String newpath) async {
    GetIt.I<Talker>().log("$_titleBrowserRepository-setPath = $newpath");
    _path = newpath;
    await sharedPref.setNewPathAndUpdatePrevious(newpath);
    if (await initDb()) {
      GetIt.I<Talker>().debug('$_titleBrowserRepository-setPath success');
      return true;
    }
    return false;
  }

  // * Set path with open diaolg to choose directory on phone
  @override
  Future<bool> getNewRepositoryPathByUser() async {
    // * Pick a directory by user and log it
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    GetIt.I<Talker>().log(
        "$_titleBrowserRepository-NewPath:\nCurrent path from prefs: ${sharedPref.prefs.getString(KeyStore.currentPath)}");

    // * If user choose directory log it and save its path
    if (selectedDirectory != null) {
      GetIt.I<Talker>()
          .log("$_titleBrowserRepository sets new path: $selectedDirectory");

      setPath(selectedDirectory);
      // * Work with sharedPrefs. setPath and add it to previous path
      sharedPref.setNewPathAndUpdatePrevious(selectedDirectory);

      return true;
    }
    // * If user didn't choose a directory nothing
    return false;
  }

  @override
  void removeRepositoryPathFromSharedPrefences() {
    GetIt.I<Talker>().info('$_titleBrowserRepository removePath');
    _path = '';
    sharedPref.prefs.setString(KeyStore.currentPath, '');
  }

  @override
  Future<void> deleteNoteByRelativePath(String relativePath) async {
    await FileSystemRepository.deleteFileByPath(p.join(path, relativePath));
    await db.deleteNote(DbNote.relativePath(relativePath: relativePath));
  }

  @override
  Future<void> deleteFolderByRelativePath(String relativePath) async {
    await FileSystemRepository.deleteDirectoryByPath(
        p.join(path, relativePath));
  }

  @override
  Future<List<DbNote>> getNotes() async {
    List<DbNote> result = [];

    result = await db.getNotes();

    return result;
  }

  /// First element in list is main node
  @override
  Future<List<DbNote>> getNotesInRelationWith(DbNote note,
      {int depth = 1}) async {
    throwIf(depth < 1, Exception("Depth can not be lower 1"));

    note = await db.getNoteByPart(note);

    Set<DbNote> result = {};

    result.add(note);

    final rel = await getRelationsNoteEntity();

    for (var i = 0; i < depth; i++) {
      if (rel.isEmpty) break;
      
      HashSet<DbNote> currentDepthRelativeNotes = HashSet();
      for (var relativeNote in result) {
        for (var j = 0; j < rel.length; j++) {
          final relation = rel[j];

          if (relation.$1.relativePath == relativeNote.relativePath) {
            currentDepthRelativeNotes.add(relation.$2);
            rel.remove(relation);
            continue;
          }
          if (relation.$2.relativePath == relativeNote.relativePath) {
            currentDepthRelativeNotes.add(relation.$1);
            rel.remove(relation);
            continue;
          }
        }
      }
      result.addAll(currentDepthRelativeNotes);
    }

    return result.toList();
  }

  // * =================================================================
  // * Db part
  @override
  Future<bool> insertDbsNote(String relativePath) async {
    DbNote note = DbNote.relativePath(relativePath: relativePath);
    DbNote? createdNote = await db.insertNote(note);
    return createdNote != null;
  }

  @override
  Future<bool> deleteDbsNote(String relativePath) async {
    int id =
        await db.deleteNote(DbNote.relativePath(relativePath: relativePath));
    return id != -1;
  }

  // * =================================================================

  /// * Without check on exclusive
  @override
  Future<String> renameNote(String fullPath, String newTitle) async {
    GetIt.I<Talker>().debug(
        '$_titleBrowserRepository: rename:\n file path: $fullPath\n newName: $newTitle');

    var newPath =
        FileSystemRepository.changeTitleInPathWithExtension(fullPath, newTitle);

    final relativeOldPath = p.relative(fullPath, from: path);
    final relativeNewPath = p.relative(newPath, from: path);

    await FileSystemRepository.renameFile(fullPath, newTitle);
    // await db.updateNoteByPaths(relativeOldPath, relativeNewPath);
    await db.updateNote(DbNote.relativePath(relativePath: relativeOldPath),
        DbNote.relativePath(relativePath: relativeNewPath));

    return relativeNewPath;
  }

  @override
  Future<void> createNote(String relPath) async {
    // await FileSystemRepository.createFileByPath('$path/$relPath');
    await FileSystemRepository.createFileByPath(p.join(path, relPath));
    await insertDbsNote(relPath);
  }

  // * =================================================================
  // * Folder part

  @override
  Future<void> createFolder(String relPath) async {
    await FileSystemRepository.createDirectoryByPath(p.join(path, relPath));
  }

  @override
  Future<String> renameFolder(String fullPath, String newTitle) async {
    GetIt.I<Talker>().debug(
        '$_titleBrowserRepository: renameFolder:\n folder path: $fullPath\n newName: $newTitle');

    var newFolderFullPath =
        FileSystemRepository.changeTitleInPathWithExtension(fullPath, newTitle);

    final oldFolderRelPath = p.relative(fullPath, from: path);
    final newFolderRelPath = p.relative(newFolderFullPath, from: path);

    await FileSystemRepository.renameDirectory(fullPath, newTitle);

    /// All files in directory (also files from child directory and etc.)
    List<FileSystemEntity> itemsList =
        await (Directory(newFolderFullPath).list(recursive: true)).toList();

    /// Update internal files
    await Future.forEach(itemsList, (item) async {
      if (item is Directory) {
        return;
      }

      /// Inner item path relative folder(parent) path (because of folder already in 
      /// new place there is used new folder relative path)
      var innerItemRelParentPath =
          p.relative(item.path, from: newFolderFullPath);

      /// Inner item path relative general app path
      var innerOldItemRelPathWithTitle =
          p.join(oldFolderRelPath, innerItemRelParentPath);

      /// Inner item project relative path
      var innerItemNewRelPath = p.relative(item.path, from: path);
      await db.updateNote(
          DbNote.relativePath(relativePath: innerOldItemRelPathWithTitle),
          DbNote.relativePath(relativePath: innerItemNewRelPath));
    });

    return newFolderRelPath;
  }

  @override
  Future<void> moveNoteFolder(
      String oldItemRelPath, String newItemParentRelPath) async {
    ///  Get old item full path and new item parent full path for rename file/directory in system by [FileSystemRepository]
    var oldItemFullPath = p.join(path, oldItemRelPath);
    var newItemParentFullPath = p.join(path, newItemParentRelPath);

    await FileSystemRepository.moveFileDirectoryByPath(
        oldItemFullPath, newItemParentFullPath);

    /// [newNoteFullPath] to check what item is file or directory and get it later if directory
    var newItemFullPath =
        p.join(newItemParentFullPath, p.basename(oldItemRelPath));

    /// [newNoteRelPath] to update item in db
    var newItemRelPath =
        p.join(newItemParentRelPath, p.basename(oldItemRelPath));

    /// If item is file update it in db
    if (await FileSystemEntity.isFile(newItemFullPath)) {
      await db.updateNote(DbNote.relativePath(relativePath: oldItemRelPath),
          DbNote.relativePath(relativePath: newItemRelPath));
    }

    /// If item is directory get all its files and update them in db
    else {
      /// All files in directory (also files from child directory and etc.)
      List<FileSystemEntity> itemsList =
          await (Directory(newItemFullPath).list(recursive: true)).toList();

      /// Update internal files
      await Future.forEach(itemsList, (item) async {
        if (item is Directory) {
          return;
        }

        /// Inner item path relative folder(parent) path (because of folder already in new place
        ///  there is used new folder relative path)
        var innerItemRelParentPathWithTitle =
            p.relative(item.path, from: newItemFullPath);

        /// Inner item path relative general app path
        var innerOldItemRelPathWithTitle =
            p.join(oldItemRelPath, innerItemRelParentPathWithTitle);

        /// Inner item project relative path
        var innerItemNewRelPath = p.relative(item.path, from: path);
        await db.updateNote(
            DbNote.relativePath(relativePath: innerOldItemRelPathWithTitle),
            DbNote.relativePath(relativePath: innerItemNewRelPath));
      });
    }
  }

  // * =================================================================
  // * Relation part

  @override
  Future<bool> createDbsRelation(String pathFrom, String pathTo) async {
    int id = await db.insertRelationByTwoPath(pathFrom, pathTo);
    return id != -1;
  }

  @override
  Future<void> deleteDbsRelation(String pathFrom, String pathTo) async {
    await db.deleteRelationByTwoPath(pathFrom, pathTo);
  }

  @override
  Future<List<(DbNote, DbNote)>> getRelationsNoteEntity() async {
    return await _getRelationsNotes();
  }

  @override
  Future<List<DbRelation>> getRelationsFromList(List<DbNote> notes) async {
    List<DbRelation> result = [];

    var relationsPaths = await _getRelationsNotes();

    for (var relation in relationsPaths) {
      final noteIdFrom = notes.indexWhere((el) => el.id == relation.$1.id);
      if (noteIdFrom == -1) continue;

      final noteIdTo = notes.indexWhere((el) => el.id == relation.$2.id);

      if (noteIdTo == -1) continue;

      result.add(DbRelation.fromSet((relation.$1.id!, relation.$2.id!)));
    }

    return result;
  }

  // !===========================================================================================
  // !===========================================================================================

  Future<void> _initSharedPreferences() async {
    sharedPref = SharedpreferencesRepository();
    await sharedPref.init();
    _initSPCompleter = true;
  }

  Future<List<(DbNote, DbNote)>> _getRelationsNotes() async {
    return await db.getRelationsNotes();
  }
}
