import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class BpListItemFolder extends StatefulWidget {
  const BpListItemFolder(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.openCloseMenu,
      required this.isEdit,
      });

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;
  final Function() openCloseMenu;
  final bool isEdit;

  @override
  State<BpListItemFolder> createState() => _BpListItemFolderState();
}

class _BpListItemFolderState extends State<BpListItemFolder> {
  ExpansionTileController controller = ExpansionTileController();

  Color? folderColor(BuildContext context) {
    return Theme.of(context).colorScheme.tertiary.withAlpha(50);
  }

  bool isEmptyFolder(BrowserItemNodeDad item) {
    return item.children.isEmpty && item.item! is FolderEntity;
  }

  @override
  Widget build(BuildContext context) {
    syncExpandedState();

    return DadItemExpansionTile(
      itemDetail: widget.itemDetail,

      // * ==========================
      // * Draggable part
      onDragEnd: (details) {
        var tt = (context.findRenderObject() as RenderBox)
            .localToGlobal(Offset.zero);
        var tt1 = (context.findRenderObject() as RenderBox).size;
        if (details.offset.dy >= tt.dy &&
            details.offset.dy <= tt.dy + tt1.height) {
          widget.openCloseMenu();
        }
      },
      feedback: FeedbackWidget(
          itemDetail: widget.itemDetail, tileHeight: widget.tileHeight),
      childWhenDragging: widget,
      onDragStarted: () {},
      onAcceptWithDetails: (details) {
        BrowsePage.onAcceptWithDetails(details, widget.itemDetail)
            .then((isComplete) {
          // * Show snackbar if it can't move item
          if (isComplete != null && !isComplete && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text(t.browser_content.dublicate_item_in_target_folder)));
          }
        });
      },
      // * End Draggable part
      // * ==========================
      controller: controller,
      
      childrenPadding:
          const EdgeInsetsDirectional.only(start: ListItem.CHILD_PADDING),

      leading: BpItemIcon(itemDetail: widget.itemDetail),
      maintainState: true,

      title: BpItemListTitle(
          itemDetail: widget.itemDetail,
          tileHeight: widget.tileHeight,
          isEdit: widget.isEdit),
      // * While editing
      collapsedShape: widget.isEdit
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
          : null,
      shape: widget.isEdit
          ? Border.all(color: Theme.of(context).colorScheme.primary, width: 1)
          : null,
      // * End editing
      subtitle: isEmptyFolder(widget.itemDetail.dadItem as BrowserItemNodeDad)
          ? const BpEmptyFolder()
          : const SizedBox.square(
              dimension: 0,
            ),
      controlAffinity: ListTileControlAffinity.leading,
      minTileHeight: widget.tileHeight,
      children: [
        ...List<ListItem>.generate(
            (widget.itemDetail.dadItem as BrowserItemNodeDad).children.length,
            (int index) {
          return ListItem(
              itemDetail: BrowserItemNodeDadDetails(
            (widget.itemDetail.dadItem as BrowserItemNodeDad).children[index],
            parrent: widget.itemDetail.dadItem as IDadList<BrowserItemEntity>,
            setStateParrent: () {
              setState(() {});
            },
          ));
        })
      ],
    );
  }

  void syncExpandedState() {
    try {
      if (controller.isExpanded ==
          (widget.itemDetail.dadItem as DadExpansionList).isExpanded) {
        return;
      }

      if (controller.isExpanded) {
        (widget.itemDetail.dadItem as DadExpansionList).isExpanded =
            controller.isExpanded;
        return;
      }
      if ((widget.itemDetail.dadItem as DadExpansionList).isExpanded) {
        controller.expand();
      } else {
        controller.collapse();
      }
    } catch (e) {}
  }
}
