import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/models/note_content_type.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:path/path.dart' as p;
import 'package:talker_flutter/talker_flutter.dart';

class NoteRepository {
  NoteRepository({required this.relativePath, required this.path});

  final String _titleNoteRepository = 'NoteRepository';

  String relativePath;
  final String path;

  NoteContentType? contentType;

  String get fullPath => p.join(path, relativePath);
  String get noteExtension => p.extension(relativePath);

  String get title => p.basenameWithoutExtension(relativePath);

  ///
  /// Check if new title is exclusive and can be used for note
  bool isExclusiveNotesTitle(String newTitle) {
    /// If new title is the same as current title it considers that all good
    if (newTitle.toLowerCase() == title.toLowerCase()) {
      return true;
    }

    String newRelaviePath = FileSystemRepository.changeTitleInPathWithExtension(
        relativePath, newTitle);

    return FileSystemRepository.isExclusiveTitle(newRelaviePath, path);
  }

  /// Return exclusive title by [newTitle]. 
  /// Compare [newTitle] with current with no register. If they're same return [newTitle]
  /// Else find exclusive title and return it
  /// 
  String getExclusiveTitle(String newTitle) {
    // If the [newTitle] is the same that before -> no change
    if (newTitle.toLowerCase() == title.toLowerCase()) {
      return newTitle;
    }

    var newRelativePath = FileSystemRepository.changeTitleInPathWithExtension(
        relativePath, newTitle.trimLeft());

    var newExlusiveTitle = FileSystemRepository.getExclusiveTitle(
        newRelativePath, path,
        returnThisTitleIfWas: title);

    return newExlusiveTitle;
  }

  static bool isNoteExist(String path) {
    return FileSystemRepository.isFileExistByPath(path);
  }

  /// Rename note/file with saving extension
  Future<void> renameNote(String newName) async {
    GetIt.I<Talker>().info('$_titleNoteRepository renameNote');

    if (!isExclusiveNotesTitle(newName)) {
      throw FileInclusiveTitle('Already exist file with this name');
    }

    String newRelativePath = await _renameNote(newName);
    relativePath = newRelativePath;
    GetIt.I<Talker>().info('$_titleNoteRepository renameNote successufuly');
  }

  /// Get file from relative Path. Вспомогательный метод
  File fileFromRelativePath() {
    return FileSystemRepository.getFileFromPath(fullPath);
  }

  /// If content type is 0 return itself.
  /// Else return file path to work with it in widgets
  // (int, String) getFileContent() {
  (NoteContentType?, String) getFileContent() {
    GetIt.I<Talker>().info('$_titleNoteRepository getFileContent');

    String content = '';

    try {
      if (TEXT_EXTENSIONS.contains(noteExtension)) {
        content = _getFileContentString();
        contentType = NoteContentText();
      }
      else if (MEDIA_EXTENSIONS.contains(noteExtension)) {
        content = fullPath;
        contentType = NoteContentMedia();
      }
    } catch (e) {
      GetIt.I<Talker>().info('$_titleNoteRepository Exception');
      content = relativePath;
      contentType = NoteContentUnknown();
    }

    return (contentType, content);
  }

  /// Save changes content
  Future<void> saveContent(String content) async {
    GetIt.I<Talker>().info('$_titleNoteRepository saveChanges');
    File file = fileFromRelativePath();
    await FileSystemRepository.writeContentToFile(file, content);
  }

  Future<void> deleteNote() async {
    await FileSystemRepository.deleteFile(fileFromRelativePath());
  }

  Future<void> createNote() async {
    await GetIt.I<INodeRepository>().createNote(relativePath);
  }

// =====================================================
// * Private

  /// * Get file content
  String _getFileContentString() {
    GetIt.I<Talker>().info('$_titleNoteRepository getFileContentString');
    return FileSystemRepository.getFileContentAsLines(fileFromRelativePath());
  }

  Future<String> _renameNote(String newName) async {
    return await GetIt.I<INodeRepository>().renameNote(fullPath, newName);
  }
}


class FileInclusiveTitle implements Exception{
  String message;
  FileInclusiveTitle(this.message); 
}