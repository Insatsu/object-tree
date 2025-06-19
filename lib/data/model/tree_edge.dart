import 'package:equatable/equatable.dart';
import 'package:object_tree/data/model/model.dart';

class TreeEdge extends Equatable {
  const TreeEdge({required this.nodeTo, required this.nodeFrom});

  final TreeNode nodeFrom;
  final TreeNode nodeTo;

  @override
  bool? get stringify => false;

  @override
  List<Object?> get props => [nodeFrom, nodeTo];
}
