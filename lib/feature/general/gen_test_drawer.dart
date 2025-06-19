import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

const double _kWidth = 304.0;
const double _kEdgeDragWidth = 20.0;
const double _kMinFlingVelocity = 365.0;
const Duration _kBaseSettleDuration = Duration(milliseconds: 246);

class GenTestDrawer extends StatefulWidget {
  /// Creates a controller for a [Drawer].
  ///
  /// Rarely used directly.
  ///
  /// The [drawer] argument is typically a [Drawer].
  const GenTestDrawer({
    GlobalKey? key,
    required this.drawer,
    this.alignment = DrawerAlignment.start,
    this.isDrawerOpen = false,
    this.drawerCallback,
    this.dragStartBehavior = DragStartBehavior.start,
    this.scrimColor,
    this.edgeDragWidth,
    this.enableOpenDragGesture = true,
    required this.content,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// Typically a [Drawer].
  final Widget drawer;
  final Widget content;

  /// The alignment of the [Drawer].
  ///
  /// This controls the direction in which the user should swipe to open and
  /// close the drawer.
  final DrawerAlignment alignment;

  /// Optional callback that is called when a [Drawer] is opened or closed.
  final DrawerCallback? drawerCallback;

  /// {@template flutter.material.DrawerControllerPlus.dragStartBehavior}
  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag behavior used for opening
  /// and closing a drawer will begin at the position where the drag gesture won
  /// the arena. If set to [DragStartBehavior.down] it will begin at the position
  /// where a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for
  ///    the different behaviors.
  ///
  /// {@endtemplate}
  final DragStartBehavior dragStartBehavior;

  /// The color to use for the scrim that obscures the underlying content while
  /// a drawer is open.
  ///
  /// If this is null, then [DrawerThemeData.scrimColor] is used. If that
  /// is also null, then it defaults to [Colors.black54].
  final Color? scrimColor;

  /// Determines if the [Drawer] can be opened with a drag gesture.
  ///
  /// By default, the drag gesture is enabled.
  final bool enableOpenDragGesture;

  /// The width of the area within which a horizontal swipe will open the
  /// drawer.
  ///
  /// By default, the value used is 20.0 added to the padding edge of
  /// `MediaQuery.paddingOf(context)` that corresponds to [alignment].
  /// This ensures that the drag area for notched devices is not obscured. For
  /// example, if [alignment] is set to [DrawerAlignment.start] and
  /// `TextDirection.of(context)` is set to [TextDirection.ltr],
  /// 20.0 will be added to `MediaQuery.paddingOf(context).left`.
  final double? edgeDragWidth;

  /// Whether or not the drawer is opened or closed.
  ///
  /// This parameter is primarily used by the state restoration framework
  /// to restore the drawer's animation controller to the open or closed state
  /// depending on what was last saved to the target platform before the
  /// application was killed.
  final bool isDrawerOpen;

  static GenTestDrawerState? maybeOf(BuildContext context) {
    return context.findAncestorStateOfType<GenTestDrawerState>();
  }

  @override
  GenTestDrawerState createState() => GenTestDrawerState();
}

/// State for a [GenTestDrawer].
///
/// Typically used by a [Scaffold] to [open] and [close] the drawer.
class GenTestDrawerState extends State<GenTestDrawer>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      value: widget.isDrawerOpen ? 1.0 : 0.0,
      duration: _kBaseSettleDuration,
      vsync: this,
    );
    _controller.addListener(_animationChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scrimColorTween = _buildScrimColorTween();
  }

  @override
  void didUpdateWidget(GenTestDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.scrimColor != oldWidget.scrimColor) {
      _scrimColorTween = _buildScrimColorTween();
    }

    if (_controller.status.isAnimating) {
      return; // Don't snap the drawer open or shut while the user is dragging.
    }
    if (widget.isDrawerOpen != oldWidget.isDrawerOpen) {
      _controller.value = widget.isDrawerOpen ? 1.0 : 0.0;
    }
  }

  void _animationChanged() {
    setState(() {
      // The animation controller's state is our build state, and it changed already.
    });
  }

  final FocusScopeNode _focusScopeNode = FocusScopeNode();

  late AnimationController _controller;

  void _handleDragDown(DragDownDetails details) {
    _controller.stop();
  }

  void _handleDragCancel() {
    if (_controller.isDismissed || _controller.isAnimating) {
      return;
    }
    if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  final GlobalKey _drawerKey = GlobalKey();

  double get _width {
    final RenderBox? box =
        _drawerKey.currentContext?.findRenderObject() as RenderBox?;
    // return _kWidth if drawer not being shown currently
    return box?.size.width ?? _kWidth;
  }

  bool _previouslyOpened = false;

  int get _directionFactor {
    return switch ((Directionality.of(context), widget.alignment)) {
      (TextDirection.rtl, DrawerAlignment.start) => -1,
      (TextDirection.rtl, DrawerAlignment.end) => 1,
      (TextDirection.ltr, DrawerAlignment.start) => 1,
      (TextDirection.ltr, DrawerAlignment.end) => -1,
    };
  }

  void _move(DragUpdateDetails details) {
    _controller.value += details.primaryDelta! / _width * _directionFactor;

    final bool opened = _controller.value > 0.5;
    if (opened != _previouslyOpened && widget.drawerCallback != null) {
      widget.drawerCallback!(opened);
    }
    _previouslyOpened = opened;
  }

  void _settle(DragEndDetails details) {
    if (_controller.isDismissed) {
      return;
    }
    final double xVelocity = details.velocity.pixelsPerSecond.dx;
    if (xVelocity.abs() >= _kMinFlingVelocity) {
      final double visualVelocity = xVelocity / _width * _directionFactor;

      _controller.fling(velocity: visualVelocity);
      widget.drawerCallback?.call(visualVelocity > 0.0);
    } else if (_controller.value < 0.5) {
      close();
    } else {
      open();
    }
  }

  /// Starts an animation to open the drawer.
  ///
  /// Typically called by [ScaffoldState.openDrawer].
  void open() {
    _controller.fling();
    widget.drawerCallback?.call(true);
  }

  /// Starts an animation to close the drawer.
  void close() {
    _controller.fling(velocity: -1.0);
    widget.drawerCallback?.call(false);
  }

  late ColorTween _scrimColorTween;
  final GlobalKey _gestureDetectorKey = GlobalKey();

  ColorTween _buildScrimColorTween() {
    return ColorTween(
      begin: Colors.transparent,
      end: widget.scrimColor ??
          DrawerTheme.of(context).scrimColor ??
          Colors.black54,
    );
  }

  AlignmentDirectional get _drawerOuterAlignment {
    return switch (widget.alignment) {
      DrawerAlignment.start => AlignmentDirectional.centerStart,
      DrawerAlignment.end => AlignmentDirectional.centerEnd,
    };
  }

  AlignmentDirectional get _drawerInnerAlignment {
    return switch (widget.alignment) {
      DrawerAlignment.start => AlignmentDirectional.centerEnd,
      DrawerAlignment.end => AlignmentDirectional.centerStart,
    };
  }

  Widget _buildDrawer(BuildContext context) {
    // final double dragAreaWidth = widget.edgeDragWidth ??
    //     _kEdgeDragWidth +
    //         switch ((widget.alignment, Directionality.of(context))) {
    //           (DrawerAlignment.start, TextDirection.ltr) =>
    //             MediaQuery.paddingOf(context).left,
    //           (DrawerAlignment.start, TextDirection.rtl) =>
    //             MediaQuery.paddingOf(context).right,
    //           (DrawerAlignment.end, TextDirection.rtl) =>
    //             MediaQuery.paddingOf(context).left,
    //           (DrawerAlignment.end, TextDirection.ltr) =>
    //             MediaQuery.paddingOf(context).right,
    //         };

    if (_controller.isDismissed) {
      if (widget.enableOpenDragGesture) {
        return Align(
          alignment: _drawerOuterAlignment,
          child: GestureDetector(
            key: _gestureDetectorKey,
            onHorizontalDragUpdate: _move,
            onHorizontalDragEnd: _settle,
            behavior: HitTestBehavior.translucent,
            excludeFromSemantics: true,
            dragStartBehavior: widget.dragStartBehavior,
            // child: LimitedBox(maxHeight: 0.0, child: SizedBox(width: dragAreaWidth, height: double.infinity)),
            child: widget.content,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      final bool platformHasBackButton;
      switch (Theme.of(context).platform) {
        case TargetPlatform.android:
          platformHasBackButton = true;
        case TargetPlatform.iOS:
        case TargetPlatform.macOS:
        case TargetPlatform.fuchsia:
        case TargetPlatform.linux:
        case TargetPlatform.windows:
          platformHasBackButton = false;
      }

      Widget drawerScrim = const LimitedBox(
          maxWidth: 0.0, maxHeight: 0.0, child: SizedBox.expand());
      if (_scrimColorTween.evaluate(_controller) case final Color color) {
        drawerScrim = ColoredBox(color: color, child: drawerScrim);
      }

      final Widget child = _DrawerControllerScope(
        controller: widget,
        child: RepaintBoundary(
          child: Stack(
            children: <Widget>[
              BlockSemantics(
                child: ExcludeSemantics(
                  // On Android, the back button is used to dismiss a modal.
                  excluding: platformHasBackButton,
                  child: GestureDetector(
                    onTap: close,
                    child: Semantics(
                      label: MaterialLocalizations.of(context)
                          .modalBarrierDismissLabel,
                      child: drawerScrim,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: _drawerOuterAlignment,
                child: Align(
                  alignment: _drawerInnerAlignment,
                  widthFactor: _controller.value,
                  child: RepaintBoundary(
                    child: FocusScope(
                      key: _drawerKey,
                      node: _focusScopeNode,
                      child: widget.drawer,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      return GestureDetector(
        key: _gestureDetectorKey,
        onHorizontalDragDown: _handleDragDown,
        onHorizontalDragUpdate: _move,
        onHorizontalDragEnd: _settle,
        onHorizontalDragCancel: _handleDragCancel,
        excludeFromSemantics: true,
        dragStartBehavior: widget.dragStartBehavior,
        child: Stack(
          children: [
            widget.content,
            child,
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return ListTileTheme.merge(
      style: ListTileStyle.drawer,
      child: _buildDrawer(context),
    );
  }
}

class _DrawerControllerScope extends InheritedWidget {
  const _DrawerControllerScope({
    required this.controller,
    required super.child,
  });

  final GenTestDrawer controller;

  @override
  bool updateShouldNotify(_DrawerControllerScope old) {
    return controller != old.controller;
  }
}
