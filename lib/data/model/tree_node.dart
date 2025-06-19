// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:object_tree/data/model/model.dart';

// ignore: must_be_immutable
class TreeNode extends Equatable {
  TreeNode(this.note,
      {
      Color? nodeColor,
      double? x,
      double? y})
      :
        size = defaultSize,
        velocity = Offset.zero,
        nodeColor =
            nodeColor ?? colorByType[TreeNodeDefaultColor()] ?? Colors.teal,
        x = x ?? canvasCenter,
        y = y ?? canvasCenter;

  DbNote note;
  Color nodeColor;
  double size;
  double get tapSize => size * tapSizeRatio;
  Offset velocity;

  static const double defaultSize = 18;
  static double tapSizeRatio = 2;
  static double defaultTapSize = defaultSize * tapSizeRatio;

  static Map<TreeNodeColorType, Color> colorByType = {
    TreeNodeHeadColor(): Colors.orange,
    TreeNodeChildColor(): Colors.blue,
    TreeNodeDefaultColor(): Colors.teal,
  };

  static double canvasSize = defaultTapSize * 1000;
  static double canvasCenter = canvasSize / 2;

  static const double l_uv = defaultSize * 7;
  static const double s_uv = -0.3;
  static const double c_uv = defaultSize * 7;

  // static double l_uv = defaultSize*10;
  // static double s_uv = -0.1;
  // static double c_uv = defaultSize*3;

  double x;
  double y;

  int headCount = 0;
  int childCount = 0;

  Offset get centerPosition => Offset(x + tapSize / 2, y + tapSize / 2);

  Offset get position => Offset(x, y);
  set position(Offset pos) {
    x = pos.dx;
    y = pos.dy;
  }

  TreeNode copy() {
    return TreeNode(
      note,
      nodeColor: nodeColor
    );
  }

  @override
  String toString() {
    return "$runtimeType[($position), ($note)]";
  }

  @override
  bool? get stringify => false;

  @override
  List<Object?> get props => [note, colorByType[TreeNodeDefaultColor()]];
}

// =============================================================
// =============================================================
sealed class TreeNodeColorType extends Equatable {
  const TreeNodeColorType();
}

class TreeNodeHeadColor extends TreeNodeColorType {
  const TreeNodeHeadColor();

  @override
  List<Object?> get props => [];
}

class TreeNodeDefaultColor extends TreeNodeColorType {
  const TreeNodeDefaultColor();
  @override
  List<Object?> get props => [];
}

class TreeNodeChildColor extends TreeNodeColorType {
  const TreeNodeChildColor();
  @override
  List<Object?> get props => [];
}
