import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';

class BpListItemFileWrapper extends StatelessWidget {
  const BpListItemFileWrapper(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.isEdit});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;
  final bool isEdit;

  @override
  Widget build(BuildContext context) {
    final MenuController controller = MenuController();

    return BpListItemMenuAnchor(
      itemDetail: itemDetail,
      tileHeight: tileHeight,
      controller: controller,
      child: BpListItemFile(
        itemDetail: itemDetail,
        tileHeight: tileHeight,
        isEdit: isEdit,
        closeMenu: ({shouldClose}) {
          if (shouldClose != null && shouldClose) {
            controller.close();
            return;
          }
          
          if (controller.isOpen) {
            controller.close();
          } else {
            controller.open();
          }
        },
      ),
    );
  }
}
