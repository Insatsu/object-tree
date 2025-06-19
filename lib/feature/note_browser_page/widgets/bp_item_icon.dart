import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';

class BpItemIcon extends StatelessWidget {
  const BpItemIcon({super.key, required this.itemDetail, this.iconSize});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double? iconSize;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var rightIcon = IconsStore(size: iconSize);

      if (itemDetail.dadItem.item! is NoteEntity) {
        return rightIcon.file();
      }
      if (itemDetail.dadItem.item! is FolderEntity) {
        if ((itemDetail.dadItem as BrowserItemNodeDad).children.isEmpty) {
          return rightIcon.emptyFolder();
        }
        return (itemDetail.dadItem as BrowserItemNodeDad).isExpanded
            ? rightIcon.openFolder()
            : rightIcon.closedFolder();
      }
      return Icon(
        Icons.question_mark_outlined,
        size: iconSize,
      );
    });
  }
}
