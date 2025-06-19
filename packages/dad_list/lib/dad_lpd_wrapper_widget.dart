import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';

///
/// Just like standart [LongPressDraggable] but with [itemDetail] instead
/// of [data],
///
/// [dragAnchorStrategy] = [pointerDragAnchorStrategy] by default,
/// [childWhenDragging] is [child] with 0.5 opacity
///
class DadItemDraggableTile extends StatefulWidget {
  const DadItemDraggableTile({
    required this.itemDetail,
    required this.child,
    required this.feedback,
    this.delay = const Duration(milliseconds: 500),
    this.properties,
    super.key,
    this.childWhenDragging,
    this.onDragStarted,
    this.onDragUpdate,
    this.onDraggableCanceled,
    this.onDragCompleted,
    this.onDragEnd,
  })
  // : defaultFunctions = DadDraggableFunctionWrapper()
  ;

  final DadItemDetail itemDetail;

  final Widget child;

  final Widget feedback;
  final Duration delay;

  final Widget? childWhenDragging;

  final VoidCallback? onDragStarted;

  final DragUpdateCallback? onDragUpdate;

  final DraggableCanceledCallback? onDraggableCanceled;

  final VoidCallback? onDragCompleted;

  final DragEndCallback? onDragEnd;

  final LongPressDraggableProperties? properties;

  // final DadDraggableFunctionWrapper defaultFunctions;

  @override
  State<DadItemDraggableTile> createState() => _DadItemDraggableTileState();
}

class _DadItemDraggableTileState extends State<DadItemDraggableTile>
    with AutomaticKeepAliveClientMixin {
  ///
  /// True if this widget is dragging
  /// Must be set in [onDragStarted] to true and [onDragEnded] to false
  ///
  bool isDragged = false;

  @override
  bool get wantKeepAlive => isDragged;


  @override
  Widget build(BuildContext context) {
    /// Call super.build for KeepAlive widget
    super.build(context);

    return LongPressDraggable<DadItemDetail>(
      key: widget.key,
      data: widget.itemDetail,
      feedback: widget.feedback,
      childWhenDragging: widget.childWhenDragging
          // If none just show [child] with 0.5 opacity
          ??
          Opacity(
              opacity: 0.5,
              child: DadTitleWidget(title: widget.itemDetail.dadItem.title)),
      dragAnchorStrategy:
          widget.properties?.dragAnchorStrategy ?? pointerDragAnchorStrategy,
      axis: widget.properties?.axis,
      rootOverlay: widget.properties?.rootOverlay ?? false,
      hapticFeedbackOnStart: widget.properties?.hapticFeedbackOnStart ?? true,
      delay: widget.delay,
      onDragCompleted: widget.onDragCompleted,

      ///
      /// Default realization to scroll [DadRootList] by dragging item on edge of it
      ///
      onDragEnd: (DraggableDetails details) {
        onDraggEnd(context, details);
        if (widget.onDragEnd != null) {
          widget.onDragEnd!(details);
        }
      },
      onDragStarted: () {
        onDraggStarted(context);
        if (widget.onDragStarted != null) {
          widget.onDragStarted!();
        }
      },
      onDragUpdate: (DragUpdateDetails onDragUpdate) {
        onDraggUpdate(context, onDragUpdate);
        if (widget.onDragUpdate != null) {
          widget.onDragUpdate!(onDragUpdate);
        }
      },

      ///
      onDraggableCanceled: widget.onDraggableCanceled,
      maxSimultaneousDrags: widget.properties?.maxSimultaneousDrags,
      ignoringFeedbackPointer:
          widget.properties?.ignoringFeedbackPointer ?? true,
      ignoringFeedbackSemantics:
          widget.properties?.ignoringFeedbackSemantics ?? true,
      feedbackOffset: widget.properties?.feedbackOffset ?? Offset.zero,
      child: widget.child,
    );
  }

  int _whereToScroll(double? dragDy, double dyBegin, double height) {
    if (dragDy == null) {
      return 0;
    }
    double step = 50;
    if (dyBegin + step > dragDy) {
      return -1;
    }

    if (dyBegin + height - step < dragDy) {
      return 1;
    }

    return 0;
  }

  void onDraggStarted(BuildContext context) {
    isDragged = true;
    updateKeepAlive();
  }

  void onDraggEnd(BuildContext context, DraggableDetails details) {
    DadInherited.of(context).stopAnimateRootList();
    isDragged = false;
    updateKeepAlive();
  }

  void onDraggUpdate(BuildContext context, DragUpdateDetails? onDragUpdate) {
    // * [onDragUpdate] stop working if widget out of screen because [DragList] dispose it
    // *

    /// Define where should to scroll
    /// 0 - no need
    /// 1 - forward
    /// -1 - reverse
    int whereToScroll = _whereToScroll(
        onDragUpdate?.globalPosition.dy,
        (DadInherited.of(context).rootListKey.currentContext?.findRenderObject()
                as RenderBox)
            .localToGlobal(Offset.zero)
            .dy,
        DadInherited.of(context).rootListController.position.viewportDimension);

    /// if no need to scroll just exist from here
    ///
    if (whereToScroll == 0) {
      DadInherited.of(context).stopAnimateRootList();
      return;
    }

    /// If it needs to scroll then defines new value of scroll in [offsetScroll]
    /// and manage edges values like 0 and [maxScrollExtent].
    ///
    DadInherited.of(context)
        .startAnimateRootList(Duration(milliseconds: 200), whereToScroll);
  }
}
