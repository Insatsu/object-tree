import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dad_list/dad.dart';

class TimerWrapper {
  Timer? timer;

  TimerWrapper({this.timer});
}

class DadDraggableFunctionWrapper {
  void Function(BuildContext context)? onDraggStarted;
  void Function(BuildContext context, DraggableDetails details)? onDraggEnd;
  void Function(BuildContext context, DragUpdateDetails? onDragUpdate)?
      onDraggUpdated;

  DadDraggableFunctionWrapper();
}

///
/// Class with additional [ExpansionTile] properties.
///
/// Used for set properties of [ExpansionTile] of [DadItemTilePast] (if [itemDetail.item] is [IDadList])
///
/// Main propertires are located in [DadItemTilePast]
///
class AdditionalExpansionTileProperties {
  const AdditionalExpansionTileProperties({
    this.showTrailingIcon = true,
    this.maintainState = false,
    this.controlAffinity,
    this.controller,
    this.dense,
    this.visualDensity,
    this.enableFeedback = true,
    this.enabled = true,
    this.expansionAnimationStyle,
  });

  final bool showTrailingIcon;

  final bool maintainState;

  final ListTileControlAffinity? controlAffinity;

  final ExpansionTileController? controller;

  final bool? dense;

  final VisualDensity? visualDensity;

  final bool? enableFeedback;

  final bool enabled;

  final AnimationStyle? expansionAnimationStyle;
}

///
/// Class with all [ListTile] properties.
///
/// Used for set properties of [ListTile] of [DadItemTilePast] (if [itemDetail.item] is [DadItem])
///
/// By default, properties taken from the fields of [DadItemTilePast] class (standard properties) are applied to [ListTile],
/// but if the [listTileProperties] field is defined, its properties are checked:
/// - If its field is empty, then the standard property is applied,
/// - else the field from [listTileProperties] is applied.
///
class ListTileProperties {
  const ListTileProperties({
    this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.isThreeLine = false,
    this.dense,
    this.visualDensity,
    this.shape,
    this.style,
    this.selectedColor,
    this.iconColor,
    this.textColor,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.leadingAndTrailingTextStyle,
    this.contentPadding,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.onFocusChange,
    this.mouseCursor,
    this.selected = false,
    this.focusColor,
    this.hoverColor,
    this.splashColor,
    this.focusNode,
    this.autofocus = false,
    this.tileColor,
    this.selectedTileColor,
    this.enableFeedback,
    this.horizontalTitleGap,
    this.minVerticalPadding,
    this.minLeadingWidth,
    this.minTileHeight,
    this.titleAlignment,
    this.internalAddSemanticForOnTap = true,
  }) : assert(!isThreeLine || subtitle != null);

  final DadWidgetBuilder? leading;

  final DadWidgetBuilder title;

  final DadWidgetBuilder? subtitle;

  final DadWidgetBuilder? trailing;

  final bool isThreeLine;

  final bool? dense;

  final VisualDensity? visualDensity;

  final ShapeBorder? shape;

  final Color? selectedColor;

  final Color? iconColor;

  final Color? textColor;

  final TextStyle? titleTextStyle;

  final TextStyle? subtitleTextStyle;

  final TextStyle? leadingAndTrailingTextStyle;

  final ListTileStyle? style;

  final EdgeInsetsGeometry? contentPadding;

  final bool enabled;

  final GestureTapCallback? onTap;

  final GestureLongPressCallback? onLongPress;

  final ValueChanged<bool>? onFocusChange;

  final MouseCursor? mouseCursor;

  final bool selected;

  final Color? focusColor;

  final Color? hoverColor;

  final Color? splashColor;

  final FocusNode? focusNode;

  final bool autofocus;

  final Color? tileColor;

  final Color? selectedTileColor;

  final bool? enableFeedback;

  final double? horizontalTitleGap;

  final double? minVerticalPadding;

  final double? minLeadingWidth;

  final double? minTileHeight;

  final ListTileTitleAlignment? titleAlignment;

  final bool internalAddSemanticForOnTap;
}

///
/// Class with additional [DragTarget] properties.
///
/// Used to set properties of [DragTarget] in [DadTarget]
///
class DragTargetProperties {
  const DragTargetProperties(
      {this.onWillAcceptWithDetails,
      this.onLeave,
      this.onMove,
      this.hitTestBehavior = HitTestBehavior.translucent});

  final DragTargetWillAcceptWithDetails<DadItemDetail>? onWillAcceptWithDetails;
  final DragTargetLeave<DadItemDetail>? onLeave;
  final DragTargetMove<DadItemDetail>? onMove;
  final HitTestBehavior hitTestBehavior;
}

///
/// Class with additional [LongPressDraggable] properties.
///
/// Used to set properties of [LongPressDraggable] in [DadItemDraggableTile]
///
class LongPressDraggableProperties {
  const LongPressDraggableProperties({
    this.axis,
    this.feedbackOffset = Offset.zero,
    this.dragAnchorStrategy = pointerDragAnchorStrategy,
    this.maxSimultaneousDrags = 1,
    this.hapticFeedbackOnStart = true,
    this.ignoringFeedbackSemantics = true,
    this.ignoringFeedbackPointer = true,
    this.rootOverlay = false,
  });

  final Axis? axis;

  final Offset feedbackOffset;

  final DragAnchorStrategy dragAnchorStrategy;

  final bool ignoringFeedbackSemantics;

  final bool ignoringFeedbackPointer;

  final int? maxSimultaneousDrags;



  final bool rootOverlay;

  final bool hapticFeedbackOnStart;
}
