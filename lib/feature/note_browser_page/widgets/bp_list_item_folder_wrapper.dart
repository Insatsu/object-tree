import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';


class BpListItemFolderWrapper extends StatefulWidget {
  const BpListItemFolderWrapper(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.isEdit});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;
  final bool isEdit;


  @override
  State<BpListItemFolderWrapper> createState() =>
      _BpListItemFolderWrapperState();
}

class _BpListItemFolderWrapperState extends State<BpListItemFolderWrapper> {
  final MenuController controller = MenuController();


  @override
  Widget build(BuildContext context) {
    return BpListItemMenuAnchor(
        itemDetail: widget.itemDetail,
        tileHeight: widget.tileHeight,
        controller: controller,
        child: BpListItemFolder(
          itemDetail: widget.itemDetail,
          tileHeight: widget.tileHeight,
          isEdit: widget.isEdit,
          openCloseMenu: () {
            if (controller.isOpen) {
              controller.close();
            } else {
              controller.open();
            }
          },
        ));
  }
}
