import 'package:object_tree/data/entities/browser_item.dart';

// ignore: must_be_immutable
class FolderEntity extends BrowserItemEntity {
  FolderEntity(
      {required super.relativePath,
      this.isExpanded = false,
      required String id})
      : _id = id;

  bool isExpanded;

  final String _id;

  @override
  List<Object?> get props => [relativePath];
}
