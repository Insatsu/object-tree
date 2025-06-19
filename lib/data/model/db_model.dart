// ignore_for_file: must_be_immutable

import 'package:equatable/equatable.dart';
import 'package:object_tree/data/model/model.dart';

class DbNote extends Equatable {
  int? id;
  final String _relativePath;

  String get relativePath => _relativePath;


  DbNote.relativePath({required String relativePath})
      : _relativePath = relativePath;

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      columnNotesRelativePath: _relativePath,
    };
    if (id != null) {
      map[columnNotesId] = id;
    }
    return map;
  }

  DbNote.fromMap(Map<String, Object?> map)
      : assert(map[columnNotesRelativePath] != null),
        id = map[columnNotesId] as int,
        _relativePath = map[columnNotesRelativePath] as String;

  @override
  List<Object?> get props => [id ?? relativePath];
}

class DbRelation extends Equatable {
  int? _idFrom;
  int? _idTo;

  DbRelation();

  DbRelation.fromSet((int, int) ids) {
    _idFrom = ids.$1;
    _idTo = ids.$2;
  }

  DbRelation.fromMap(Map<String, Object?> map) {
    _idFrom = map[columnRelationsIdFrom] as int;
    _idTo = map[columnRelationsIdTo] as int;
  }

  Map<String, Object?> toMap() {
    var map = <String, int?>{
      columnRelationsIdFrom: _idFrom,
      columnRelationsIdTo: _idTo
    };
    return map;
  }

  (int, int) ids() {
    return (_idFrom!, _idTo!);
  }

  @override
  List<Object?> get props => [_idFrom, _idTo];
}
