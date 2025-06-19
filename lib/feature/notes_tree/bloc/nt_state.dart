// ignore_for_file: hash_and_equals

part of 'nt_bloc.dart';

sealed class NtState extends Equatable {
  const NtState();
}

class NtInitial extends NtState {
  const NtInitial();

  @override
  List<Object?> get props => [];
}

// =====================================================================
class NtLoaded extends NtState {
  const NtLoaded({required this.nodes, required this.edges});

  final List<TreeNode> nodes;
  final List<TreeEdge> edges;

  @override
  bool operator ==(Object other) {
    return false;
  }

  @override
  List<Object?> get props => [nodes, edges];
}

class NtSorted extends NtState {
  const NtSorted({required this.nodes, required this.edges});

  final List<TreeNode> nodes;
  final List<TreeEdge> edges;

  @override
  bool operator ==(Object other) {
    return false;
  }

  @override
  List<Object?> get props => [nodes, edges];
}

// =====================================================================

class NtSearchListLoaded extends NtState {
  const NtSearchListLoaded({required this.nodes});
  final Set<String> nodes;

  @override
  List<Object?> get props => [nodes];
}

// =====================================================================
class NtLoading extends NtState {
  const NtLoading();

  @override
  List<Object?> get props => [];
}
// =====================================================================
// =====================================================================
// =====================================================================
// =====================================================================
// =====================================================================
class NtFailure extends NtState {
  const NtFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
