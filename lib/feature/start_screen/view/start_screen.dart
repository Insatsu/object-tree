import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // =======================================================================
            // * Offer to choose directory
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                t.start.choose_directory,
                textAlign: TextAlign.center,
              ),
            ),
            // =======================================================================
            // * Button that allow choose directory
            ElevatedButton(
                onPressed: () async {
                  // * Get permission
                  await GetIt.I<INodeRepository>().initFilePermissionIfNot();
                  GetIt.I<INodeRepository>()
                      .getNewRepositoryPathByUser()
                      .then((openApp) {
                    if (context.mounted) {
                      openApp ? context.goNamed(BROWSER_ROUTE) : null;
                    }
                  });
                },
                child: Text(t.start.choose_directory_btn)),
            // =======================================================================
            // * If already choosen directories before show list of it
            // =======================================================================
            StatefulBuilder(
              builder: (context, setState) => LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        if (SharedpreferencesRepository()
                            .previousPaths
                            .isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(
                                left: 40, right: 40, top: 10),
                            child: Text(
                              t.start.choose_directory_history,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 15, fontStyle: FontStyle.normal),
                            ),
                          ),
                        // * Previous paths
                        ...List.generate(
                            SharedpreferencesRepository().previousPaths.length,
                            (index) {
                          return SizedBox(
                              height: 30,
                              child: TextButton(
                                onPressed: () {
                                  GetIt.I<INodeRepository>()
                                      .setPath(SharedpreferencesRepository()
                                          .previousPaths[index])
                                      .then((_) {
                                    // * Event to Bloc for update
                                    GetIt.I<BrowserBloc>()
                                        .add(const BrowserLoadNotesList());
                                  });
                                  context.goNamed(BROWSER_ROUTE);
                                },
                                onLongPress: () {
                                  GetIt.I<INodeRepository>()
                                      .sharedPref
                                      .removeFromPreviousPaths(index);
                                  setState(() {});
                                },
                                style: const ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsetsDirectional.zero),
                                ),
                                child: Text(
                                  SharedpreferencesRepository()
                                      .previousPaths[index],
                                ),
                              ));
                        })
                      ]);
                },
              ),
            )
            // =======================================================================
          ],
        ),
      ),
    );
  }
}
