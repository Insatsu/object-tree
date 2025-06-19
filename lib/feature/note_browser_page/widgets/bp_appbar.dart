import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class BrowserPageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrowserPageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(
          Icons.menu,
        ),
        onPressed: () {
          Scaffold.of(context).openDrawer();
        },
      ),
      title: Text(
        t.headers.browser,
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
              GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
            },
            icon: const Icon(Icons.update)),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(APPBAR_HEIGHT);
}
