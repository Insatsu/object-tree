import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/core/routers.dart';
import 'package:object_tree/data/data.dart';

class NtNodeInv extends StatefulWidget {
  const NtNodeInv({super.key, required this.node, required this.titleOpacity});
  final TreeNode node;
  final ValueNotifier<double> titleOpacity;

  @override
  State<NtNodeInv> createState() => _NtNodeInvState();
}

class _NtNodeInvState extends State<NtNodeInv> {

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.node.x,
      top: widget.node.y,
      child: RepaintBoundary(
        child: _NtNodeInvCircle(
            node: widget.node, update: () => setState(() {})),
      ),
    );
  }
}

class _NtNodeInvCircle extends StatelessWidget {
  const _NtNodeInvCircle({required this.node, required this.update});

  final TreeNode node;

  final VoidCallback update;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        node.x = max(0, node.x + details.delta.dx);
        node.y = max(0, node.y + details.delta.dy);
        update();
      },
      onTap: () {
        StatefulNavigationShell.of(context).goBranch(0);
        context.goNamed(NOTE_ROUTE,
            pathParameters: {NOTE_RELATIVE_PATH_ROUTE: node.note.relativePath});
      },
      child: Container(
        width: node.tapSize,
        height: node.tapSize,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
        ),
        alignment: AlignmentDirectional.center,
      ),
    );
  }
}


class NtNode extends StatefulWidget {
  const NtNode({super.key, required this.node, required this.titleOpacity});
  final TreeNode node;
  final ValueNotifier<double> titleOpacity;

  @override
  State<NtNode> createState() => _NtNodeState();
}

class _NtNodeState extends State<NtNode> {
  late GlobalObjectKey _key;

  @override
  void initState() {
    _key = GlobalObjectKey(widget.node);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
        left: widget.node.x,
        top: widget.node.y,
        child: RepaintBoundary(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NtNodeCircle(node: widget.node, update: () => setState(() {})),
              if (widget.titleOpacity.value > 0)
                _NtNodeTitle(
                  key: _key,
                  node: widget.node,
                  titleOpacity: widget.titleOpacity,
                )
            ],
          ),
        ));
  }
}

class _NtNodeCircle extends StatelessWidget {
  const _NtNodeCircle({required this.node, required this.update});

  final TreeNode node;

  final VoidCallback update;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanUpdate: (details) {
        node.x = max(0, node.x + details.delta.dx);
        node.y = max(0, node.y + details.delta.dy);
        update();
      },
      onTap: () {
        StatefulNavigationShell.of(context).goBranch(0);
        context.goNamed(NOTE_ROUTE,
            pathParameters: {NOTE_RELATIVE_PATH_ROUTE: node.note.relativePath});
      },
      child:
          // * Node. A circle (with a circle inside) with title under it
          Container(
        width: node.tapSize,
        height: node.tapSize,
        decoration: ShapeDecoration(
          shape: const CircleBorder(),
        ),
        alignment: AlignmentDirectional.center,
        child: Container(
          alignment: AlignmentDirectional.center,
          width: node.size,
          height: node.size,
          decoration: ShapeDecoration(
              shape: const CircleBorder(), color: node.nodeColor),
        ),
      ),
    );
  }
}

class _NtNodeTitle extends StatelessWidget {
  const _NtNodeTitle(
      {required this.node, required this.titleOpacity, super.key});
  final TreeNode node;
  final ValueNotifier<double> titleOpacity;

  @override
  Widget build(BuildContext context) {
    final kKey = GlobalKey();
    return RepaintBoundary(
      child: SizedBox(
        width: node.size,
        child: ValueListenableBuilder(
            key: kKey,
            valueListenable: titleOpacity,
            builder: (context, value, child) {
              int tAlp = (255 * value).toInt();
              final noteEntity =
                  NoteEntity(relativePath: node.note.relativePath);

              return _NtNodeTitleText(title: noteEntity.title, textAlpha: tAlp);
            }),
      ),
    );
  }
}

class _NtNodeTitleText extends StatelessWidget {
  const _NtNodeTitleText({required this.title, required this.textAlpha});

  final String title;
  final int textAlpha;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
        minWidth: 0,
        maxWidth: double.infinity,
        fit: OverflowBoxFit.deferToChild,
        child: Text.rich(
          TextSpan(
              text: title,
              style: TextStyle(
                  fontSize: 7,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withAlpha(textAlpha))),
        ));
  }
}
