import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/feature/general/data_widget.dart';
import 'package:object_tree/i18n/strings.g.dart';
import 'package:talker_flutter/talker_flutter.dart';

class RootNavBarClassic extends StatelessWidget {
  const RootNavBarClassic({super.key, required this.navigationShell, required this.pageIndex});

  final StatefulNavigationShell navigationShell;
  final int pageIndex;

  @override
  Widget build(BuildContext context) {
    void openRightPage(int tappedIndex) {
      DataWidget.of(context).shownScreenIndex.value = tappedIndex;


      // * Hide keyboard on change Page
      SystemChannels.textInput.invokeMethod('TextInput.hide');

      GetIt.I<Talker>().debug(
          "NAVBAR: curr = ${navigationShell.currentIndex}\ntapped = $tappedIndex");

      // * If current page is the tapped page -> open it init state
      // * Else open branch
      navigationShell.goBranch(tappedIndex,
          initialLocation: tappedIndex == pageIndex);
    }

    return NavigationBar(
      destinations: destinations,
      selectedIndex: pageIndex,
      onDestinationSelected: openRightPage,
    );
  }
}

final destinations = <NavigationDestination>[
  NavigationDestination(
      selectedIcon: const Icon(
        Icons.subdirectory_arrow_right_sharp,
      ),
      label: t.bottom_navigation.home,
      icon: const Icon(
        Icons.home,
      )),
  NavigationDestination(
    selectedIcon: const Icon(
      Icons.subdirectory_arrow_left_sharp,
    ),
    icon: const Icon(
      Icons.polyline_outlined,
    ),
    label: t.bottom_navigation.tree,
  ),
];
