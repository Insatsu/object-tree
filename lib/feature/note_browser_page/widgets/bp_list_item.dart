import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';


/// Item of list. Define what type of item is it and return need widget
class ListItem extends StatefulWidget {
  const ListItem({super.key, required this.itemDetail});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  static const double CHILD_PADDING = 15;
  static const double TILE_HEIGHT = 15;
  static const double FEEDBACK_HEIGHT = 50;
  static const double FEEDBACK_WIDTH = 150;

  @override
  State<ListItem> createState() => _ListItemState();
}

class _ListItemState extends State<ListItem> {

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrowserBloc, BrowserState>(
      bloc: GetIt.I<BrowserBloc>(),
      buildWhen: (previous, current) {
        return (current is BrowserBeginRenameObject) ||
            current is BrowserComplitedRenameObject;
      },
      builder: (context, state) {
        var isEdit = false;
        if (state is BrowserBeginRenameObject &&
            state.relativePath ==
                widget.itemDetail.dadItem.item!.relativePath) {
          isEdit = true;
        }

        // * There key is needed for correct work on rename items. Especially if item is in list body (not in edge)
        return widget.itemDetail.dadItem.item is FolderEntity
            ? BpListItemFolderWrapper(
                key: ValueKey(widget.itemDetail.dadItem.item),
                // key: UniqueKey(),
                itemDetail: widget.itemDetail,
                isEdit: isEdit,
                tileHeight: ListItem.TILE_HEIGHT)
            : BpListItemFileWrapper(
                key: ValueKey(widget.itemDetail.dadItem.item),
                itemDetail: widget.itemDetail,
                isEdit: isEdit,
                tileHeight: ListItem.TILE_HEIGHT,
              );
      },
    );
  }
}

class FeedbackWidget extends StatelessWidget {
  const FeedbackWidget(
      {super.key, required this.itemDetail, required this.tileHeight});
  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;

  bool isEmptyFolder(BrowserItemNodeDad item) {
    return item.children.isEmpty && item.item! is FolderEntity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: ListItem.FEEDBACK_WIDTH,
        height: ListItem.FEEDBACK_HEIGHT,
        color: Theme.of(context).colorScheme.tertiary.withAlpha(255),
        padding: EdgeInsets.only(left: 5),
        child: Row(
          children: [
            BpItemIcon(
              itemDetail: itemDetail,
              iconSize: 30,
            ),
            Expanded(
              child: Text(
                itemDetail.dadItem.item!.title,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Theme.of(context).colorScheme.onTertiary),
              ),
            ),
          ],
        ));
  }
}

class ChildWhenDraggingWidget extends StatelessWidget {
  const ChildWhenDraggingWidget(
      {super.key, required this.itemDetail, required this.tileHeight});
  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;

  bool isEmptyFolder(BrowserItemNodeDad item) {
    return item.children.isEmpty && item.item! is FolderEntity;
  }

  @override
  Widget build(BuildContext context) {

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: Color.fromARGB(0, 85, 255, 0),
        child: ListTile(
          leading: BpItemIcon(itemDetail: itemDetail),
          tileColor: Theme.of(context).colorScheme.primary.withAlpha(50),
          isThreeLine: false,
          title: Text(
            itemDetail.dadItem.item!.title,
            softWrap: false,
          ),
          subtitle: isEmptyFolder(itemDetail.dadItem as BrowserItemNodeDad)
              ? const BpEmptyFolder()
              : const SizedBox.square(
                  dimension: 0,
                ),
          minTileHeight: tileHeight,
        ),
      ),
    );
  }
}
