import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/feature/note_page/note_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NpLinkItem extends StatefulWidget {
  const NpLinkItem({super.key, required this.linkType, required this.notes});

  final int linkType;
  final List<NoteEntity> notes;

  @override
  State<NpLinkItem> createState() => _NpLinkItemState();
}

class _NpLinkItemState extends State<NpLinkItem> {
  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(linkTitles[widget.linkType]),
      tilePadding: EdgeInsets.only(left: 5),
      childrenPadding:
          const EdgeInsetsDirectional.only(start: 20, top: 0, bottom: 0),
      minTileHeight: 15,
      children: [
        ...List<Widget>.generate(widget.notes.length, (index) {
          return ListTile(
            minTileHeight: 20,
            title: Text(widget.notes.elementAt(index).relativePath),
            onTap: () {
              context.goNamed(NOTE_ROUTE, pathParameters: {
                NOTE_RELATIVE_PATH_ROUTE:
                    widget.notes.elementAt(index).relativePath
              });
            },
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t.note_drawer.dialog_delete_title),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(t.note_drawer.dialog_delete_cancel)),
                      TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();

                            deleteRelation(index);

                            GetIt.I<BrowserBloc>()
                                .add(const BrowserUpdateLinks());
                          },
                          child: Text(t.note_drawer.dialog_delete_confirm))
                    ],
                  );
                },
              );
            },
          );
        })
      ],
    );
  }

  void deleteRelation(int index) {
    var bloc = BlocProvider.of<NoteBloc>(context);
    switch (widget.linkType) {
      case 0:
        bloc.add(NoteDeleteBackLinkedNoteFromDb(
            noteFrom: widget.notes.elementAt(index)));
        break;
      case 1:
        bloc.add(NoteDeleteForwardLinkedNoteFromDb(
            noteTo: widget.notes.elementAt(index)));
        break;
      default:
        Exception("Undefined relation type");
        break;
    }
  }
}
