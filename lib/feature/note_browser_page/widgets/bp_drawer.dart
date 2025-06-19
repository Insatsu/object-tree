import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class BpDrawer extends StatefulWidget {
  const BpDrawer({super.key});

  @override
  State<BpDrawer> createState() => _BpDrawerState();
}

class _BpDrawerState extends State<BpDrawer> {
  @override
  Widget build(BuildContext context) {
    return GenDrawer(
      drawerExpandedBody: ListView(
        children: [
          SwitchAppTheme(bloc: GetIt.I<RootBloc>()),
          // const SwitchAppLocale()
        ],
      ),
      drawerFooter: Row(
        children: [
          // Go to start screen
          IconButton(
            padding: EdgeInsets.all(0),
            iconSize: ICON_SIZE_MEDIUM,
            onPressed: () {
              GetIt.I<INodeRepository>()
                  .removeRepositoryPathFromSharedPrefences();
              context.goNamed(START_ROUTE);
            },
            icon: const Icon(
              Icons.delete_forever_outlined,
            ),
            tooltip: t.browser_drawer.hint_delete_path,
          ),
          // Choose new directory
          IconButton(
            iconSize: ICON_SIZE_MEDIUM,
            onPressed: () {
              GetIt.I<INodeRepository>().getNewRepositoryPathByUser();
            },
            icon: const Icon(
              Icons.create,
            ),
            tooltip: t.browser_drawer.hint_edit_path,
            alignment: AlignmentDirectional.centerEnd,
          ),
          const Spacer(),
          // Create a folder
          IconButton(
              iconSize: ICON_SIZE_MEDIUM,
              alignment: AlignmentDirectional.centerEnd,
              tooltip: t.browser_drawer.hint_create_folder,
              onPressed: () {
                Scaffold.of(context).closeDrawer();
                GetIt.I<BrowserBloc>().add(
                    BrowserCreateFolder(relativePath: FOLDER_TITLE_DEFAULT));
              },
              icon: const Icon(
                Icons.create_new_folder_outlined,
              )),
          // Create a note
          IconButton(
              iconSize: ICON_SIZE_MEDIUM,
              alignment: AlignmentDirectional.center,
              tooltip: t.browser_drawer.hint_create_note,
              onPressed: () {
                Scaffold.of(context).closeDrawer();

                GetIt.I<BrowserBloc>().add(BrowserCreateNote(
                    relativePath: NOTE_TITLE_WITH_EXTANSION_DEFAULT));
              },
              icon: const Icon(
                Icons.note_add_outlined,
              )),
        ],
      ),
    );
  }
}
