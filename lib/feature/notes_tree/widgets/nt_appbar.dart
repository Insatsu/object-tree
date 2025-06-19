import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/feature/notes_tree/bloc/nt_bloc.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NtAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NtAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        t.headers.tree,
      ),
      centerTitle: true,
      scrolledUnderElevation: 0.0,
      backgroundColor: Theme.of(context).colorScheme.surface,
      bottom: PreferredSize(
          preferredSize: preferredSize,
          child: Divider(
            thickness: 1,
            height: 1,
            color: Theme.of(context).dividerColor,
          )),
      actions: [
        IconButton(
            onPressed: () {
              _ntBlocSetLoad(context);
            },
            icon: const Icon(Icons.auto_stories_outlined)),
        IconButton(
            onPressed: () {
              _ntShowHistoryRelativeNotes(context);
            },
            icon: const Icon(Icons.tips_and_updates_outlined)),
      ],
    );
  }

  void _ntBlocSetLoad(BuildContext context) {
    BlocProvider.of<NtBloc>(context).add(NtUpdateTree());
  }

  void _ntShowHistoryRelativeNotes(BuildContext context) {
    Scaffold.of(context).openEndDrawer();
  }

  @override
  Size get preferredSize => const Size.fromHeight(APPBAR_HEIGHT);
}
