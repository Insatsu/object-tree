import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';

// ** [feedback], [childWhenDragging] widgets cannot be the same widget that child with controller
// ** because with drag them take this child together its controller and it will create exception
// ** (one controller in many widgets)

/// Single list item widget.
///
///
class DadItemExpansionTile extends StatefulWidget {
  const DadItemExpansionTile(
      {required this.itemDetail,
      this.leading,
      required this.title,
      required this.feedback,
      this.subtitle,
      ValueChanged<bool>? onExpansionChanged,
      this.trailing,
      this.showTrailingIcon = true,
      bool initiallyExpanded = false,
      this.useItemDetailExpandedValue = true,
      this.maintainState = false,
      this.controlAffinity,
      this.controller,
      this.dense,
      this.visualDensity,
      this.enableFeedback = true,
      this.enabled = true,
      this.expansionAnimationStyle,
      this.tilePadding,
      this.expandedCrossAxisAlignment,
      this.expandedAlignment,
      this.backgroundColor,
      this.collapsedBackgroundColor,
      this.textColor,
      this.collapsedTextColor,
      this.iconColor,
      this.collapsedIconColor,
      this.shape,
      this.collapsedShape,
      this.clipBehavior,
      this.minTileHeight,
      this.children = const <Widget>[],
      super.key,
      this.childrenPadding,
      // draggable
      this.longPressDelay = const Duration(milliseconds: 500),
      this.properties,
      this.childWhenDragging,
      this.onDragStarted,
      this.onDragUpdate,
      this.onDraggableCanceled,
      this.onDragCompleted,
      this.onDragEnd,
      this.onAcceptWithDetails,
      this.onMove,
      this.onLeave,
      this.dragTargetproperties})
      :
        // assert((children.isEmpty || itemDetail.dadItem is! DadItem),
        //       '[children] must be null if [itemDetail.item] is DadItem'),
        _initiallyExpanded = initiallyExpanded,
        _onExpansionChanged = onExpansionChanged;

  /// Define what field should be used in [ExpansionTile] for expand and collapse
  ///
  final bool useItemDetailExpandedValue;
  final DadItemDetail itemDetail;

  // * From drop target
  final DragTargetAcceptWithDetails<DadItemDetail>? onAcceptWithDetails;
  final DragTargetMove<DadItemDetail>? onMove;
  final DragTargetLeave<DadItemDetail>? onLeave;

  /// Additional properties
  final DragTargetProperties? dragTargetproperties;

  // * From draggable
  final Widget feedback;
  final Duration longPressDelay;
  final Widget? childWhenDragging;

  final VoidCallback? onDragStarted;

  final DragUpdateCallback? onDragUpdate;

  final DraggableCanceledCallback? onDraggableCanceled;

  final VoidCallback? onDragCompleted;

  final DragEndCallback? onDragEnd;

  final LongPressDraggableProperties? properties;

  // * From expansion tile
  final List<Widget> children;

  final Color? backgroundColor;
  final Color? collapsedBackgroundColor;

  final bool maintainState;

  final ListTileControlAffinity? controlAffinity;

  final ExpansionTileController? controller;

  final bool? dense;

  final VisualDensity? visualDensity;

  final bool? enableFeedback;

  final bool enabled;

  final AnimationStyle? expansionAnimationStyle;
  final Widget? leading;

  final Widget title;

  final Widget? subtitle;

  final ValueChanged<bool>? _onExpansionChanged;

  final Widget? trailing;

  final bool showTrailingIcon;

  final bool _initiallyExpanded;

  final EdgeInsetsGeometry? tilePadding;

  final EdgeInsetsGeometry? childrenPadding;

  final Alignment? expandedAlignment;

  final CrossAxisAlignment? expandedCrossAxisAlignment;

  final Color? iconColor;

  final Color? collapsedIconColor;

  final Color? textColor;

  final Color? collapsedTextColor;

  final ShapeBorder? shape;

  final ShapeBorder? collapsedShape;

  final Clip? clipBehavior;

  final double? minTileHeight;

  /// Work in chain with [onExpansionTileUncoverd] on [ExpansionTile] in [DadTarget]
  ///
  /// If there is a draggable item hover at [DadTarget] then timer starts from [TimerWrapper] in [DadInherited] widget
  /// for 1 seconds. If user continue hold item for it time then [ExpansionTile] will open
  /// else timer will be canceled and removed from [TimerWrapper]
  ///
  static void onExpansionTileCoverd(
      TimerWrapper timer, void Function() callback) {
    if (timer.timer != null && !timer.timer!.isActive) {
      timer.timer!.cancel();

      return;
    }

    timer.timer ??= Timer(Duration(seconds: 1), callback);
  }

  /// Work in chain with [onExpansionTileCoverd] on [ExpansionTile] in [DadTarget]
  ///
  /// When an item that covered [ExpansionTile] go out this method should be called
  /// for stop timer (that expand tile after some time)
  ///
  static void onExpansionTileUncoverd(TimerWrapper timer) {
    timer.timer?.cancel();
    timer.timer = null;
  }

  @override
  State<DadItemExpansionTile> createState() => _DadItemExpansionTileState();
}

class _DadItemExpansionTileState extends State<DadItemExpansionTile> {
  late ExpansionTileController controller;

  ///
  bool get initiallyExpanded {
    return widget.useItemDetailExpandedValue
        ? (widget.itemDetail.dadItem as DadExpansionList).isExpanded
        : widget._initiallyExpanded;
  }

  /// If [useItemDetailExpandedValue] is true then on expansion changed
  /// changes [isExpanded] field value in [DadExpansionTile]
  ///
  ValueChanged<bool>? get onExpansionChanged {
    return widget.useItemDetailExpandedValue
        ? (value) =>
            (widget.itemDetail.dadItem as DadExpansionList).isExpanded = value
        : widget._onExpansionChanged;
  }

  @override
  void initState() {
    super.initState();
    controller = widget.controller ?? ExpansionTileController();
  }

  @override
  Widget build(BuildContext context) {
    void openExpansionTile() {
      /// If ExpansionTile fully isn't visible than skip
      if (mounted == false) {
        return;
      }
      controller.expand();
    }

    return DadItemDraggableTile(
        itemDetail: widget.itemDetail,
        feedback: widget.feedback,
        delay: widget.longPressDelay,
        childWhenDragging: widget.childWhenDragging,
        onDragStarted: widget.onDragStarted ??
            () {
              controller.collapse();
            },
        onDragUpdate: widget.onDragUpdate,
        onDragCompleted: widget.onDragCompleted,
        onDraggableCanceled: widget.onDraggableCanceled,
        onDragEnd: widget.onDragEnd,
        properties: widget.properties,
        child: DadTarget(
            itemDetail: widget.itemDetail,
            onMove: (details) {
              onMoveLocal(details, context, openExpansionTile);
              if (widget.onMove != null) {
                widget.onMove!(details);
              }
            },
            onLeave: (data) {
              onLeaveLocal(data, context);
              if (widget.onLeave != null) {
                widget.onLeave!(data);
              }
            },
            onAcceptWithDetails: (details) {
              onAcceptWithDetailsLocal(details, context);
              if (widget.onAcceptWithDetails != null) {
                widget.onAcceptWithDetails!(details);
              } else {
                ///
                DadTarget.dadOnAcceptWithDetails(
                  details,
                  widget.itemDetail,
                );
              }
            },
            dragTargetproperties: widget.dragTargetproperties,
            builder: (context, candidateData, rejectedData) => ExpansionTile(
                  controller: controller,
                  backgroundColor: widget.backgroundColor,
                  collapsedBackgroundColor: widget.collapsedBackgroundColor,
                  title: widget.title,
                  initiallyExpanded: initiallyExpanded,
                  onExpansionChanged: onExpansionChanged,
                  leading: widget.leading,
                  subtitle: widget.subtitle,
                  trailing: widget.trailing,
                  showTrailingIcon: widget.showTrailingIcon,
                  tilePadding: widget.tilePadding,
                  expandedCrossAxisAlignment: widget.expandedCrossAxisAlignment,
                  expandedAlignment: widget.expandedAlignment,
                  childrenPadding: widget.childrenPadding,
                  textColor: widget.textColor,
                  collapsedTextColor: widget.collapsedTextColor,
                  iconColor: widget.iconColor,
                  collapsedIconColor: widget.collapsedIconColor,
                  shape: widget.shape,
                  collapsedShape: widget.collapsedShape,
                  clipBehavior: widget.clipBehavior,
                  minTileHeight: widget.minTileHeight,
                  maintainState: widget.maintainState,
                  controlAffinity: widget.controlAffinity,
                  dense: widget.dense,
                  visualDensity: widget.visualDensity,
                  enableFeedback: widget.enableFeedback,
                  enabled: widget.enabled,
                  expansionAnimationStyle: widget.expansionAnimationStyle,
                  children: widget.children,
                )));
  }

  void onAcceptWithDetailsLocal(
      DragTargetDetails<DadItemDetail<Object>> details, BuildContext context) {
    if (widget.itemDetail.dadItem == details.data.dadItem) {
      return;
    }

    ///
    DadItemExpansionTile.onExpansionTileUncoverd(
        DadInherited.of(context).expansionTileExpandTimer);
  }

  void onLeaveLocal(DadItemDetail<Object>? data, BuildContext context) {
    if (widget.itemDetail.dadItem == data?.dadItem) {
      return;
    }
    DadItemExpansionTile.onExpansionTileUncoverd(
        DadInherited.of(context).expansionTileExpandTimer);
  }

  void onMoveLocal(DragTargetDetails<DadItemDetail<Object>> details,
      BuildContext context, void Function() openExpansionTile) {
    // * If target is item
    if (widget.itemDetail.dadItem == details.data.dadItem) {
      return;
    }

    DadItemExpansionTile.onExpansionTileCoverd(
        DadInherited.of(context).expansionTileExpandTimer, openExpansionTile);
  }
}
