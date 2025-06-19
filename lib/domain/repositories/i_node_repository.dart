import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/repositories/i_db_repository.dart';

abstract interface class INodeRepository {
  late SharedpreferencesRepository sharedPref;
  late IDbProvider db;

  String get path;
  ValueNotifier<bool> get isInit;

  // ========================================================
  // Init part
  // ========================================================
  Future<bool> initDb();

  Future<void> initFilePermissionIfNot();

  Future<bool> init();
  // ========================================================
  //
  // ========================================================
  Future<bool> setPath(String newpath);

  Future<bool> getNewRepositoryPathByUser();

  void removeRepositoryPathFromSharedPrefences();
  // ========================================================
  //
  // ========================================================
  Future<void> deleteNoteByRelativePath(String relativePath);

  Future<void> deleteFolderByRelativePath(String relativePath);
  // ========================================================
  //
  // ========================================================

  Future<List<DbNote>> getNotes();

  /// ========================================================
  ///
  /// ========================================================
  Future<List<DbNote>> getNotesInRelationWith(DbNote note,{ int depth});
  // ========================================================
  //
  // ========================================================

  Future<bool> insertDbsNote(String relativePath);

  Future<bool> deleteDbsNote(String relativePath);

  // Future<String> renameNote(File file, String newName);
  Future<String> renameNote(String fullPath, String newName);

  Future<void> createNote(String relPath);
  // ========================================================
  //
  // ========================================================

  Future<void> createFolder(String relPath);

  Future<void> moveNoteFolder(
      String oldItemRelPath, String newItemParentRelPath);

  Future<String> renameFolder(String fullPath, String newTitle);

  // ========================================================
  //
  // ========================================================
  Future<bool> createDbsRelation(String pathFrom, String pathTo);

  Future<void> deleteDbsRelation(String pathFrom, String pathTo);

  Future<List<(DbNote, DbNote)>> getRelationsNoteEntity();

  Future<List<DbRelation>> getRelationsFromList(List<DbNote> notes);
}
