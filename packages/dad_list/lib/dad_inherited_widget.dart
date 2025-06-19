import 'dart:async';

import 'package:flutter/material.dart';

import 'dad.dart';

/// 
/// Contain info that need to right work of [DadListPast]
/// 
class DadInherited extends InheritedWidget {
  const DadInherited(
      {super.key,
      required this.rootListKey,
      required this.verticalPadding,
      required super.child,
      required this.expansionTileExpandTimer,
      required this.rootListController,
      required TimerWrapper scrollRootListTimer,
     })
      : _scrollRootListTimer = scrollRootListTimer;
  ///
  /// Timer that defines needed time to expand [DadItemTilePast] when an item covered it
  /// 
  final TimerWrapper expansionTileExpandTimer;
  ///
  /// Timer that managed scroll root list on draggable item on widget edges 
  ///
  final TimerWrapper _scrollRootListTimer;
  ///
  /// Root list [ScrollController] used for scroll root list on draggable item on widget edges
  ///
  final ScrollController rootListController;
  ///
  /// Root list global key to find the dy of it in screen. Used for scrolling root list 
  ///
  final GlobalKey rootListKey;
  ///
  ///
  ///
  final int verticalPadding;

  /// Start periodic animation of scroll root list when draggable item located above widget edge
  /// 
  /// [verticalPadding] defines a padding from widget edges. In those areas it begins root list scrolling
  /// [singleDuration] is duration of single scroll animation that periodic repeats
  /// [whereToScroll] it direction of scroll. 1 - up, -1 - down, 0 - nothing
  /// 
  void startAnimateRootList(
      Duration singleDuration, int whereToScroll) {
    if (_scrollRootListTimer.timer != null) {
      return;
    }

    _scrollRootListTimer.timer = Timer.periodic(singleDuration, (timer) {
      _startAnimateRootList(whereToScroll, singleDuration);
    });
  }

  /// Stop animation
  /// 
  /// Cancel timer that manages scroll
  ///
  void stopAnimateRootList() {
    _scrollRootListTimer.timer?.cancel();
    _scrollRootListTimer.timer = null;
  }

  ///
  void _startAnimateRootList(
      int whereToScroll, Duration singleDuration) {
    if (!rootListController.hasClients) {
      return;
    }
    double offsetScroll =
        rootListController.position.pixels + verticalPadding * whereToScroll;

    if (offsetScroll < 0) {
      offsetScroll = 0;
    }
    if (offsetScroll > rootListController.position.maxScrollExtent) {
      offsetScroll = rootListController.position.maxScrollExtent;
    }

    /// Scroll to newValue
    ///
    rootListController.animateTo(offsetScroll,
        duration: singleDuration, curve: Curves.easeOut);
  }



  static DadInherited? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<DadInherited>();
  }

  static DadInherited of(BuildContext context) {
    final DadInherited? result = maybeOf(context);

    assert(result != null, 'No FrogColor found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) {
    return expansionTileExpandTimer != expansionTileExpandTimer;
  }
}
