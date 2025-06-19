import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';

class DadTarget extends StatefulWidget {
  const DadTarget(
      {super.key,
      required this.itemDetail,
      this.onAcceptWithDetails,
      this.onMove,
      this.onLeave,
      this.dragTargetproperties,
      required this.builder});
  final DadItemDetail itemDetail;

  ///
  /// If [onAcceptWithDetails] is non-null it will call in [DragTarget] [onAcceptWithDetails] property
  /// after what [setState] will not call
  ///
  final DragTargetAcceptWithDetails<DadItemDetail>? onAcceptWithDetails;
  final DragTargetMove<DadItemDetail>? onMove;
  final DragTargetLeave<DadItemDetail>? onLeave;
  final DragTargetBuilder<DadItemDetail> builder;

  /// Additional properties
  final DragTargetProperties? dragTargetproperties;

  static void moveDadItem(
      {required IDadItem item,
      required IDadList parrent,
      required IDadList target,
      required DadWidgetSetStateWrapper setStateParrent,
      required DadWidgetSetStateWrapper setStateTarget}) {
    parrent.children.remove(item);
    target.children.add(item);
    setStateParrent();

    ///
    /// if target is child of item parrent there no need to update target widget
    ///
    if (!parrent.children.contains(target)) {
      setStateTarget();
    }
  }

  static void dadOnAcceptWithDetails(
    DragTargetDetails<DadItemDetail> details,
    DadItemDetail taregtListDetail,
  ) {
    // * If target is item's parrent -> skip
    if (taregtListDetail.dadItem == details.data.parrent) {
      return;
    }
    // * If target is item
    if (taregtListDetail.dadItem == details.data.dadItem) {
      return;
    }

    moveDadItem(
        item: details.data.dadItem,
        parrent: details.data.parrent!,
        target: taregtListDetail.dadItem as IDadList,
        setStateParrent: details.data.setStateParrent,
        setStateTarget: taregtListDetail.setStateParrent);
  }

  @override
  State<DadTarget> createState() => _DadTargetState();
}

class _DadTargetState extends State<DadTarget> {
  @override
  Widget build(BuildContext context) {
    return DragTarget<DadItemDetail>(
        onAcceptWithDetails: (details) {
          /// User [onAcceptWithDetails] function if it non-null
          if (widget.onAcceptWithDetails != null) {
            widget.onAcceptWithDetails!(details);
            return;
          }

          /// Else this logic:
          DadTarget.dadOnAcceptWithDetails(
            details,
            widget.itemDetail,
          );
        },
        onWillAcceptWithDetails:
            widget.dragTargetproperties?.onWillAcceptWithDetails,
        hitTestBehavior: widget.dragTargetproperties != null
            ? widget.dragTargetproperties!.hitTestBehavior
            : HitTestBehavior.translucent,
        onMove: widget.onMove,
        onLeave: widget.onLeave,
        builder: widget.builder);
  }
}
