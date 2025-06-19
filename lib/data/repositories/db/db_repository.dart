import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/model/model.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:talker_flutter/talker_flutter.dart';

class DbProvider implements IDbProvider {
  final String _title = 'DbProvider';

  @protected
  Database? db;

  @override
  String? get path => db?.path;

  /// Temporary contains all existent notes in user directory
  ///
  /// With browser page update it runs to try to insert all notes into db in [initInsertIfNotNote].
  /// All notes are being added to [_notesRelPathsForCheck] and in db if not already added
  /// Then in [removeDirt] it runs to find notes that contrains in [_notesFromDb] but not in [_notesRelPathsForCheck] and delete it from db
  ///
  /// After all clear [_notesRelPathsForCheck]
  ///
  final List<String?> _notesRelPathsForCheck = [];

  /// ======================================================
  ///
  /// Creates db if it's not exist. After created of if already create just open
  ///
  /// ======================================================
  @override
  Future<void> open(String path) async {
    if (Platform.isAndroid) {
      db = await openDatabase(path, version: 1, onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      }, onCreate: (Database db, int version) async {
        await db.execute('''
      CREATE TABLE IF NOT EXISTS `$tableNotes`(
      `$columnNotesId` INTEGER PRIMARY KEY AUTOINCREMENT,
      `$columnNotesRelativePath` TEXT UNIQUE NOT NULL
      )
      ''');

        await db.execute('''
      CREATE TABLE IF NOT EXISTS `$tableRelations`(
      `$columnRelationsIdFrom` INTEGER,
      `$columnRelationsIdTo` INTEGER,
      FOREIGN KEY (`$columnRelationsIdFrom`) REFERENCES `$tableNotes` (`$columnNotesId`) ON DELETE CASCADE,
      FOREIGN KEY (`$columnRelationsIdTo`) REFERENCES `$tableNotes` (`$columnNotesId`) ON DELETE CASCADE,
      UNIQUE (`$columnRelationsIdFrom`, `$columnRelationsIdTo`)
      )
      ''');
      });
    } else if (Platform.isWindows) {
      var databaseFactory = databaseFactoryFfi;
      db = await databaseFactory.openDatabase(path);
      await db?.execute('PRAGMA foreign_keys = ON');
      await db?.execute('''
      CREATE TABLE IF NOT EXISTS `$tableNotes`(
      `$columnNotesId` INTEGER PRIMARY KEY AUTOINCREMENT,
      `$columnNotesRelativePath` TEXT UNIQUE NOT NULL
      )
      ''');

      await db?.execute('''
      CREATE TABLE IF NOT EXISTS `$tableRelations`(
      `$columnRelationsIdFrom` INTEGER,
      `$columnRelationsIdTo` INTEGER,
      FOREIGN KEY (`$columnRelationsIdFrom`) REFERENCES `$tableNotes` (`$columnNotesId`) ON DELETE CASCADE,
      FOREIGN KEY (`$columnRelationsIdTo`) REFERENCES `$tableNotes` (`$columnNotesId`) ON DELETE CASCADE,
      UNIQUE (`$columnRelationsIdFrom`, `$columnRelationsIdTo`)
      )
      ''');
    }

    GetIt.I<Talker>().debug('$_title opened');
  }

  /// ======================================================
  ///
  /// Updates [_notesRelPathsForCheck] variable by call method [getNotes]
  ///
  /// ======================================================
  @override
  Future<void> updateProps() async {
    await db!.transaction(
      (txn) async {
        await _updateProps(txn);
      },
    );
    GetIt.I<Talker>().debug('$_title updateProps successfully');
  }

  Future<void> _updateProps(Transaction txn) async {
    if (_notesRelPathsForCheck.isEmpty) return;

    final batch = txn.batch();
    try {
      // 1. Получаем существующие уникальные идентификаторы
      final trashNoteId = await txn
          .query(
            tableNotes,
            columns: [columnNotesId],
            where:
                '$columnNotesRelativePath NOT IN (${List.filled(_notesRelPathsForCheck.length, '?').join(',')})',
            whereArgs: _notesRelPathsForCheck.map((note) => note!).toList(),
          )
          .then((rows) => rows.map((row) => row[columnNotesId] as int).toSet());

      // 3. Добавляем в Batch
      for (final noteId in trashNoteId) {
        batch.delete(tableNotes,
            where: '$columnNotesId = ?', whereArgs: [noteId]
            // conflictAlgorithm: ConflictAlgorithm.ignore, // Игнорируем конфликты
            );
      }

      // 4. Выполняем все операции одним запросом
      if (trashNoteId.isNotEmpty) {
        await batch.commit(noResult: true);
      }
      _notesRelPathsForCheck.clear();
      // GetIt.I<Talker>().debug('$_title _update props successfully');
    } catch (e) {
      GetIt.I<Talker>().error('$_title _updateProps error\n$e');
    }
  }

  /// ======================================================
  ///
  /// Insert relation into db.
  ///
  /// Take as argument [DbRelation] object.
  ///
  /// If successfully return the inserted id. Else return -1
  ///
  /// ======================================================
  @override
  Future<int> insertRelation(DbRelation relation) async {
    int id = -1;
    try {
      await db!.transaction((txn) async {
        id = await _insertRelation(relation, txn);
      });
      GetIt.I<Talker>().debug('$_title insetRelation successfully');
    } catch (e) {
      GetIt.I<Talker>().error('$_title insertRelation error\n$e');
    }
    return id;
  }

  /// ======================================================
  ///
  /// Delete relation from db.
  ///
  /// ======================================================
  @override
  Future<void> deleteRelation(DbRelation relation) async {
    try {
      await db!.transaction((txn) async {
        await _deleteRelation(relation, txn);
      });
      GetIt.I<Talker>().debug('$_title deleteRelation successfully');
    } catch (e) {
      GetIt.I<Talker>().error('$_title deleteRelation error\n$e');
    }
  }

  /// ======================================================
  ///
  /// Insert note into db for init case.
  ///
  /// At the start add 'note' in [_notesRelPathsForCheck] and then try to insert.
  ///
  /// If successfully return note itself (the argument).
  /// Else retrun null
  ///
  /// ======================================================
  @override
  Future<void> checkNotesInserts(List<DbNote> notes) async {
    _notesRelPathsForCheck.clear();
    _notesRelPathsForCheck.addAll(notes.map((item) => item.relativePath));

    try {
      await db!.transaction((txn) async {
        final batch = txn.batch();
        // 1. Получаем существующие уникальные идентификаторы (пример для поля "id")
        final setExistingRelPaths = await txn
            .query(
              tableNotes,
              columns: [columnNotesRelativePath],
              where:
                  '$columnNotesRelativePath IN (${List.filled(notes.length, '?').join(',')})',
              whereArgs: notes.map((note) => note.relativePath).toList(),
            )
            .then((rows) => rows
                .map((row) => row[columnNotesRelativePath] as String)
                .toSet());

        // 2. Фильтруем только новые записи
        final newNotes = notes
            .where((note) => !setExistingRelPaths.contains(note.relativePath))
            .toList();

        // 3. Добавляем в Batch
        for (final note in newNotes) {
          batch.insert(tableNotes, {
            columnNotesRelativePath: note.relativePath,
          }
              );
        }

        // 4. Выполняем все операции одним запросом
        if (newNotes.isNotEmpty) {
          await batch.commit(noResult: true);
          GetIt.I<Talker>().info('$_title checkNotesInserts successfully');
        } else {
          GetIt.I<Talker>()
              .info('$_title checkNotesInserts successfully (nothing remove)');
        }
      });
      await updateProps();
    } catch (e) {
      GetIt.I<Talker>().error('$_title checkNotesInserts error\n$e');
    }
  }

  /// ======================================================
  ///
  /// Insert note into db for general case.
  ///
  /// If successfully call [_updateProps] and then return note itself (the argument)
  /// Else return null
  ///
  /// ======================================================
  @override
  Future<DbNote?> insertNote(DbNote note) async {
    try {
      await db!.transaction((txn) async {
        note = await _insertNote(note, txn);
      });
      GetIt.I<Talker>().debug('$_title insertNote successfully');

      await updateProps();

      return note;
    } catch (e) {
      GetIt.I<Talker>().error('$_title insertNote error\n$e');
      return null;
    }
  }

  /// ======================================================
  ///
  /// Insert relation into db.
  ///
  /// Take as argument two strings: notes relative paths (from, to)
  /// Try to find need notes by their relativePath then create [DbRelation] and insert it into db
  /// If successfully return the inserted id. Else return -1
  ///
  /// ======================================================
  @override
  Future<int> insertRelationByTwoPath(String pathFrom, String pathTo) async {
    int id = -1;
    try {
      await db!.transaction((txn) async {
        GetIt.I<Talker>().debug(
            '$_title insertRelationByTwoPath start:\n from: $pathFrom\n to: $pathTo');

        int idFrom = await _getNoteIdByRelativePath(pathFrom, txn);
        int idTo = await _getNoteIdByRelativePath(pathTo, txn);
        var relation = DbRelation.fromMap(
            {columnRelationsIdFrom: idFrom, columnRelationsIdTo: idTo});

        id = await _insertRelation(relation, txn);
        GetIt.I<Talker>().debug('$_title insertRelationByTwoPath successfully');
      });
    } catch (e) {
      GetIt.I<Talker>().error('$_title insertRelationByTwoPath error\n$e');
    }
    return id;
  }

  /// ======================================================
  ///
  /// Delete relation from db.
  ///
  /// Take as argument two strings: notes relative paths (from, to)
  /// Try to find need notes by their relativePath then create [DbRelation] and delete it from db
  ///
  /// ======================================================
  @override
  Future<void> deleteRelationByTwoPath(String pathFrom, String pathTo) async {
    try {
      await db!.transaction((txn) async {
        int idFrom = await _getNoteIdByRelativePath(pathFrom, txn);
        int idTo = await _getNoteIdByRelativePath(pathTo, txn);
        var relation = DbRelation.fromMap(
            {columnRelationsIdFrom: idFrom, columnRelationsIdTo: idTo});

        await _deleteRelation(relation, txn);
        GetIt.I<Talker>().debug('$_title deleteRelationByTwoPath successfully');
      });
    } catch (e) {
      GetIt.I<Talker>().error('$_title deleteRelationByTwoPath error\n$e');
    }
  }

  /// ======================================================
  ///
  /// Delete note from db.
  ///
  /// Take note id, find it in db
  /// If found delete it and call [_updateProps]
  ///
  /// ======================================================

  Future<int> _deleteNoteById(int id) async {
    int result = -1;
    try {
      await db!.transaction((txn) async {
        result = await txn
            .delete(tableNotes, where: '$columnNotesId = ?', whereArgs: [id]);
      });

      GetIt.I<Talker>().debug('$_title deleteNoteById [id=$id] successfully');
      await updateProps();
    } catch (e) {
      GetIt.I<Talker>().error('$_title deleteNoteById error\n$e');
    }
    return result;
  }

  /// ======================================================
  ///
  /// Delete note from db
  ///
  /// Take note relative path, try to find it in db
  /// If found delete it, call [_updateProps]
  ///
  /// Return note id if successfully
  /// Else return -1
  ///
  /// ======================================================

  Future<int> _deleteNoteByRelativePath(String relativePath) async {
    int id = -1;

    try {
      await db!.transaction((txn) async {
        id = await txn.delete(tableNotes,
            where: '$columnNotesRelativePath = ?', whereArgs: [relativePath]);
      });

      GetIt.I<Talker>().debug('$_title deleteNoteByRelativePath successfully');

      await updateProps();
    } catch (e) {
      GetIt.I<Talker>().error('$_title deleteNoteByRelativePath error\n$e');
    }

    return id;
  }

  @override
  Future<int> deleteNote(DbNote note) async {
    if (note.id != null) {
      return await _deleteNoteById(note.id!);
    }
    return await _deleteNoteByRelativePath(note.relativePath);
  }

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
  @override
  Future<bool> deleteNotesByParentRelativePath(String parentRelPath) async {
    bool result = false;
    try {
      await db!.delete(tableNotes,
          where: '$columnNotesRelativePath LIKE "?%"',
          whereArgs: [parentRelPath]);
      result = true;
      GetIt.I<Talker>()
          .debug('$_title deleteNotesByParentRelativePath successfully');

      await updateProps();
    } catch (e) {
      GetIt.I<Talker>()
          .error('$_title deleteNotesByParentRelativePath error\n$e');
      result = false;
    }

    return result;
  }

  /// ======================================================
  ///
  /// Get all notes from db in format: {id: relativePath}.
  ///
  /// Return list of maps
  ///
  /// ======================================================
  @override
  Future<List<DbNote>> getNotes() async {
    List<DbNote> result = [];
    await db!.transaction((txn) async {
      result = (await _getNotes(txn)).map((el) => DbNote.fromMap(el)).toList();
    });

    GetIt.I<Talker>().debug('$_title getNotes successfully');
    return result;
  }

  @override
  Future<DbNote> getNoteByPart(DbNote partNote) async {
    await getNotes();

    late DbNote fullNote;
    if (partNote.id == null) {
      await db!.transaction((txn) async {
        int id = await _getNoteIdByRelativePath(partNote.relativePath, txn);
        fullNote = DbNote.fromMap({
          columnNotesId: id,
          columnNotesRelativePath: partNote.relativePath
        });
      });
    } else {
      await db!.transaction((txn) async {
        String relPath = await _getNoteRelativePathById(partNote.id!, txn);
        fullNote = DbNote.fromMap(
            {columnNotesId: partNote.id, columnNotesRelativePath: relPath});
      });
    }

    return fullNote;
  }

  /// ======================================================
  ///
  /// Updates note by it relative path [columnNotesRelativePath].
  ///
  /// Take [oldPath] and [newPath]. By first one find note in db and then update it.
  /// Also call [_updateProps]
  ///
  /// ======================================================

  @override
  Future<void> updateNote(DbNote oldNote, DbNote newNote) async {
    await updateProps();

    try {
      await db!.transaction((txn) async {
        if (newNote.id == null) {
          int id = await _getNoteIdByRelativePath(oldNote.relativePath, txn);
          newNote.id ??= id;
        }
        // DbNote newNote = DbNote.fromMap(
        //     {columnNotesId: id, columnNotesRelativePath: newNote.relativePath!});

        GetIt.I<Talker>().debug(
            '$_title: updateNoteByPaths\n oldPath: ${oldNote.relativePath}\n newPath: ${newNote.relativePath}\n id: ${newNote.id}');

        await _updateNoteById(newNote, txn);

        GetIt.I<Talker>().debug('$_title updateNoteByPaths successfully');
      });
    } catch (e) {
      GetIt.I<Talker>().debug('$_title updateNoteByPaths error: $e');
    }
  }

  /// ======================================================
  ///
  /// Get all relations relative paths from db in format: relPathFrom: relPathTo
  ///
  /// At first get all relations ids from db table [tableRelations] and then find need notes relative paths from  table [tableNotes]
  /// Then combines it to format
  ///
  /// ======================================================

  @override
  Future<List<(DbNote, DbNote)>> getRelationsNotes() async {
    List<(DbNote, DbNote)> relationsNotes = [];
    final note1id = "note1id";
    final note1rel = "note1rel";
    final note2id = "note2id";
    final note2rel = "note2rel";
    try {
      await db!.transaction((txn) async {
        var result = await txn.rawQuery(
            "SELECT nt1.$columnNotesId AS `$note1id`, nt1.$columnNotesRelativePath as `$note1rel`, "
            "	nt2.$columnNotesId AS `$note2id`, nt2.$columnNotesRelativePath as `$note2rel` FROM $tableRelations as nr"
            " JOIN $tableNotes as nt1 ON nt1.$columnNotesId = nr.$columnRelationsIdFrom "
            " JOIN $tableNotes as nt2 ON nt2.$columnNotesId = nr.$columnRelationsIdTo;");

        relationsNotes = result
            .map((el) => (
                  DbNote.fromMap({
                    columnNotesId: el[note1id],
                    columnNotesRelativePath: el[note1rel]
                  }),
                  DbNote.fromMap({
                    columnNotesId: el[note2id],
                    columnNotesRelativePath: el[note2rel]
                  })
                ))
            .toList();
      });

      GetIt.I<Talker>().debug('$_title getRelationsNotes successfully');
    } on Exception catch (e) {
      GetIt.I<Talker>().error('$_title getRelationsNotes error\n$e');
    }
    return relationsNotes;
  }

  /// ======================================================
  ///
  /// Get all relations from db table [tableRelations]
  /// They represent notes ids
  ///
  /// Return list of map of DbRelation
  ///
  /// ======================================================
  @override
  Future<List<DbRelation>> getRelations() async {
    List<DbRelation> result = [];
    try {
      await db!.transaction((txn) async {
        result = (await _getRelations(txn))
            .map((el) => DbRelation.fromMap(el))
            .toList();
      });

      GetIt.I<Talker>().debug('$_title getRelations successfully');
    } on Exception catch (e) {
      GetIt.I<Talker>().error('$_title getRelations error\n$e');
    }
    return result;
  }

  /// ======================================================
  ///
  /// Get relations that are directed TO note whose relative path taken as argument
  ///
  /// ======================================================
  @override
  Future<List<DbNote>> getRelationsNotesToByNoteFrom(DbNote noteFrom) async {
    List<DbNote> result = [];
    try {
      await db!.transaction((txn) async {
        result = await _getRelationsNotesByMainNote(
            noteFrom, columnRelationsIdTo, txn);
      });

      GetIt.I<Talker>().debug('$_title getRelationsPathsToByPath successfully');
    } on Exception catch (e) {
      GetIt.I<Talker>().error('$_title getRelationsPathsToByPath error\n$e');
    }
    return result;
  }

  /// ======================================================
  ///
  /// Get relations that are directed FROM note that relative path taken as argument
  ///
  /// ======================================================
  @override
  Future<List<DbNote>> getRelationsNotesFromByNoteTo(DbNote noteTo) async {
    List<DbNote> result = [];
    try {
      await db!.transaction((txn) async {
        result = await _getRelationsNotesByMainNote(
            noteTo, columnRelationsIdFrom, txn);
      });

      GetIt.I<Talker>()
          .debug('$_title getRelationsPathssFromByPath successfully');
    } on Exception catch (e) {
      GetIt.I<Talker>().error('$_title getRelationsPathssFromByPath error\n$e');
    }
    return result;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<void> _updateNoteById(DbNote note, Transaction txn) async {
    await txn.update(tableNotes, {columnNotesRelativePath: note.relativePath},
        where: '$columnNotesId = ?', whereArgs: [note.id]);
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  /// ! Принимает только с relativePath != null
  Future<List<DbNote>> _getRelationsNotesByMainNote(
      DbNote mainNote, String targetColumn, Transaction txn) async {
    if (targetColumn != columnRelationsIdTo ||
        targetColumn != columnRelationsIdFrom) {
      Exception('<My error>: Target column is not defined in table');
    }
    List<DbNote> targetNotes = [];

    late String neededColumn;
    switch (targetColumn) {
      case columnRelationsIdTo:
        neededColumn = columnRelationsIdFrom;
        break;
      case columnRelationsIdFrom:
        neededColumn = columnRelationsIdTo;
        break;

      default:
        Exception();
        break;
    }

    // ** все заметки(relative path), для которых notePath находится в столбце target
//          SELECT relative_path FROM Notes AS nt
//          JOIN (SELECT id_to FROM NotesRelations
//          WHERE id_from =
//          (SELECT _id FROM Notes
//          WHERE relative_path = "myTest 1.md" LIMIT 1)) AS idsTo
//          ON nt._id = idsTo.id_to

    var result = await txn.rawQuery(
        "SELECT $columnNotesId, $columnNotesRelativePath FROM $tableNotes AS nt " // relative_path ; Notes
        " JOIN (SELECT $neededColumn FROM $tableRelations " // id_... ; NotesRelations
        " WHERE $targetColumn = (" // id_...
        " SELECT $columnNotesId FROM $tableNotes " // _id ; Notes
        " WHERE $columnNotesRelativePath = ? LIMIT 1)) AS neededIds" // relative_path ; <notePath>
        " ON nt.$columnNotesId = neededIds.$neededColumn", // _id ; id_...
        [
          mainNote.relativePath,
        ]);
    targetNotes = result.map((el) => DbNote.fromMap(el)).toList();

    return targetNotes;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<List<Map<String, Object?>>> _getRelations(Transaction txn) async {
    List<Map<String, Object?>> result = [];
    result = (await txn.query(tableRelations)).toList();
    return result;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<int> _insertRelation(DbRelation relation, Transaction txn) async {
    int id = -1;
    id = await txn.insert(tableRelations, relation.toMap());
    return id;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<void> _deleteRelation(DbRelation relation, Transaction txn) async {
    txn.delete(tableRelations,
        where: '$columnRelationsIdFrom = ? AND $columnRelationsIdTo = ?',
        whereArgs: [
          relation.toMap()[columnRelationsIdFrom],
          relation.toMap()[columnRelationsIdTo],
        ]);
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<DbNote> _insertNote(DbNote note, Transaction txn) async {
    note.id = await txn
        .insert(tableNotes, {columnNotesRelativePath: note.relativePath});
    return note;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<int> _getNoteIdByRelativePath(String path, Transaction txn) async {
    int id = -1;
    final test = (await txn.query(tableNotes,
        columns: [columnNotesId],
        where: '$columnNotesRelativePath = ?',
        whereArgs: [path]));
    id = test.first[columnNotesId] as int;
    return id;
  }

  Future<String> _getNoteRelativePathById(int id, Transaction txn) async {
    late String relativePath;

    final test = (await txn.query(tableNotes,
        columns: [columnNotesRelativePath],
        where: '$columnNotesId = ?',
        whereArgs: [id]));
    relativePath = test.first[columnNotesRelativePath] as String;

    return relativePath;
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  Future<List<Map<String, Object?>>> _getNotes(Transaction txn) async {
    return txn
        .query(tableNotes, columns: [columnNotesId, columnNotesRelativePath]);
  }

  /// ======================================================
  ///
  ///
  ///
  /// ======================================================
  @override
  Future close() async {
    await db?.close();
  }
}
