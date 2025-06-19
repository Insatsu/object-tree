import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';

import 'package:object_tree/i18n/strings.g.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key});
  @override
  State<BrowsePage> createState() => _BrowsePageState();

  static bool onWillAcceptWithDetails(
      DragTargetDetails<DadItemDetail<Object>> itemDetails,
      DadItemDetail<BrowserItemEntity> targetFolder) {
    String targetFolderRelPath = targetFolder.dadItem.item!.relativePath;
    String itemRelPath =
        (itemDetails.data.dadItem.item as BrowserItemEntity).relativePath;

    var result = FileSystemRepository.isMoveSave(
        targetFolderRelPath, itemRelPath, GetIt.I<INodeRepository>().path);

    return result;
  }

  static Future<bool?> onAcceptWithDetails(
      DragTargetDetails<DadItemDetail<Object>> itemDetails,
      DadItemDetail<BrowserItemEntity> targetFolder) async {
    // =========
    // SKIP PART
    // * If target is item's parrent -> skip
    if (targetFolder.dadItem as IDadList == itemDetails.data.parrent) {
      return null;
    }
    // * If target is item
    if (targetFolder.dadItem is! DadRootList &&
        targetFolder.dadItem == itemDetails.data.dadItem) {
      return null;
    }
    // END SKIP PART
    // =========

    if (onWillAcceptWithDetails(itemDetails, targetFolder)) {
      await GetIt.I<INodeRepository>().moveNoteFolder(
          (itemDetails.data.dadItem.item as BrowserItemEntity).relativePath,
          targetFolder.dadItem.item!.relativePath);

      GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
      return true;
    }

    return false;
  }
}

class _BrowsePageState extends State<BrowsePage> {
  @override
  void initState() {
    GetIt.I<BrowserBloc>().add(const BrowserLoadNotesList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: const BrowserPageAppBar(),
      drawer: const BpDrawer(),
      drawerEdgeDragWidth: double.infinity,
      body: BlocConsumer<BrowserBloc, BrowserState>(
        bloc: GetIt.I<BrowserBloc>(),
        listener: (context, state) {
          if (state is BrowserLoadingFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              showCloseIcon: true,
                content: Text(t.global_error.root_directory_not_exist)));
            context.goNamed(START_ROUTE);
          }
          if (state is BrowserRenameFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              showCloseIcon: true,
                content: Text(t.browser_content.ban_symbol_item_title)));
          }
        },
        buildWhen: (previous, current) {
          return current is BrowserLoading ||
              current is BrowserLoaded ||
              current is BrowserLoading;
        },
        // * Browser page content
        builder: (context, state) {
          if (state is BrowserInitial || state is BrowserLoading) {
            return Center(
              child: Text(t.browser_content.loading),
            );
          }

          // * Loaded content
          else if (state is BrowserLoaded) {
            // * If directory empty
            if (state.itemsList.isEmpty) {
              return Center(
                child: Text(
                  t.browser_content.empty,
                  style: theme.textTheme.bodyMedium,
                ),
              );
            }

            // * If directory has any files
            return BrowserItemsList(
              blocState: state,
            );
          }

          // * Заглушка
          return Center(child: Text(t.browser_content.plug));
        },
      ),
      bottomNavigationBar: RootNavBarClassic(
        pageIndex: 0,
        navigationShell: StatefulNavigationShell.of(context).widget,
      ),
    );
  }
}
