import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_node.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_relations_painter.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NtNodesRelations extends StatefulWidget {
  const NtNodesRelations({
    super.key,
    required this.nodes,
    required this.edges,
    required this.titleOpacity,
  });

  final List<TreeNode> nodes;
  final List<TreeEdge> edges;
  final ValueNotifier<double> titleOpacity;

  @override
  State<NtNodesRelations> createState() => _NtNodesRelationsState();
}

class _NtNodesRelationsState extends State<NtNodesRelations> {
  final _stackKey = GlobalKey();
  DataWidget? _dw;

  Function(void Function())? stt;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    GetIt.I<Talker>().debug("didChangeDependencies TREE");
    _dw = DataWidget.maybeOf(context);
    _shownScreenIndexListener();
    _dw?.shownScreenIndex.removeListener(_shownScreenIndexListener);
    _dw?.shownScreenIndex.addListener(_shownScreenIndexListener);
  }

  @override
  void didUpdateWidget(covariant NtNodesRelations oldWidget) {
    super.didUpdateWidget(oldWidget);
    GetIt.I<Talker>().debug("didUpdateWidget TREE");
    _shownScreenIndexListener();
    _dw?.shownScreenIndex.removeListener(_shownScreenIndexListener);
    _dw?.shownScreenIndex.addListener(_shownScreenIndexListener);
  }

  void _shownScreenIndexListener() {
    if (DataWidget.of(context).shownScreenIndex.value == 0) {
      return;
    }

  }



  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: RelationsPainter(
          edges: widget.edges,
        ),
        isComplex: true,
        willChange: true,
        child: Stack(
          key: _stackKey,
          children: [
            ...widget.nodes.map((el) {
              return NtNode(
                key: ObjectKey(el),
                node: el,
                titleOpacity: widget.titleOpacity,
              );
            }),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _dw?.shownScreenIndex.removeListener(_shownScreenIndexListener);
    super.dispose();
  }
}

