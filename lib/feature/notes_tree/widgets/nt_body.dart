import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/notes_tree/bloc/nt_bloc.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_nodes_relations.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_relations_painter.dart';
import 'package:object_tree/i18n/strings.g.dart';


class NtBody extends StatefulWidget {
  const NtBody({super.key});

  static void customInitDefaultIVProperties(
      {required TransformationController interactiveController,
      required Color lineColor,
      required Color arrowColor,
      required double screenWidth,
      required double screenHeight,
      double scale = 1}) {
    // * Set colors for line and arrows
    PainterSettings.lineColor = lineColor;
    PainterSettings.arrowColor = arrowColor;

    // * Move screen to center position and set default zoom
    interactiveController.value
        .setEntry(0, 3, (-TreeNode.canvasSize + screenWidth) / 2
            );
    interactiveController.value
        .setEntry(1, 3, (-TreeNode.canvasSize + screenHeight) / 2
            );

    interactiveController.value.setEntry(0, 0, scale);
    interactiveController.value.setEntry(1, 1, scale);
    interactiveController.value.setEntry(2, 2, scale);
  }

  @override
  State<NtBody> createState() => _NtBodyState();
}

class _NtBodyState extends State<NtBody> {
  final _ivKey = GlobalKey();
  final _ivBodyKey = GlobalKey();
  final _relKey = GlobalKey();
  TransformationController interactiveController = TransformationController();
  final maxScale = 18.0;

  final double _minScaleToSeeTitle = 0.5;
  final double _maxScaleToSeeTitle = 2;
  final _nodeTitleOpacity = ValueNotifier(1.0);
  final int scalesCount = 5;

  @override
  Widget build(BuildContext context) {
    NtBody.customInitDefaultIVProperties(
        interactiveController: interactiveController,
        lineColor: Theme.of(context).colorScheme.tertiary,
        arrowColor: Theme.of(context).colorScheme.onSecondaryContainer,
        screenWidth: MediaQuery.of(context).size.width,
        screenHeight: MediaQuery.of(context).size.height);

    return InteractiveViewer(
      key: _ivKey,
      transformationController: interactiveController,
      minScale: 0.05,
      maxScale: maxScale,
      clipBehavior: Clip.hardEdge,
      constrained: false,
      // onInteractionUpdate: (details) {
      //   final currentScale = interactiveController.value.getMaxScaleOnAxis();
      //   if (currentScale < _minScaleToSeeTitle) {
      //     if (_nodeTitleOpacity.value != 0) _nodeTitleOpacity.value = 0;
      //     return;
      //   }
      //   if (currentScale > _maxScaleToSeeTitle) {
      //     if (_nodeTitleOpacity.value != 1) _nodeTitleOpacity.value = 1;
      //     return;
      //   }
      //   final currentScalePart = currentScale - _minScaleToSeeTitle;
      //   final maxMinScaleDiff = _maxScaleToSeeTitle - _minScaleToSeeTitle;

      //   final rawOpacity = (currentScalePart / maxMinScaleDiff) / 2;
      //   final tempOpacity = ((rawOpacity * 10).round() / 10) * 2;

      //   if (_nodeTitleOpacity.value == tempOpacity) return;

      //   _nodeTitleOpacity.value = tempOpacity;
      // },
      child: _IVBody(
          key: _ivBodyKey,
          relKey: _relKey,
          nodeTitleOpacity: _nodeTitleOpacity),
    );
  }

  @override
  void dispose() {
    interactiveController.dispose();
    super.dispose();
  }
}

class _IVBody extends StatelessWidget {
  const _IVBody({
    super.key,
    required GlobalKey<State<StatefulWidget>> relKey,
    required ValueNotifier<double> nodeTitleOpacity,
  })  : _relKey = relKey,
        _nodeTitleOpacity = nodeTitleOpacity;

  final GlobalKey<State<StatefulWidget>> _relKey;
  final ValueNotifier<double> _nodeTitleOpacity;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: TreeNode.canvasSize,
      child: BlocBuilder<NtBloc, NtState>(
        buildWhen: (previous, current) =>
            current is NtLoaded || current is NtSorted || current is NtLoading ,
        builder: (context, state) {
          if (state is NtLoaded) {
            return NtNodesRelations(
              key: _relKey,
              nodes: state.nodes,
              edges: state.edges,
              titleOpacity: _nodeTitleOpacity,
            );
          }
          if (state is NtSorted) {
            return NtNodesRelations(
              key: _relKey,
              nodes: state.nodes,
              edges: state.edges,
              titleOpacity: _nodeTitleOpacity,
            );
          }

          if (state is NtFailure) {
            return Center(
              child: Text(t.note_tree.error_on_load_tree),
            );
          }

          return Center(
            child: Text(t.note_tree.loading),
          );
        },
      ),
    );
  }
}
