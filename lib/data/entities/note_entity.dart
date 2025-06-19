import 'package:object_tree/data/entities/browser_item.dart';

class NoteEntity extends BrowserItemEntity {
  const NoteEntity({super.relativePath = "./"});


  @override
  List<Object?> get props => [relativePath];
}
