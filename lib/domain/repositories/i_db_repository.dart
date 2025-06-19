import 'dart:async';

import 'package:object_tree/data/model/model.dart';

abstract interface class IDbProvider {
  String? get path;

  Future<void> open(String path);

  Future<void> updateProps();

  /// ======================================================
  ///
  /// Insert note into db for init case.
  /// 
  /// If successfully return note itself (the argument).
  /// Else retrun null
  ///
  /// ======================================================
  Future<void> checkNotesInserts(List<DbNote> notes);

  /// ======================================================
  ///
  /// Insert note into db for general case.
  ///
  /// If successfully return note itself (the argument)
  /// Else return null
  ///
  /// ======================================================
  Future<DbNote?> insertNote(DbNote note);

  /// ======================================================
  ///
  /// Insert relation into db.
  ///
  /// Take as argument [DbRelation] object.
  ///
  /// If successfully return the inserted id. Else return -1
  ///
  /// ======================================================
  Future<int> insertRelation(DbRelation relation);

  /// ======================================================
  ///
  /// Insert relation into db.
  ///
  /// Take as argument two strings: notes relative paths (from, to)
  /// Try to find need notes by their relativePath then create [DbRelation] and insert it into db
  /// If successfully return the inserted id. Else return -1
  ///
  /// ======================================================
  Future<int> insertRelationByTwoPath(String pathFrom, String pathTo);

  /// ======================================================
  ///
  /// Delete relation from db.
  ///
  /// ======================================================
  Future<void> deleteRelation(DbRelation relation);

  /// ======================================================
  ///
  /// Delete relation from db.
  ///
  /// Take as argument two strings: notes relative paths (from, to)
  ///
  /// ======================================================
  Future<void> deleteRelationByTwoPath(String pathFrom, String pathTo);


  /// ======================================================
  ///
  /// Delete note from db
  ///
  /// Take note relative path, try to find it in db
  /// If found delete it
  ///
  /// Return note id if successfully
  /// Else return -1
  ///
  /// ======================================================
  Future<int> deleteNote(DbNote note);

  /// ======================================================
  ///
  /// Delete notes from db by its parent relative path
  ///
  /// Take note relative path, try to find it in db
  /// If found delete it
  ///
  /// Return note true if successfully
  /// Else return false
  ///
  /// ======================================================
  Future<bool> deleteNotesByParentRelativePath(String parentRelPath);

  /// ======================================================
  ///
  /// Updates note by it relative path [columnNotesRelativePath].
  ///
  /// Take [oldPath] and [newPath]. By first one find note in db and then update it.
  ///
  /// ======================================================
  // Future<void> updateNoteByPaths(String oldPath, String newPath);

  Future<void> updateNote(DbNote oldNote, DbNote newNote);

  /// ======================================================
  ///
  /// Return all notes relative paths from db (second column)
  ///
  /// ======================================================

  /// ======================================================
  ///
  /// Get all notes from db in format: {id: relativePath}.
  ///
  /// Return list of maps
  ///
  /// ======================================================

  Future<List<DbNote>> getNotes();

  /// without check [partNote] on correct
  Future<DbNote> getNoteByPart(DbNote partNote);

  /// ======================================================
  ///
  /// Get all relations relative paths from db in format: relPathFrom: relPathTo
  ///
  /// At first get all relations ids from db table [tableRelations] and then find need notes relative paths from  table [tableNotes]
  /// Then combines it to format
  ///
  /// ======================================================
  // Future<List<Map<DbNote, DbNote>>> getRelationsRelativePaths();
  Future<List<(DbNote, DbNote)>> getRelationsNotes();

  /// ======================================================
  ///
  /// Get all relations from db table [tableRelations]
  /// They represent notes ids
  ///
  /// ======================================================
  Future<List<DbRelation>> getRelations();

  /// ======================================================
  ///
  /// Get relations that are directed TO note whose relative path taken as argument
  ///
  /// ======================================================

  Future<List<DbNote>> getRelationsNotesToByNoteFrom(DbNote noteFrom);

  /// ======================================================
  ///
  /// Get relations that are directed FROM note that relative path taken as argument
  ///
  /// ======================================================
  Future<List<DbNote>> getRelationsNotesFromByNoteTo(DbNote noteTo);

  /// ======================================================
  ///
  /// Close db connection
  ///
  /// ======================================================
  Future close();
}
