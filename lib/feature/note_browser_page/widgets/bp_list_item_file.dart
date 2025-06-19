import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/data/data.dart';

import 'widgets.dart';

// * Itself line with file title. also button to go to file
class BpListItemFile extends StatefulWidget {
  const BpListItemFile(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.closeMenu,
      required this.isEdit});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final bool isEdit;

  final double tileHeight;
  final Function({bool? shouldClose}) closeMenu;

  @override
  State<BpListItemFile> createState() => _BpListItemFileState();
}

class _BpListItemFileState extends State<BpListItemFile> {
  Offset? _globalDetailOffset;

  @override
  Widget build(BuildContext context) {
    return DadItemTile(
      itemDetail: widget.itemDetail,
      // * ==========================
      // * Draggable part
      feedback: FeedbackWidget(
          itemDetail: widget.itemDetail, tileHeight: widget.tileHeight),
      childWhenDragging: ChildWhenDraggingWidget(
          itemDetail: widget.itemDetail, tileHeight: widget.tileHeight),
      properties: LongPressDraggableProperties(
        dragAnchorStrategy: (draggable, context, position) =>
            Offset(0, ListItem.FEEDBACK_HEIGHT),
      ),
      onDragUpdate: (details) {
        _globalDetailOffset = details.globalPosition;
      },
      onDragEnd: (details) {
        var tt0 = (context.findRenderObject() as RenderBox);
        var tt = tt0.localToGlobal(Offset.zero);
        var tt1 = tt0.size;

        _globalDetailOffset ??= Offset(tt.dx + 1, tt.dy + 1);

        if (_globalDetailOffset!.dy >= tt.dy &&
            _globalDetailOffset!.dy <= tt.dy + tt1.height) {
          widget.closeMenu();
        }
      },
      // * End Draggable part
      // * ==========================

      // * Go to note on tap on it
      onTap: () {
        widget.closeMenu(shouldClose: true);
        context.goNamed(NOTE_ROUTE, pathParameters: {
          NOTE_RELATIVE_PATH_ROUTE: widget.itemDetail.dadItem.item!.relativePath
        });
      },
      minTileHeight: widget.tileHeight,
      shape: widget.isEdit
          ? Border.all(color: Theme.of(context).colorScheme.primary)
          : null,
      leading: BpItemIcon(itemDetail: widget.itemDetail),

      title: BpItemListTitle(
        itemDetail: widget.itemDetail,
        tileHeight: widget.tileHeight,
        isEdit: widget.isEdit,
      ),

      // * If file extension is not ".md" then show it
      trailing: widget.itemDetail.dadItem.item!.itemExtension != MD_EXTENSION
          ? Container(
              decoration: BoxDecoration(
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
                borderRadius: const BorderRadius.all(Radius.elliptical(5, 4)),
              ),
              padding: const EdgeInsets.all(2),
              child: Text(widget.itemDetail.dadItem.item!.itemExtension),
            )
          : null,
    );
  }
}
