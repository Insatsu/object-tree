import 'package:dad_list/dad.dart';
import 'package:flutter/material.dart';

class DadItemTile extends StatelessWidget {
  const DadItemTile(
      {super.key,
      required this.itemDetail,
      required this.feedback,
      this.leading,
      this.title,
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
      this.longPressDelay = const Duration(milliseconds: 500),
      this.properties,
      this.childWhenDragging,
      this.onDragStarted,
      this.onDragUpdate,
      this.onDraggableCanceled,
      this.onDragCompleted,
      this.onDragEnd})
      : assert(!isThreeLine || subtitle != null)
      // , assert(
            // (itemDetail.dadItem is DadItem), 'itemDetail item must be DadItem')
            ;

  final DadItemDetail itemDetail;

  /// List tile properties
  final Widget? leading;
  final Widget? title;
  final Widget? subtitle;
  final Widget? trailing;
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

  ///
  final Widget feedback;
  final Duration longPressDelay;
  final Widget? childWhenDragging;
  final VoidCallback? onDragStarted;
  final DragUpdateCallback? onDragUpdate;
  final DraggableCanceledCallback? onDraggableCanceled;
  final VoidCallback? onDragCompleted;
  final DragEndCallback? onDragEnd;

  final LongPressDraggableProperties? properties;

  @override
  Widget build(BuildContext context) {
    return DadItemDraggableTile(
        itemDetail: itemDetail,
        feedback: feedback,
        delay: longPressDelay,
        childWhenDragging: childWhenDragging,
        onDragStarted: onDragStarted,
        onDragUpdate: onDragUpdate,
        onDragCompleted: onDragCompleted,
        onDraggableCanceled: onDraggableCanceled,
        onDragEnd: onDragEnd,
        properties: properties,
        child: ListTile(
          title: title,
          tileColor: tileColor,
          titleAlignment: titleAlignment,
          titleTextStyle: titleTextStyle,
          subtitleTextStyle: subtitleTextStyle,
          selected: selected,
          selectedColor: selectedColor,
          selectedTileColor: selectedTileColor,
          style: style,
          splashColor: splashColor,
          internalAddSemanticForOnTap: internalAddSemanticForOnTap,
          minLeadingWidth: minLeadingWidth,
          isThreeLine: isThreeLine,
          onTap: onTap,
          horizontalTitleGap: horizontalTitleGap,
          leadingAndTrailingTextStyle: leadingAndTrailingTextStyle,
          onLongPress: onLongPress,
          contentPadding: contentPadding,
          focusColor: focusColor,
          hoverColor: hoverColor,
          mouseCursor: mouseCursor,
          onFocusChange: onFocusChange,
          autofocus: autofocus,
          focusNode: focusNode,
          minVerticalPadding: minVerticalPadding,
          leading: leading,
          subtitle: subtitle,
          trailing: trailing,
          textColor: textColor,
          iconColor: iconColor,
          shape: shape,
          dense: dense,
          visualDensity: visualDensity,
          minTileHeight: minTileHeight,
          enableFeedback: enableFeedback,
          enabled: enabled,
        ));
  }
}

/// DadItemTile widget with custom child
class DadItemTileCustom extends StatelessWidget {
  const DadItemTileCustom(
      {super.key,
      required this.itemDetail,
      required this.feedback,
      required this.child,
      this.delay = const Duration(milliseconds: 500),
      this.draggableProperties});
  final DadItemDetail itemDetail;

  final Widget feedback;
  final Duration delay;
  final Widget child;

  final LongPressDraggableProperties? draggableProperties;

  @override
  Widget build(BuildContext context) {
    return DadItemDraggableTile(
      itemDetail: itemDetail,
      feedback: feedback,
      delay: delay,
      child: child,
    );
  }
}
