// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:object_tree/feature/general/root_page.dart';
import 'package:object_tree/feature/note_browser_page/view/browser_page.dart';
import 'package:object_tree/feature/note_page/view/note_page.dart';
import 'package:object_tree/feature/notes_tree/view/notes_tree.dart';
import 'package:object_tree/feature/start_screen/view/start_screen.dart';
import 'package:talker_flutter/talker_flutter.dart';

const BROWSER_ROUTE = "browser";
const BROWSER_BRANCH_ID = 0;
const TREE_ROUTE = "tree";
const TREE_BRANCH_ID = 1;
const NOTE_ROUTE = "notie";
const NOTE_RELATIVE_PATH_ROUTE = "notesRelativePath";
const CREATE_NOTE_ROUTE = "createNote";
const START_ROUTE = "begin";

final _navkey = GlobalKey<NavigatorState>();
final _rootkey = GlobalKey();
final _stackkey = GlobalKey<StatefulNavigationShellState>();


// * Routes from GoRouter
final goRoutes = GoRouter(
  // * Observer for logging route
  observers: [TalkerRouteObserver(GetIt.I<Talker>())],
  debugLogDiagnostics: true,
  requestFocus: false,
  navigatorKey: _navkey,

  initialLocation: '/$BROWSER_ROUTE',

  redirect: (context, state) {
    if (state.fullPath == '') {
      return '/$BROWSER_ROUTE';
    }
    return null;
  },

  // * Routes from main level
  routes: [
    GoRoute(
      path: '/$START_ROUTE',
      name: START_ROUTE,
      pageBuilder: (context, state) => mypageBuilder(const StartScreen()),
    ),

    // * Like a container for pages. It need for navigationBar
    StatefulShellRoute.indexedStack(
      parentNavigatorKey: _navkey,
      key: _stackkey,
      
      // * Redirect if path == ''
      // * This may be happend on error in routing
      redirect: (context, state) async {
        // * There is catch routing error
        if (GetIt.I<INodeRepository>().path == '') {
          return '/$START_ROUTE';
        } else {
          return null;
        }
      },

      // * Make main screen with bottomNavBar. Inside it putting all pages
      pageBuilder: (context, state, navigationShell) => mypageBuilder(RootPage(
        key: _rootkey,
        navigationShell: navigationShell,
      )),

      // * Enumeration all main page (from bottomNavBar). Each main page can contain itself pages
      branches: [
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/$BROWSER_ROUTE',
              name: BROWSER_ROUTE,
              pageBuilder: (context, state) =>
                  mypageBuilder(const BrowsePage()),
              routes: [
                GoRoute(
                  path: '$NOTE_ROUTE/:$NOTE_RELATIVE_PATH_ROUTE',
                  name: NOTE_ROUTE,
                  pageBuilder: (context, state) => mypageBuilder(NotePage(
                    notesRelativePath:
                        state.pathParameters[NOTE_RELATIVE_PATH_ROUTE] ?? '',
                  )),
                ),
              ]),
        ]),
        StatefulShellBranch(routes: [
          GoRoute(
              path: '/$TREE_ROUTE',
              name: TREE_ROUTE,
              pageBuilder: (context, state) => mypageBuilder(const NotesTree()))
        ])
      ],
    )
  ],
);

Widget anTransition(context, Animation<double> animation,
    Animation<double> secondaryAnimation, child) {
  const double begin = 0;
  const double end = 1;
  const curve = Curves.easeOutExpo;

  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
  return FadeTransition(
    opacity: animation.drive(tween),
    child: child,
  );
}

Widget someTransition(BuildContext context, Animation<double> animation,
    Animation<double> secondaryAnimation, Widget child) {
  return FadeTransition(
    opacity: animation,
    child: child,
  );
}

Page mypageBuilder(Widget widget) {
  return CustomTransitionPage<void>(
      child: widget,
      transitionsBuilder: someTransition,
      transitionDuration: const Duration(milliseconds: 100),
      reverseTransitionDuration: const Duration(milliseconds: 100));
}
