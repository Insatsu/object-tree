import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:path/path.dart' as p;
import 'package:permission_handler/permission_handler.dart';
import 'package:talker_flutter/talker_flutter.dart';

class FileSystemRepository {
  final String _titleFileSystemRepository = 'FileSystemRepository';

  // =========================================================================
  // Start Move part
  ///
  static bool isMoveSave(
      String targetFolderRelPath, String moveItem, String rootPath) {
    var moveItemNewRelPath = p.join(targetFolderRelPath, p.basename(moveItem));
    return FileSystemRepository.isExclusiveTitle(moveItemNewRelPath, rootPath);
  }

  ///
  /// Move file by old and new path.
  ///
  /// Both [oldPathWithTitle] and [newParentPath] are full paths
  ///
  /// [oldPathWithTitle] is path and file title with extension
  ///
  /// [newParentPath] is path without file title
  ///
  static Future<void> moveFileDirectoryByPath(
      String oldPathWithTitle, String newParentPath) async {
    late FileSystemEntity item;

    if (isFile(oldPathWithTitle)) {
      item = FileSystemRepository.getFileFromPath(oldPathWithTitle);
    } else {
      item = FileSystemRepository.getDirectoryFromPath(oldPathWithTitle);
    }

    var path = item.path;
    var fileTitle = p.basename(path);
    var newPathWithFile = p.join(newParentPath, fileTitle);
    await item.rename(newPathWithFile);
  }

  // End   Move part
  // =========================================================================

  // =========================================================================
  // Start Title part

  ///
  static Future<void> renameFile(String fullPath, String newName) async {
    // var newPath = changeTitleInPathWithExtension(file.path, newName);
    var newPath = changeTitleInPathWithExtension(fullPath, newName);
    var file = File(fullPath);

    await file.rename(newPath);
  }

  static Future<void> renameDirectory(String fullPath, String newName) async {
    var newPath = changeTitleInPathWithExtension(fullPath, newName);
    var directory = Directory(fullPath);

    await directory.rename(newPath);
  }

  Future<void> renameFileDirectory(String fullPath, String newName) async {
    if (isFile(fullPath)) {
      await renameFile(fullPath, newName);
      return;
    }
    await renameDirectory(fullPath, newName);
  }

  /// *
  /// *
  /// *
  static bool isExclusiveTitle(String relativePath, String path) {
    var fullPath = p.join(path, relativePath);

    bool result = !FileSystemRepository.isFileExistByPath(fullPath) && !FileSystemRepository.isDirectoryExistByPath(fullPath);

    return result;
  }

  /// Check if title is not exclusive. If so change it by adding digit in the end or increment digit if title already has it
  /// If exclusive return
  /// Extension and type need to separate folders from files
  /// 
  /// [returnThisTitleIfWas] works in case if [relativePath] contains not exclusive title. 
  /// If in process of defining a new exclusive title with a copy number it gets new title as [returnThisTitleIfWas] 
  /// process is stoped and [getExclusiveTitle] return it
  /// 
  /// Define copy number only higher that current so if there was free copy-num before it not find it
  ///
  /// Return only title. Without extension
  static String getExclusiveTitle(String relativePath, String path,
      {String? returnThisTitleIfWas}) {
    String titleWithotExtension = p.basenameWithoutExtension(relativePath);
    String currentRelativePath = relativePath;

    GetIt.I<Talker>().debug(
        'FileSystemRepository getExclusiveTitle:\n relative: $relativePath\n path: $path');

    while (!FileSystemRepository.isExclusiveTitle(currentRelativePath, path)) {
      var textsplit = titleWithotExtension.split(' ');
      // * If text with 'space' and last symbol is digit
      if (textsplit.length > 1 && int.tryParse(textsplit.last) != null) {
        titleWithotExtension =
            '${textsplit.sublist(0, textsplit.length - 1).join(' ')} ${int.parse(textsplit.last) + 1}';
      }
      // * Else just add '1'
      else {
        titleWithotExtension = '$titleWithotExtension 1';
      }

      // 
      if (returnThisTitleIfWas != null &&
          titleWithotExtension == returnThisTitleIfWas) {
        break;
      }

      currentRelativePath = changeTitleInPathWithExtension(
          currentRelativePath, titleWithotExtension);

      GetIt.I<Talker>().debug(
          'FileSystemRepository in loop:\n currrelative: $currentRelativePath');
    }

    return titleWithotExtension;
  }

  ///
  /// Take extension from [fullPath] and then add it to [newTitle]
  ///
  static String changeTitleInPathWithExtension(
      String fullPath, String newTitle) {
    var oldTitle = p.basename(fullPath);
    var extension = p.extension(fullPath);
    var newPath = fullPath.replaceFirst(
        oldTitle, "$newTitle$extension", fullPath.lastIndexOf(oldTitle));

    return newPath;
  }

  // End   Title part
  // =========================================================================

  // =========================================================================
  // Start File content
  static String getFileContentAsLines(File file) {
    return file.readAsStringSync();
  }

  static Future<void> writeContentToFile(File file, String content) async {
    await file.writeAsString(content);
  }

  /// End   File content
  /// =========================================================================

  static File getFileFromPath(String path) {
    File file = File(path);
    return file;
  }

  static Directory getDirectoryFromPath(String path) {
    Directory folder = Directory(path);
    return folder;
  }

  static bool isFileExistByPath(String path) {
    File file = getFileFromPath(path);
    return file.existsSync();
  }
  static bool isDirectoryExistByPath(String path) {
    Directory directory = Directory(path);
    return directory.existsSync();
  }

// !==

  static Future<File> createFileByPath(String fullPath) async {
    File file = await File(fullPath).create(exclusive: true);
    return file;
  }

  static Future<Directory> createDirectoryByPath(String fullPath) async {
    Directory directory = await Directory(fullPath).create();
    return directory;
  }

  static Future<void> deleteFileByPath(String path) async {
    await File(path).delete();
  }

  static Future<void> deleteDirectoryByPath(String path) async {
    await Directory(path).delete(recursive: true);
  }

  static Future<void> deleteFile(File file) async {
    await file.delete();
  }

  static bool isFile(String fullPath) {
    return FileSystemEntity.isFileSync(fullPath);
  }

  static bool isDirectory(String fullPath) {
    return FileSystemEntity.isDirectorySync(fullPath);
  }

  // * Getting permission if its not
  Future<PermissionStatus> getPermissionIfNot() async {
    if (await Permission.manageExternalStorage.isDenied) {
      GetIt.I<Talker>().info(
          '$_titleFileSystemRepository getPermissionIfNot get permission');
      return await Permission.manageExternalStorage.request();
    }
    return Permission.manageExternalStorage.status;
  }

  List<String> getFilesRelativePathFromPath(String path) {
    List<String> result = [];
    List<String> skipFolders = [];

    Directory(path).listSync(recursive: true).forEach((e) {
      if (_shouldSkip(e) || skipFolders.contains(e.parent.path)) {
        if (FileSystemEntity.isDirectorySync(e.path)) {
          skipFolders.add(e.path);
        }
        return;
      }
      if (e is File) {
        result.add(p.relative(e.path, from: path));
      }
    });
    return result;
  }

  bool _shouldSkip(FileSystemEntity e) {
    for (var title in SKIP_CONTENT_TITLE) {
      if (p.basename(e.path).startsWith(title)) return true;
    }

    if (SKIP_CONTENT_EXTENSION.contains(p.extension(e.path))) return true;

    return false;
  }
}
