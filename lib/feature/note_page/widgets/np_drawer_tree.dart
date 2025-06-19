import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NpDrawerTree extends StatelessWidget {
  const NpDrawerTree({super.key, required this.noteEnt});

  final DbNote noteEnt;

  @override
  Widget build(BuildContext context) {
    return Material(
        child: InkWell(
      onTap: () {
        GetIt.I<BrowserBloc>().add(BrowserShowTreeWith(note: noteEnt));
      },
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(Icons.account_tree_outlined),
        title: Text(t.note_drawer.show_local_tree),
      ),
    ));
  }
}
