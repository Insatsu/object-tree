// ignore_for_file: hash_and_equals

part of './browser_bloc.dart';

sealed class BrowserState extends Equatable {
  const BrowserState();
}

class BrowserInitial extends BrowserState {
  const BrowserInitial();
  @override
  List<Object?> get props => [];
  @override
  bool operator ==(Object other) {
    return false;
  }
}

class BrowserLoading extends BrowserState {
  const BrowserLoading();
  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) {
    return false;
  }
}

class BrowserLoaded extends BrowserState {
  const BrowserLoaded({required this.itemsList});

  final List<BrowserItemNodeDad> itemsList;

  @override
  List<Object?> get props => [itemsList];
}

// ==============================================================
// * Creating part
class BrowserCreatingFolder extends BrowserState {
  const BrowserCreatingFolder(this.relativePath);

  final String relativePath;

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) {
    return false;
  }
}

class BrowserCreatingNote extends BrowserState {
  const BrowserCreatingNote(this.relativePath);

  final String relativePath;

  @override
  List<Object?> get props => [];
  
  @override
  bool operator ==(Object other) {
    return false;
  }
}
// * End creating part
// ==============================================================

// ==============================================================
// * Rename part
class BrowserBeginRenameObject extends BrowserState {
  const BrowserBeginRenameObject(this.relativePath);

  final String relativePath;

  @override
  List<Object?> get props => [];
  @override
  bool operator ==(Object other) {
    return false;
  }
}

class BrowserComplitedRenameObject extends BrowserState {
  const BrowserComplitedRenameObject(this.newRelativePath);

  final String newRelativePath;

  @override
  List<Object?> get props => [];
  @override
  bool operator ==(Object other) {
    return false;
  }
}

class BrowserRenameFailure extends BrowserState {
  const BrowserRenameFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}

// ==============================================================

// ==============================================================
// * Links
class BrowserUpdatedLinks extends BrowserState {
  const BrowserUpdatedLinks();

  @override
  List<Object?> get props => [];
  
  @override
  bool operator ==(Object other) {
    return false;
  }
}
// ==============================================================

// ==============================================================
// * Tree
class BrowserUpdatedTree extends BrowserState {
  const BrowserUpdatedTree({required this.note});

  final DbNote note;

  @override
  List<Object?> get props => [];

  @override
  bool operator ==(Object other) {
    return false;
  }
}

// ==============================================================

class BrowserSomeFailure extends BrowserState {
  const BrowserSomeFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}

class BrowserLoadingFailure extends BrowserState {
  const BrowserLoadingFailure({required this.exception});

  final Object? exception;

  @override
  List<Object?> get props => [exception];
}
