import 'dart:io';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/app.dart';
import 'package:object_tree/core/errors.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/data/model/db_model.dart';
import 'package:object_tree/data/model/tree_edge.dart';
import 'package:object_tree/data/repositories/tree_repository.dart';
import 'package:object_tree/data/repositories/worker.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'nt_event.dart';
part 'nt_state.dart';

class NtBloc extends Bloc<NtEvent, NtState> {
  @override
  Future<void> close() {
    _treeWorkerPool?.close();
    return super.close();
  }

  NtBloc()
      : _nodes = [],
        _edges = [],
        super(const NtInitial()) {
    /// Set max count for isolates that compute nodes positions.
    /// The value is OS number of processors
    TreeWorkerPool.ISOLATES_COUNT_MAX = Platform.numberOfProcessors - 1;

    on<NtLoadAll>((event, emit) async {
      await _onNtLoadAll(emit);
    });

    on<NtLoadRelative>((event, emit) async {
      await _onNtLoadRelative(event, emit);
    });

    on<NtUpdateTree>((event, emit) {
      if (_isRelativeNotesTree) {
        add(NtLoadRelative(note: relativeNotesHistory.first));
      } else {
        add(NtLoadAll());
      }
    });

    on<NtLoadSearchList>((event, emit) async {
      await _onNtLoadSearchList(event, emit);
    });
  }

  Future<void> _onNtLoadSearchList(
      NtLoadSearchList event, Emitter<NtState> emit) async {
    try {

      var tempNote = await GetIt.I<INodeRepository>().getNotes();
      var allNotes = tempNote.map((note) => note.relativePath).toSet();

      Set<String> searchedNodes = {};
      
      if (event.word.isEmpty) {
        emit(NtSearchListLoaded(nodes: allNotes));
        return;
      }

      for (var el in allNotes) {
        if (!el.contains(event.word)) continue;

        searchedNodes.add(el);
      }

      emit(NtSearchListLoaded(nodes: searchedNodes));
    } catch (e, st) {
      emit(NtFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  Future<void> _onNtLoadRelative(
      NtLoadRelative event, Emitter<NtState> emit) async {
    try {
      GetIt.I<Talker>().info('NtBloc NtLoadRelative');
      await GetIt.I<INodeRepository>().db.updateProps();

      var dbNotes = await GetIt.I<INodeRepository>()
          .getNotesInRelationWith(event.note, depth: 100);

      var eventNoteWithId = dbNotes.first;


      _nodes.clear();
      for (final tn in dbNotes) {
        _allNodes.remove(tn);
        _allNodes[tn] = TreeNode(tn);
        _nodes.add(_allNodes[tn]!);
      }

      _updateHistory();

      emit(NtLoading());

      await _operationCanceledMapper(() async {
        await _setConnectionToNodes(dbNotes);

        await _sortNodesPositionsTEST();

        await _setConnectionToNodes(dbNotes);

        emit(NtSorted(nodes: _nodes, edges: _edges));

        // Add to history
        relativeNotesHistory.remove(eventNoteWithId);
        relativeNotesHistory.insert(0, eventNoteWithId);
        _isRelativeNotesTree = true;
      });
    } catch (e, st) {
      emit(NtFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
      add(NtLoadAll());
    }
  }

  Future<void> _onNtLoadAll(Emitter<NtState> emit) async {
    try {
      GetIt.I<Talker>().info('NtBloc NtLoad');
      await GetIt.I<INodeRepository>().db.updateProps();
      var dbNotes = await GetIt.I<INodeRepository>().getNotes();

      _allNodes.clear();
      for (final tn in dbNotes) {
        _allNodes[tn] = TreeNode(tn);
      }
      _nodes = _allNodes.values.toList();

      _updateHistory();

      emit(NtLoading());

      await _operationCanceledMapper(() async {
        await _setConnectionToNodes(dbNotes);

        await _sortNodesPositionsTEST();

        await _setConnectionToNodes(dbNotes);

        emit(NtSorted(nodes: _nodes, edges: _edges));
        _isRelativeNotesTree = false;

        GetIt.I<Talker>().info('NtBloc sorted end');
      });
    } catch (e, st) {
      emit(NtFailure(exception: e));
      GetIt.I<Talker>().handle(e, st);
    }
  }

  // ==============================================================================
  // * Realisations
  Future<void> _sortNodesPositionsTEST() async {
    if (_treeWorkerPool == null) {
      int isolatesCount =
          (_nodes.length / TreeWorkerPool.maxNodesForIsolate).round();

      _treeWorkerPool = await TreeWorkerPool.spawnPool(isolatesCount);
    }

    final Map<int, TreeNode> tempNodes = {};
    for (var tempNode in _nodes) {
      tempNodes[tempNode.hashCode] = tempNode.copy();
    }

    final result = await TreeRepository(tempNodes, _edges,
            treeWorkerPool: _treeWorkerPool!)
        .setNodes();

    _nodes = result;
  }

  Future<void> _setConnectionToNodes(List<DbNote> dbNotes) async {
    List<DbRelation> dbRelations =
        await GetIt.I<INodeRepository>().getRelationsFromList(dbNotes);

    _edges.clear();

    for (var relation in dbRelations) {
      var nodeFrom = _nodes
          .firstWhereOrNull((element) => element.note.id == relation.ids().$2);

      if (nodeFrom == null) continue;

      var nodeTo = _nodes
          .firstWhereOrNull((element) => element.note.id == relation.ids().$1);

      if (nodeTo == null) continue;

      _edges.add(TreeEdge(nodeTo: nodeFrom, nodeFrom: nodeTo));
    }
  }

  void _updateHistory() {
    for (var i = 0; i < relativeNotesHistory.length; i++) {
      var localNote = relativeNotesHistory.elementAt(i);
      var nodeInNodes = _allNodes[localNote];
      // * If note was deleted than delete it from history
      if (nodeInNodes == null) {
        relativeNotesHistory.removeAt(i);
        i--;
        // * If deleted note was root in tree
        if (_isRelativeNotesTree && _nodes.first == localNote) {
          add(const NtLoadAll());
        }
        continue;
      }
      if (localNote.relativePath != nodeInNodes.note.relativePath) {
        relativeNotesHistory.removeAt(i);
        relativeNotesHistory.insert(i, nodeInNodes.note);
      }
    }
  }

  // * Mappers
  Future<void> _operationCanceledMapper(Future<void> Function() arg) async {
    try {
      await arg();
    } on OperationCanceled catch (e) {
      GetIt.I<Talker>().error("From set nodes: $e");
    } on Exception {
      rethrow;
    }
  }

  // *  Fileds
  final Map<DbNote, TreeNode> _allNodes = {};

  List<TreeNode> _nodes;
  final List<TreeEdge> _edges;

  final List<DbNote> relativeNotesHistory = [];
  bool _isRelativeNotesTree = false;

  TreeWorkerPool? _treeWorkerPool;
}
