// ignore_for_file: constant_identifier_names
import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:object_tree/core/errors.dart';
import 'package:object_tree/data/model/model.dart';

class TreeWorker {
  final SendPort _commands;
  final ReceivePort _responses;
  final Map<int, Completer<List<TreeNode>>> _activeRequests = {};
  int _idCounter = 0;
  bool _closed = false;

  static final Map<int, bool> _canceledMap = {};
  bool get isEmpty => _activeRequests.isEmpty;

  Future<List<TreeNode>> updateTree(IsMes message) async {
    if (_closed) throw StateError('Closed');
    final completer = Completer<List<TreeNode>>.sync();

    final id = _idCounter++;
    _activeRequests[id] = completer;

    _commands.send((id, message));
    return await completer.future;
  }

  static Future<TreeWorker> spawn() async {
    // Create a receive port and add its initial message handler
    final initPort = RawReceivePort();
    final connection = Completer<(ReceivePort, SendPort)>.sync();
    initPort.handler = (initialMessage) {
      final commandPort = initialMessage as SendPort;
      connection.complete((
        ReceivePort.fromRawReceivePort(initPort),
        commandPort,
      ));
    };

    // Spawn the isolate.
    try {
      await Isolate.spawn(_startRemoteIsolate, (initPort.sendPort));
    } on Object {
      initPort.close();
      rethrow;
    }

    final (ReceivePort receivePort, SendPort sendPort) =
        await connection.future;

    /// [sendPort] is port from new isolate and it sets to _commands in constructor
    /// [receivePort] is port our (main) isolate and it sets to _responses

    return TreeWorker._(receivePort, sendPort);
  }

  TreeWorker._(this._responses, this._commands) {
    _responses.listen(_handleResponsesFromIsolate);
  }

  static void _startRemoteIsolate(SendPort sendPort) {
    final receivePort = ReceivePort();
    sendPort.send(receivePort.sendPort);
    _handleCommandsToIsolate(receivePort, sendPort);
  }

  void _handleResponsesFromIsolate(dynamic message) {
    if (message is (int, CommandToIsolate) &&
        message.$2 == CommandToIsolate.Cancel) {
      final (int id, _) = message;

      final completer = _activeRequests.remove(id)!;
      completer.completeError(OperationCanceled());
      return;
    }

    final (int id, List<TreeNode> response) = message as (int, List<TreeNode>);
    final completer = _activeRequests.remove(id)!;

    completer.complete(response);
  }

  static void _handleCommandsToIsolate(
    ReceivePort receivePort,
    SendPort sendPort,
  ) {
    receivePort.listen((message) async {
      if (message == CommandToIsolate.Close) {
        receivePort.close();
        return;
      }

      if (message is (int, CommandToIsolate) &&
          message.$2 == CommandToIsolate.Cancel) {
        final (int id, CommandToIsolate command) = message;
        _canceledMap[id] = true;
        return;
      }

      final (int id, IsMes mes) = message as (int, IsMes);
      try {
        final newNodes = await _updateTreeBatch(mes, id);
        sendPort.send((
          id,
          newNodes
        )); // send to main isolate. _handleResponsesFromIsolate take this message
      } on OperationCanceled catch (_) {
        sendPort.send((id, CommandToIsolate.Cancel));
      }
    });
  }

  void cancelCurrentCompute() {
    for (int id in _activeRequests.keys) {
      _commands.send((
        id,
        CommandToIsolate.Cancel,
      ));
    }
  }

  void close() {
    if (!_closed) {
      _closed = true;
      _commands.send(CommandToIsolate.Close);
      if (_activeRequests.isEmpty) _responses.close();
    }
  }

  static Future<List<TreeNode>> _updateTreeBatch(IsMes message, int id) async {
    List<TreeNode> batchNodes = message.batchNodes;
    List<TreeNode> nodes = message.nodes;
    List<TreeEdge> edges = message.edges;

    for (int i = 0; i < batchNodes.length; i++) {
      double forceX = 0;
      double forceY = 0;

      // Let event-loop look in other part of the code so it allow to check current state of the [_canceledMap]
      // and cancel itself if need
      await Future.delayed(Duration(milliseconds: 0));
      // Check if it is needed to be stoped
      if (_canceledMap[id] != null && _canceledMap[id]!) {
        _canceledMap[id] = false;
        throw OperationCanceled();
      }
      for (int j = 0; j < nodes.length; j++) {
        if (batchNodes[i] == nodes[j]) {
          continue;
        }

        Offset delta = batchNodes[i].centerPosition - nodes[j].centerPosition;

        double distance = delta.distance + 1;

        // Compute physical force
        if (edges
            .contains(TreeEdge(nodeFrom: nodes[j], nodeTo: batchNodes[i]))) {
          final local_l_uv = TreeNode.l_uv;

          double fX = TreeNode.s_uv *
              (distance - local_l_uv) *
              (batchNodes[i].x - nodes[j].x) /
              distance;

          double fY = TreeNode.s_uv *
              (distance - local_l_uv) *
              (batchNodes[i].y - nodes[j].y) /
              distance;

          // ! If batch in nodeFROM
          if (fX.sign == delta.dx.sign && fX.abs() > local_l_uv * 2) {
            fX = local_l_uv * fX.sign;
          }
          if (fY.sign == delta.dy.sign && fY.abs() > local_l_uv * 2) {
            fY = local_l_uv * fY.sign;
          }

          if (fX.abs() > 0.01) {
            // ! If batch in nodeTO
            forceX += fX / 2;
            nodes[j].position -= Offset(fX, 0);
            distance += Offset(fX, 0).distance;
          }
          if (fY.abs() > 0.01) {
            // ! If batch in nodeTO
            forceY += fY / 2;
            nodes[j].position -= Offset(0, fY);
            distance += Offset(0, fY).distance;
          }
          continue;
        }

        double gX = 0;
        double gY = 0;
        gX = (((TreeNode.c_uv) / (distance.abs())) *
            ((batchNodes[i].x - nodes[j].x) / distance));
        gY = (((TreeNode.c_uv) / (distance.abs())) *
            ((batchNodes[i].y - nodes[j].y) / distance));

        if (gX.abs() > 0.01) {
          forceX += gX / 2;
          nodes[j].x -= gX / 2;
        }
        if (gY.abs() > 0.01) {
          forceY += gY / 2;
          nodes[j].y -= gY / 2;
        }
      }

      batchNodes[i].velocity =
          Offset(forceX, forceY);
    }

    for (var node in batchNodes) {
      node.position += node.velocity;
    }

    return batchNodes;
  }
}

class TreeWorkerPool {
  final List<TreeWorker> _workers;

  TreeWorkerPool._(this._workers);

  // ignore: non_constant_identifier_names
  static int ISOLATES_COUNT_MAX = 1;
  static int maxNodesForIsolate = 150;

  /// Spawn [count] isolates pool
  static Future<TreeWorkerPool> spawnPool(int count) async {
    // Check if get [count] is lower that [ISOLATES_COUNT_MAX] and higher than 1
    count = min(count, ISOLATES_COUNT_MAX);
    count = max(1, count);

    final workers = await Future.wait(
      List.generate(count, (_) => TreeWorker.spawn()),
    );
    return TreeWorkerPool._(workers);
  }

  /// Разбиваем [batch] на N частей и шлём каждую своему изоляту
  Future<List<TreeNode>> updateTree(
    List<TreeNode> batch,
    List<TreeNode> allNodes,
    List<TreeEdge> edges,
  ) async {
    final int n = _workers.length;
    if (n == 0) throw StateError('No workers in pool');

    // Cancel the calculation if there are any
    for (var worker in _workers) {
      if (!worker.isEmpty) {
        worker.cancelCurrentCompute();
      }
    }

    int needIsolatesCount =
        min((batch.length / maxNodesForIsolate).round(), ISOLATES_COUNT_MAX);
    needIsolatesCount = max(1, needIsolatesCount);
    needIsolatesCount = min(n, needIsolatesCount);

    final int chunkSize = (batch.length / needIsolatesCount).ceil();
    final List<Future<List<TreeNode>>> futures = [];

    for (int i = 0, j = 0; i < batch.length; i += chunkSize, j++) {
      final sub = batch.sublist(i, min(i + chunkSize, batch.length));
      final worker = _workers[j];
      futures.add(worker.updateTree(IsMes(sub, allNodes, edges)));
    }

    final parts = await Future.wait(futures);

    return parts.expand((x) => x).toList();
  }

  void close() {
    for (final w in _workers) {
      w.close();
    }
  }
}

class IsMes {
  IsMes(this.batchNodes, this.nodes, this.edges);

  List<TreeNode> batchNodes;
  List<TreeNode> nodes;
  List<TreeEdge> edges;
}

enum CommandToIsolate { Cancel, Close }
