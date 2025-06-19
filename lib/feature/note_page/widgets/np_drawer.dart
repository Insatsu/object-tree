import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_page/note_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NPDrawer extends StatefulWidget {
  const NPDrawer({super.key});

  @override
  State<NPDrawer> createState() => _NPDrawerState();
}

class _NPDrawerState extends State<NPDrawer> {
  static const List<double> paddingsLTRB = [28.0, 16.0, 16.0, 10.0];
  late NoteBloc bloc;

  @override
  void initState() {
    bloc = BlocProvider.of<NoteBloc>(context);
    GetIt.I<INodeRepository>().getNotes().then((notes) {
      bloc.notes =
          notes.map((el) => NoteEntity(relativePath: el.relativePath)).toList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GenDrawer(
      drawerExpandedBody: ListView(
        padding: EdgeInsets.zero,
        children: [
          NpDrawerTree(
            noteEnt:
                DbNote.relativePath(relativePath: bloc.noteRepository!.relativePath)
          ),
          const NpLink(linkType: 0),
          const NpLink(linkType: 1),
        ],
      ),
      drawerFooter: Padding(
        padding: EdgeInsets.only(right: paddingsLTRB.elementAt(2)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TextButton.icon(
                onPressed: () => showSearchNoteSheet(bloc),
                icon: const Icon(Icons.add),
                label: Text(t.note_drawer.add_forwardLinked_note)),
          ],
        ),
      ),
    );
  }

  void showSearchNoteSheet(NoteBloc bloc) {
    showModalBottomSheet(
        isScrollControlled: true,
        showDragHandle: true,
        useSafeArea: true,
        elevation: 0,
        context: context,
        builder: (context) {
          return NpSearchSheet(bloc: bloc);
        });
  }
}
