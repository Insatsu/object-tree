import 'dart:math';
import 'dart:ui';

import 'package:object_tree/data/data.dart';

class TreeRepository {
  // List<TreeNode> _nodes;
  final Map<int, TreeNode> _nodes;
  final List<TreeEdge> _edges;
  final TreeWorkerPool treeWorkerPool;

  double _mainRadius = 0;

  double get normRandomDelta =>
      -TreeNode.defaultTapSize / 2 +
      Random().nextDouble() * TreeNode.defaultSize * 2;

  TreeRepository(
      this._nodes,
      this._edges,
      {required this.treeWorkerPool});

  Future<List<TreeNode>> setNodes() async {
    _defaultSetNodes();

    var nodes = _nodes.values.toList();

    var cycleCount = 20;

    if(nodes.length > TreeWorkerPool.ISOLATES_COUNT_MAX * TreeWorkerPool.maxNodesForIsolate * 1.5 ){
      cycleCount = 1;
    }
    else if(nodes.length > TreeWorkerPool.ISOLATES_COUNT_MAX * TreeWorkerPool.maxNodesForIsolate ){
      cycleCount = 5;
    }
    else if(nodes.length > 250){
      cycleCount = 10;
    }
    else if(nodes.length > 100){
      cycleCount = 15;
    }


    for (var i = 0; i < cycleCount; i++) { 
      nodes = await treeWorkerPool.updateTree(nodes, nodes, _edges);
    }
    return nodes;
  }

  void _defaultSetNodes() {
    // * Node: its child
    Map<TreeNode, List<TreeNode>> clusters =
        {}; // сюда складываем компоненты связности

    // * Разбиваем узлы на группы
    for (var node in _nodes.values) {
      List<TreeNode> nodeConnections = [];
      for (var edge in _edges) {
        if (edge.nodeTo != node) {
          continue;
        }
        nodeConnections.add(_nodes[edge.nodeFrom.hashCode]!);
      }

      clusters[node] = nodeConnections;
    }

    __arrangeGroupsInsideCircle(clusters);
  }

  void __arrangeGroupsInsideCircle(Map<TreeNode, List<TreeNode>> clusters) {
    final Offset mainCenter =
        Offset(TreeNode.canvasCenter, TreeNode.canvasCenter);

    // Золотой угол  для равномерного распределения
    const double goldenAngle = 2.39996322972865332;
    // double goldenAngle = pi*(3 - sqrt(5));
    final int groupsCount = clusters.length;

    // максимальный радиус размещения внутри основного круга
    _mainRadius = max((TreeNode.defaultTapSize * groupsCount) / 6.28,
        TreeNode.defaultTapSize * 4);

    for (int i = 0; i < groupsCount; i++) {
      // метод равномерного распределения: чтобы плотность точек была постоянной,
      double r = _mainRadius * sqrt((i + 0.5) / groupsCount);
      double angle = i * goldenAngle;
      Offset groupCenter = Offset(
        mainCenter.dx + r * cos(angle),
        mainCenter.dy + r * sin(angle),
      );

      TreeNode headNode = clusters.keys.toList()[i];
      // There it is impotrtant to rigth define [equals] in headNode
      List<TreeNode> childNodes = clusters[headNode] ?? [];

      __arrangeNodesInGroup([headNode, ...childNodes], groupCenter);
    }
  }

  void __arrangeNodesInGroup(List<TreeNode> group, Offset groupCenter) {
    int nodeCount = group.length;

    if (nodeCount == 1) {
      if (group[0].position !=
          Offset(TreeNode.canvasCenter, TreeNode.canvasCenter)) {
        return;
      }

      group[0].position = Offset(
        groupCenter.dx + normRandomDelta,
        groupCenter.dy + normRandomDelta,
      );

      return;
    }

    final double localRadius = max(TreeNode.defaultTapSize * 5,
        TreeNode.defaultTapSize * sqrt(nodeCount) / 10);

    for (int j = 0; j < nodeCount; j++) {
      double angle = (2 * pi * j) / (nodeCount - 1);
      Offset nodePos;
      switch (j) {
        case 0:
          group[0].headCount++;
          if (group[0].headCount >= group[0].childCount) {
            group[0].nodeColor = TreeNode.colorByType[TreeNodeHeadColor()]!;
          }

          group[0].size = max(
              TreeNode.defaultSize, TreeNode.defaultSize * sqrt(nodeCount) / 2);

          nodePos = Offset(
            groupCenter.dx + normRandomDelta,
            groupCenter.dy + normRandomDelta,
          );
          break;
        default:
          group[j].childCount++;
          if (group[j].headCount < group[j].childCount) {
            group[j].nodeColor = TreeNode.colorByType[TreeNodeChildColor()]!;
          }

          if (group[j].position !=
              Offset(TreeNode.canvasCenter, TreeNode.canvasCenter)) {
            final wantPos = Offset(
              groupCenter.dx + localRadius * cos(angle) + normRandomDelta,
              groupCenter.dy + localRadius * sin(angle) + normRandomDelta,
            );
            final delta = wantPos - group[j].position;
            nodePos = wantPos - (delta / 2);
            break;
          }
          nodePos = Offset(
            groupCenter.dx + localRadius * cos(angle) + normRandomDelta,
            groupCenter.dy + localRadius * sin(angle) + normRandomDelta,
          );
          break;
      }

      group[j].position = nodePos;
    }
  }
}
