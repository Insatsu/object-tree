import 'package:dad_list/dad_class.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';

class BpItemListTitle extends StatefulWidget {
  const BpItemListTitle(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.isEdit});
  final DadItemDetail<BrowserItemEntity> itemDetail;

  final double tileHeight;

  /// It is used for define what the widget should be: [Text] or [TextField]
  final bool isEdit;
  @override
  State<BpItemListTitle> createState() => __BpFileTileTextFieldState();
}

class __BpFileTileTextFieldState extends State<BpItemListTitle> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.text = widget.itemDetail.dadItem.item!.title;
  }

  @override
  Widget build(BuildContext context) {
    /// On every build if title is edit forced request focus on it
    ///
    /// (there may be a situation when was several build and [TextField] focus was lost)
    if (widget.isEdit) {
      _focusNode.requestFocus();
    }

    return widget.isEdit
        ? TextField(
            controller: _controller,
            maxLines: 1,
            autofocus: true,
            focusNode: _focusNode,
            onTapOutside: (event) {
              /// If tap outside than not saved and unfocus
              var oldRelPath = widget.itemDetail.dadItem.item!.relativePath;
              var oldRelTitle = widget.itemDetail.dadItem.item!.title;
              GetIt.I<BrowserBloc>().add(BrowserEndRenameItem(
                  newTitle: oldRelTitle, oldRelativePath: oldRelPath));
              _focusNode.unfocus();
            },
            onSubmitted: (newValue) {
              /// Try to save new title and unfocus
              var oldRelPath = widget.itemDetail.dadItem.item!.relativePath;
              GetIt.I<BrowserBloc>().add(BrowserEndRenameItem(
                  newTitle: newValue, oldRelativePath: oldRelPath));
              _focusNode.unfocus();
            },
            style: Theme.of(context).textTheme.bodyLarge)

        /// If not edit return [Text]
        : Text(widget.itemDetail.dadItem.item!.title,
            style: Theme.of(context).textTheme.bodyLarge);
  }

  @override
  void dispose() {
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    super.dispose();
  }
}
