import 'dart:math';

import 'package:flutter/material.dart';
import 'package:object_tree/data/data.dart';
import "package:path/path.dart" as p;

class PainterSettings {
  static late Color lineColor;
  static late Color arrowColor;
}

class RelationsAndNodePainter extends CustomPainter {
  RelationsAndNodePainter({
    required this.textStyle,
    required this.titleOpacity,
    List<TreeEdge>? edges,
    List<TreeNode>? nodes,
  })  : edges = edges ?? [],
        nodes = nodes ?? [];

  final TextStyle textStyle;
  final double titleOpacity;

  List<TreeEdge> edges;
  List<TreeNode> nodes;

  Set<TreeNode> cacehdNodes = {};

  Paint linePaint = Paint()
    ..color = PainterSettings.lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  Paint arrowPaint = Paint()
    ..color = PainterSettings.arrowColor
    ..strokeWidth = 2;

  static const double arrowSize = 5;
  static const arrowAngle = 20 * pi / 180;

  // * Pain only on change top-level widgets or when this lines are changed
  @override
  void paint(Canvas canvas, Size size) async {
    cacehdNodes.clear();

    drawRelationsAndNodes(canvas);
  }

  void drawRelationsAndNodes(Canvas canvas) {
    Path linesPath = Path();
    Path arrowsPath = Path();

    Path singleNodesPath = Path();
    Path headNodesPath = Path();
    Path childNodesPath = Path();

    for (var edge in edges) {
      if (edge.nodeFrom == edge.nodeTo) {
        continue;
      }
      var nodeFrom = edge.nodeFrom;
      var nodeTo = edge.nodeTo;

      drawRelation(
          nodeTo: nodeTo,
          nodeFrom: nodeFrom,
          linesPath: linesPath,
          arrowsPath: arrowsPath);

      drawNode(
          node: nodeTo,
          canvas: canvas,
          lookInCache: true,
          nodesPath: headNodesPath);    }

    for (var node in nodes) {
      if (node.headCount == 0 && node.childCount == 0) {
        drawNode(
            node: node,
            canvas: canvas,
            lookInCache: true,
            nodesPath: singleNodesPath);
        continue;
      }
      if (node.headCount >= node.childCount) {
        drawNode(
            node: node,
            canvas: canvas,
            lookInCache: true,
            nodesPath: headNodesPath);
        continue;
      }
      if (node.headCount < node.childCount) {
        drawNode(
            node: node,
            canvas: canvas,
            lookInCache: true,
            nodesPath: childNodesPath);
      }
    }

    Paint singleNodePaint = Paint()
      ..color = TreeNode.colorByType[TreeNodeDefaultColor()]!;
    Paint headNodePaint = Paint()
      ..color = TreeNode.colorByType[TreeNodeHeadColor()]!;
    Paint childNodePaint = Paint()
      ..color = TreeNode.colorByType[TreeNodeChildColor()]!;

    linesPath.close();
    arrowsPath.close();
    singleNodesPath.close();
    headNodesPath.close();
    childNodesPath.close();

    canvas.drawPath(linesPath, linePaint);
    canvas.drawPath(arrowsPath, arrowPaint);
    canvas.drawPath(singleNodesPath, singleNodePaint);
    canvas.drawPath(headNodesPath, headNodePaint);
    canvas.drawPath(childNodesPath, childNodePaint);
  }

  void drawNode(
      {required TreeNode node,
      required bool lookInCache,
      required Canvas canvas,
      required Path nodesPath}) {
    // var op = (255 * titleOpacity.value).toInt();
    // var op = (255 * titleOpacity).toInt();
    // var opatxtstl = textStyle.copyWith(color: textStyle.color!.withAlpha(op));
    var isCached = cacehdNodes.contains(node);

    if (lookInCache && !isCached) {
      nodesPath.addOval(Rect.fromCircle(
        center: node.centerPosition,
        radius: node.size / 2,
      ));
    }

    cacehdNodes.add(node);
  }

  void drawRelation(
      {required TreeNode nodeTo,
      required TreeNode nodeFrom,
      required Path linesPath,
      required Path arrowsPath}) {
    var dX = nodeTo.centerPosition.dx - nodeFrom.centerPosition.dx;
    var dY = nodeTo.centerPosition.dy - nodeFrom.centerPosition.dy;
    var angle = atan2(dY, dX);

    Offset endPoint = Offset(
        nodeTo.centerPosition.dx - nodeTo.size / 2 * cos(angle),
        nodeTo.centerPosition.dy - nodeTo.size / 2 * sin(angle));

    Offset endLinePoint = endPoint.translate(
        -arrowSize * 0.5 * cos(angle), -arrowSize * 0.5 * sin(angle));
    // * Draw line
    var line = Path();
    line.moveTo(nodeFrom.centerPosition.dx, nodeFrom.centerPosition.dy);
    line.lineTo(endLinePoint.dx, endLinePoint.dy);
    line.close();

    linesPath.addPath(line, Offset.zero);

    // * Draw arrow
    var arrow = Path();
    arrow.moveTo(endPoint.dx - arrowSize * cos(angle - arrowAngle),
        endPoint.dy - arrowSize * sin(angle - arrowAngle));
    arrow.lineTo(endPoint.dx, endPoint.dy);
    arrow.lineTo(endPoint.dx - arrowSize * cos(angle + arrowAngle),
        endPoint.dy - arrowSize * sin(angle + arrowAngle));
    arrow.close();

    arrowsPath.addPath(arrow, Offset.zero);
  }

  @override
  bool shouldRepaint(RelationsAndNodePainter oldDelegate) {
    return false;
  }
}

// !============================================
// !============================================

class RelationsPainter extends CustomPainter {
  RelationsPainter({
    List<TreeEdge>? edges,
  }) : edges = edges ?? [];

  List<TreeEdge> edges;

  Paint linePaint = Paint()
    ..color = PainterSettings.lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2;
  Paint arrowPaint = Paint()
    ..color = PainterSettings.arrowColor
    ..strokeWidth = 2;

  static const double arrowSize = 5;
  static const arrowAngle = 20 * pi / 180;

  // * Pain only on change top-level widgets or when this lines are changed
  @override
  void paint(Canvas canvas, Size size) async {
    drawRelations(canvas);
  }

  void drawRelations(Canvas canvas) {
    Path linesPath = Path();
    Path arrowsPath = Path();

    for (var edge in edges) {
      if (edge.nodeFrom == edge.nodeTo) {
        continue;
      }
      var nodeFrom = edge.nodeFrom;
      var nodeTo = edge.nodeTo;

      var dX = nodeTo.centerPosition.dx - nodeFrom.centerPosition.dx;
      var dY = nodeTo.centerPosition.dy - nodeFrom.centerPosition.dy;
      var angle = atan2(dY, dX);
      Offset endPoint = Offset(
          nodeTo.centerPosition.dx - nodeTo.size / 2 * cos(angle),
          nodeTo.centerPosition.dy - nodeTo.size / 2 * sin(angle));

      Offset endLinePoint = endPoint.translate(
          -arrowSize * 0.5 * cos(angle), -arrowSize * 0.5 * sin(angle));
      // * Draw line
      var line = Path();
      line.moveTo(nodeFrom.centerPosition.dx, nodeFrom.centerPosition.dy);
      line.lineTo(endLinePoint.dx, endLinePoint.dy);
      line.close();

      linesPath.addPath(line, Offset.zero);

      // * Draw arrow
      var arrow = Path();
      arrow.moveTo(endPoint.dx - arrowSize * cos(angle - arrowAngle),
          endPoint.dy - arrowSize * sin(angle - arrowAngle));
      arrow.lineTo(endPoint.dx, endPoint.dy);
      arrow.lineTo(endPoint.dx - arrowSize * cos(angle + arrowAngle),
          endPoint.dy - arrowSize * sin(angle + arrowAngle));
      arrow.close();

      arrowsPath.addPath(arrow, Offset.zero);
    }

    linesPath.close();
    arrowsPath.close();

    canvas.drawPath(linesPath, linePaint);
    canvas.drawPath(arrowsPath, arrowPaint);
  }

  @override
  bool shouldRepaint(RelationsPainter oldDelegate) {
    return false;
  }
}

// !===============================================================

class NodePainter extends CustomPainter {
  NodePainter(
      {super.repaint,
      required this.nodes,
      required this.textStyle,
      required this.titleOpacity});
  final TextStyle textStyle;
  final double titleOpacity;
  List<TreeNode> nodes;

  @override
  void paint(Canvas canvas, Size size) {

    var op = (255 * titleOpacity).toInt();
    var opatxtstl = textStyle.copyWith(color: textStyle.color!.withAlpha(op));
    for (var node in nodes) {
      Paint crcPaint = Paint()..color = node.nodeColor;
      canvas.drawCircle(node.centerPosition, node.size / 2, crcPaint);

      if (op == 0) {
        continue;
      }

      var textSpan = TextSpan(
        text: p.basenameWithoutExtension(node.note.relativePath),
        style: opatxtstl,
      );
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout(
        minWidth: 0,
        maxWidth: double.infinity,
      );
      final xCenter = node.centerPosition.dx - textPainter.width / 2;
      final yCenter = node.centerPosition.dy + node.size + 2;
      final offset = Offset(xCenter, yCenter);
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant NodePainter oldDelegate) {
    return false;
  }
}
