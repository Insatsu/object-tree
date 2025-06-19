import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';
import 'package:flutter/rendering.dart';


class _DadListKey extends GlobalObjectKey {
  const _DadListKey(super.value);
}


class DadList extends StatelessWidget {
  const DadList({
    super.key,
    required this.itemDetail,
    this.verticalPaddingToScroll = 70,
    this.onAcceptWithDetails,
    this.onMove,
    this.onLeave,
    this.dragTargetproperties,
    // * List field
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    // this.physics,
    this.shrinkWrap = true,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    List<Widget> children = const <Widget>[],
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
  })  : _children = children,
        assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        _itemBuilder = null,
        _itemCount = null;
  const DadList.builder({
    super.key,
    required this.itemDetail,
    this.verticalPaddingToScroll = 70,
    this.onAcceptWithDetails,
    this.onMove,
    this.onLeave,
    this.dragTargetproperties,
    // * builder
    int? itemCount,
    required NullableIndexedWidgetBuilder itemBuilder,

    // * List field
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    // this.physics,
    this.shrinkWrap = true,
    this.padding,
    this.itemExtent,
    this.itemExtentBuilder,
    this.prototypeItem,
    this.addAutomaticKeepAlives = true,
    this.addRepaintBoundaries = true,
    this.addSemanticIndexes = true,
    this.cacheExtent,
    this.semanticChildCount,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.hitTestBehavior = HitTestBehavior.opaque,
  })  : assert(
          (itemExtent == null && prototypeItem == null) ||
              (itemExtent == null && itemExtentBuilder == null) ||
              (prototypeItem == null && itemExtentBuilder == null),
          'You can only pass one of itemExtent, prototypeItem and itemExtentBuilder.',
        ),
        _children = const [],
        _itemBuilder = itemBuilder,
        _itemCount = itemCount;

  /// Detail
  final DadItemDetail itemDetail;

  ///
  final int verticalPaddingToScroll;

  ///
  /// If [onAcceptWithDetails] is non-null it will call in [DragTarget] [onAcceptWithDetails] property
  /// after what [setState] will not call
  ///
  final DragTargetAcceptWithDetails<DadItemDetail>? onAcceptWithDetails;
  final DragTargetMove<DadItemDetail>? onMove;
  final DragTargetLeave<DadItemDetail>? onLeave;

  /// Additional properties
  final DragTargetProperties? dragTargetproperties;

  /// Lists
  final double? itemExtent;
  final ItemExtentBuilder? itemExtentBuilder;
  final Widget? prototypeItem;
  // not fields in ListView
  final List<Widget> _children;
  final int? _itemCount;
  final NullableIndexedWidgetBuilder? _itemBuilder;

  final bool addAutomaticKeepAlives;
  final bool addRepaintBoundaries;
  final bool addSemanticIndexes;
  final int? semanticChildCount;

  // From hmhm
  final EdgeInsetsGeometry? padding;
  // From scroll view
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  // final ScrollPhysics? physics;
  ///
  /// For nested list [shrinkWrap] must be true
  ///
  final bool shrinkWrap;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;
  final HitTestBehavior hitTestBehavior;

  @override
  Widget build(BuildContext context) {
    return itemDetail.dadItem is DadRootList
        ? DadInherited(
            verticalPadding: verticalPaddingToScroll,
            expansionTileExpandTimer: TimerWrapper(),
            scrollRootListTimer: TimerWrapper(),
            rootListController: ScrollController(),
            rootListKey: _DadListKey('globalDadListKey'),
            child: DadTarget(
              itemDetail: itemDetail,
              onAcceptWithDetails: onAcceptWithDetails,
              onMove: onMove,
              onLeave: onLeave,
              dragTargetproperties: dragTargetproperties,
              builder: (context, candidateData, rejectedData) {
                if (_itemBuilder != null) {
                  return ListView.builder(
                    controller: DadInherited.of(context).rootListController,
                    key: DadInherited.of(context).rootListKey,
                    physics: null,
                    shrinkWrap: shrinkWrap,
                    // Other
                    itemExtent: itemExtent,
                    itemExtentBuilder: itemExtentBuilder,
                    cacheExtent: cacheExtent,
                    restorationId: restorationId,
                    reverse: reverse,
                    addRepaintBoundaries: addRepaintBoundaries,
                    hitTestBehavior: hitTestBehavior,
                    padding: padding,
                    primary: primary,
                    prototypeItem: prototypeItem,
                    addAutomaticKeepAlives: addAutomaticKeepAlives,
                    addSemanticIndexes: addSemanticIndexes,
                    scrollDirection: scrollDirection,
                    semanticChildCount: semanticChildCount,
                    dragStartBehavior: dragStartBehavior,
                    keyboardDismissBehavior: keyboardDismissBehavior,
                    clipBehavior: clipBehavior,
                    itemCount: _itemCount,
                    itemBuilder: _itemBuilder,
                  );
                }

                return ListView(
                  controller: DadInherited.of(context).rootListController,
                  key: DadInherited.of(context).rootListKey,
                  physics: null,
                  shrinkWrap: shrinkWrap,
                  // Other
                  itemExtent: itemExtent,
                  itemExtentBuilder: itemExtentBuilder,
                  cacheExtent: cacheExtent,
                  restorationId: restorationId,
                  reverse: reverse,
                  addRepaintBoundaries: addRepaintBoundaries,
                  hitTestBehavior: hitTestBehavior,
                  padding: padding,
                  primary: primary,
                  prototypeItem: prototypeItem,
                  addAutomaticKeepAlives: addAutomaticKeepAlives,
                  addSemanticIndexes: addSemanticIndexes,
                  scrollDirection: scrollDirection,
                  semanticChildCount: semanticChildCount,
                  dragStartBehavior: dragStartBehavior,
                  keyboardDismissBehavior: keyboardDismissBehavior,
                  clipBehavior: clipBehavior,
                  children: _children,
                );
              },
            ),
          )
        : Builder(builder: (context) {
            if (_itemBuilder != null) {
              return ListView.builder(
                controller: controller,
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: shrinkWrap,
                // Other
                itemExtent: itemExtent,
                itemExtentBuilder: itemExtentBuilder,
                cacheExtent: cacheExtent,
                restorationId: restorationId,
                reverse: reverse,
                addRepaintBoundaries: addRepaintBoundaries,
                hitTestBehavior: hitTestBehavior,
                padding: padding,
                primary: primary,
                prototypeItem: prototypeItem,
                addAutomaticKeepAlives: addAutomaticKeepAlives,
                addSemanticIndexes: addSemanticIndexes,
                scrollDirection: scrollDirection,
                semanticChildCount: semanticChildCount,
                dragStartBehavior: dragStartBehavior,
                keyboardDismissBehavior: keyboardDismissBehavior,
                clipBehavior: clipBehavior,
                // Builder
                itemCount: _itemCount,
                itemBuilder: _itemBuilder,
              );
            }

            return ListView(
              controller: controller,
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: shrinkWrap,
              // Other
              itemExtent: itemExtent,
              itemExtentBuilder: itemExtentBuilder,
              cacheExtent: cacheExtent,
              restorationId: restorationId,
              reverse: reverse,
              addRepaintBoundaries: addRepaintBoundaries,
              hitTestBehavior: hitTestBehavior,
              padding: padding,
              primary: primary,
              prototypeItem: prototypeItem,
              addAutomaticKeepAlives: addAutomaticKeepAlives,
              addSemanticIndexes: addSemanticIndexes,
              scrollDirection: scrollDirection,
              semanticChildCount: semanticChildCount,
              dragStartBehavior: dragStartBehavior,
              keyboardDismissBehavior: keyboardDismissBehavior,
              clipBehavior: clipBehavior,
              children: _children,
            );
          });
  }
}
