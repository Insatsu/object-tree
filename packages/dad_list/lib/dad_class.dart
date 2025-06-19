import 'dad.dart';

/// Main interface for every item in [DadListPast]
///
/// [title] is string presentaion of item, its name. By default it
/// used as [data] for [Text] widget in list items
///
/// [item] data that you can contain in this class
///
interface class IDadItem<T extends Object> {
  String title;

  T? item;

  IDadItem(this.title, {this.item});
}

/// Extends for [IDadItem] with additional property [children]
/// that will contain another [IDadItem] objects.
///
/// Used to define what kind of widget should be used
///
interface class IDadList<T extends Object> implements IDadItem<T> {
  @override
  String title;

  @override
  T? item;

  List<IDadItem<T>> children;

  IDadList(this.title, {required this.children, this.item});
}

/// Contain item [IDadItem] itself, its parrent if it exist and [setState] method of its widget
///
/// Used as [data] in [DadItemDraggableTile] and [DadTarget] widgets.
/// [parrent] can be null only for [DadRootList] that contain all other items
/// [setStateParrent] needs to call it in [DadTarget] widget when items moved is completed
/// to update both parrent widget and target widget
///
class DadItemDetail<T extends Object> {
  IDadList<T>? parrent;
  IDadItem<T> dadItem;
  // DadWidgetSetState? setStateParrent;
  DadWidgetSetStateWrapper setStateParrent;

  DadItemDetail(this.dadItem, {this.parrent, required this.setStateParrent})
      : assert((parrent != null || dadItem is DadRootList),
            '[parrent] can be null only if item is [DadRootList]');

  @override
  String toString() {
    return 'DadItemDetail Instance.\n\tparrent: ${parrent.toString()}\n\titem: ${dadItem.toString()}';
  }
}

///
/// Simple realization of [IDadItem]
///
/// Defines as [ListTile]
///
class DadItem<T extends Object> implements IDadItem<T> {
  @override
  String title;

  @override
  T? item;

  DadItem(this.title, {this.item});

  @override
  String toString() {
    return 'DadItem Instance. T is <${T.toString()}>. title is <$title>. item is <${item.toString()}>';
  }

}

///
/// Simple realization of [IDadList]
///
/// Defines as [ExpansionTile] in [DadItemTilePast]
///
class DadExpansionList<T extends Object> implements IDadList<T> {
  @override
  String title;

  @override
  T? item;

  @override
  List<IDadItem<T>> children;

  bool isExpanded;

  DadExpansionList(this.title,
      {this.item, this.children = const [], this.isExpanded = false});

  @override
  String toString() {
    return 'DadExpansionList Instance. T is <${T.toString()}>. title is <$title>. item is <${item.toString()}>. children length: <${children.length}>. isExpanded: <$isExpanded>';
  }
}

/// Used to definition root list that cannot have parrent
class DadRootList<T extends Object> implements IDadList<T> {
  @override
  String title;

  @override
  T? item;

  @override
  List<IDadItem<T>> children;

  DadRootList({this.title = '', this.item, this.children = const []});

  @override
  String toString() {
    return 'DadRootList Instance. T is <${T.toString()}>. item is <${item.toString()}>. children length: <${children.length}>';
  }
}
