// ignore_for_file: unused_element_parameter

import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';
import 'package:path/path.dart' as p;

class BpListItemMenuAnchor extends StatefulWidget {
  const BpListItemMenuAnchor(
      {super.key,
      required this.itemDetail,
      required this.tileHeight,
      required this.child,
      required this.controller});

  final DadItemDetail<BrowserItemEntity> itemDetail;
  final double tileHeight;
  final Widget child;

  final MenuController controller;

  @override
  State<BpListItemMenuAnchor> createState() => _BpListItemMenuAnchorState();
}

class _BpListItemMenuAnchorState extends State<BpListItemMenuAnchor> {
  double dropdownMenuWidth = 150;

  final _menuKey = GlobalKey();

  // * Menu items
  final createNote = _MenuItem(
      text: t.browser_content.menu_create_note, icon: Icons.note_add_outlined);

  final createFolder = _MenuItem(
      text: t.browser_content.menu_create_folder,
      icon: Icons.create_new_folder_outlined);

  final rename =
      _MenuItem(text: t.browser_content.menu_rename, icon: Icons.edit_outlined);

  final delete = _MenuItem(
      text: t.browser_content.menu_delete, icon: Icons.delete_forever_outlined);

  // * Methods
  void onCreateFolder() {
    widget.controller.close();
    GetIt.I<BrowserBloc>().add(BrowserCreateFolder(
        relativePath: p.join(widget.itemDetail.dadItem.item!.relativePath,
            FOLDER_TITLE_DEFAULT)));
  }

  void onCreateNote() {
    widget.controller.close();
    GetIt.I<BrowserBloc>().add(BrowserCreateNote(
        relativePath: p.join(widget.itemDetail.dadItem.item!.relativePath,
            NOTE_TITLE_WITH_EXTANSION_DEFAULT)));
  }

  void onDeletePressed() {
    widget.controller.close();
    if (widget.itemDetail.dadItem.item is FolderEntity) {
      GetIt.I<INodeRepository>()
          .deleteFolderByRelativePath(
              widget.itemDetail.dadItem.item!.relativePath)
          .then((value) {
        GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
      });
    }
    if (widget.itemDetail.dadItem.item is NoteEntity) {
      GetIt.I<INodeRepository>()
          .deleteNoteByRelativePath(
              widget.itemDetail.dadItem.item!.relativePath)
          .then((value) {
        GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
      });
    }
  }

  void onRenamePressed() {
    widget.controller.close();
    GetIt.I<BrowserBloc>().add(BrowserStartRenameItem(
        relativePath: widget.itemDetail.dadItem.item!.relativePath));
  }

  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      key: _menuKey,
      controller: widget.controller,
      style: MenuStyle(
          alignment: AlignmentDirectional(1, -1),
          visualDensity: VisualDensity()),
      menuChildren: <Widget>[
        /// If its item is [FolderEntity] also show button for create inner folder and note
        if (widget.itemDetail.dadItem.item! is FolderEntity) ...[
          MenuItemButton(
            onPressed: onCreateFolder,
            child: buildItem(createFolder),
          ),
          MenuItemButton(
            onPressed: onCreateNote,
            child: buildItem(createNote),
          )
        ],

        /// Else show button only for rename and delete
        MenuItemButton(
          onPressed: onRenamePressed,
          child: buildItem(rename),
        ),
        MenuItemButton(
          onPressed: () {
            showDialogOnDelete(context, onDeletePressed);
          },
          child: buildItem(delete),
        ),
      ],
      child: widget.child,
    );
  }


  Widget buildItem(_MenuItem item) {
    return SizedBox(
      width: dropdownMenuWidth,
      child: Row(
        children: [
          Icon(
            item.icon,
            size: 22,
          ),
          const SizedBox(
            width: 10,
          ),
          Expanded(
            child: Text(
              item.text,
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> showDialogOnDelete(
      BuildContext context, void Function() onConfirm) {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            t.browser_content.dialog_delete_title,
          ),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(t.browser_content.dialog_delete_cancel)),
            TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm();
                },
                child: Text(t.browser_content.dialog_delete_confirm))
          ],
        );
      },
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.text,
    required this.icon,
  });

  final String text;
  final IconData icon;
}