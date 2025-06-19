import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/domain/usecases/db_init.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

class FileRepository {
  FileRepository({required this.path, required this.db});
  final String _titleFileRepository = "FileRepository";

  List<BrowserItemNodeDad> nodesList = [];
  List<DbNote> notes = [];
  String path;
  IDbProvider db;

  String _getItemPath(BrowserItemEntity item) {
    return p.join(path, item.relativePath);
  }

  List<BrowserItemNodeDad> getBItemNodeList() {
    GetIt.I<Talker>().debug("$_titleFileRepository getBItemNodeList start");
    _getNotesTreeList();

    // * Check is db's file exist. If not call initDbUseCase and then use db
    if (!FileSystemRepository.isFileExistByPath(db.path!)) {
      initDbUseCase(GetIt.I<INodeRepository>()).then((value) {
        if (value) {
          db.checkNotesInserts(notes);
        }
      });
    }
    // * Else just use db
    else {
      db.checkNotesInserts(notes);
    }

    GetIt.I<Talker>().debug("$_titleFileRepository getBItemNodeList end");
    return nodesList;
  }

  List<BrowserItemNodeDad> _getNotesTreeList() {
    notes.clear();
    nodesList = _folderContain(path);
    nodesList.sort(_compareNodes);
    return nodesList;
  }

  List<BrowserItemNodeDad> _folderContain(String folderPath,
      {bool isRecursive = false}) {
    List<BrowserItemNodeDad> temp = [];

    Directory(folderPath).listSync(recursive: isRecursive).forEach((e) {
      // * If its a file shouldn't be showed
      if (_shouldSkip(e)) {
        return;
      }
      

      if (e is Directory) {
        var currFold =
            FolderEntity(relativePath: p.relative(e.path, from: path), id: "${e.statSync().changed}");

        List<BrowserItemNodeDad> curNodes = _getFolderNodesList(currFold);
        temp.add(BrowserItemNodeDad(currFold.title,
            item: currFold, children: curNodes));
      }

      if (e is File) {
        notes.add(
            DbNote.relativePath(relativePath: p.relative(e.path, from: path)));
        var tempNote = NoteEntity(
          relativePath: p.relative(e.path, from: path),
        );
        temp.add(BrowserItemNodeDad(tempNote.title, item: tempNote));
      }
    });

    return temp;
  }

  List<BrowserItemNodeDad> _getFolderNodesList(FolderEntity folder) {
    var temp = _folderContain(_getItemPath(folder));
    temp.sort(_compareNodes);

    return temp;
  }

  int _compareNodes(BrowserItemNodeDad a, BrowserItemNodeDad b) {
    if (a.item! is FolderEntity && b.item! is FolderEntity) {
      return a.item!.title.compareTo(b.item!.title);
    }

    if (a.item! is FolderEntity) return -1;
    if (b.item! is FolderEntity) return 1;

    return a.item!.title.compareTo(b.item!.title);
  }

  bool _shouldSkip(FileSystemEntity e) {
    if (SKIP_CONTENT_EXTENSION.contains(p.extension(e.path)) ||
        SKIP_CONTENT_TITLE.fold<bool>(
            false,
            (previous, element) =>
                previous ||
                p.basenameWithoutExtension(e.path).startsWith(element))) {
      return true;
    }
    return false;
  }
}
