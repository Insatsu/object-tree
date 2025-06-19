import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';

/// List widget of all notes
class BrowserItemsList extends StatefulWidget {
  const BrowserItemsList({super.key, required this.blocState});

  final BrowserLoaded blocState;

  @override
  State<BrowserItemsList> createState() => _BrowserItemsListState();
}

class _BrowserItemsListState extends State<BrowserItemsList> {
  late final DadItemDetail<BrowserItemEntity> rootListDetail;

  @override
  void initState() {
    super.initState();
    rootListDetail = BrowserItemNodeDadDetails(
      DadRootList(
          children: widget.blocState.itemsList,
          item: FolderEntity(relativePath: '', id: "root")),
      setStateParrent: () {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: DadList.builder(
        itemDetail: rootListDetail,
        itemCount: widget.blocState.itemsList.length,
        padding: const EdgeInsetsDirectional.only(top: 10),
        onAcceptWithDetails: (details) {
          BrowsePage.onAcceptWithDetails(details, rootListDetail);
        },
        itemBuilder: (context, index) {
          var itemDetail = BrowserItemNodeDadDetails(
            widget.blocState.itemsList[index],
            parrent: rootListDetail.dadItem as IDadList<BrowserItemEntity>,
            setStateParrent: () {
              setState(() {});
            },
          );

          return ListItem(
              key: ValueKey(itemDetail.dadItem.item), itemDetail: itemDetail);
        },
      ),
    );
  }
}
