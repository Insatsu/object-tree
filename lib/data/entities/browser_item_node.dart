import 'package:dad_list/dad.dart';
import 'package:equatable/equatable.dart';
import 'package:object_tree/data/data.dart';


// ignore: must_be_immutable
class BrowserItemNodeDadDetails extends Equatable
    implements DadItemDetail<BrowserItemEntity> {
  BrowserItemNodeDadDetails(this.dadItem,
      {this.parrent, required this.setStateParrent})
      : assert((parrent != null || dadItem is DadRootList),
            '[parrent] can be null only if item is [DadRootList]');

  @override
  IDadItem<BrowserItemEntity> dadItem;

  @override
  IDadList<BrowserItemEntity>? parrent;

  @override
  DadWidgetSetStateWrapper setStateParrent;

  @override
  List<Object?> get props => [dadItem];
}


// ignore: must_be_immutable
class BrowserItemNodeDad extends Equatable
    implements
        IDadItem<BrowserItemEntity>,
        DadExpansionList<BrowserItemEntity> {
  BrowserItemNodeDad(this.title,
      {required BrowserItemEntity this.item,
      this.children = const []});
  @override
  List<IDadItem<BrowserItemEntity>> children;

  @override
  bool get isExpanded => (item as FolderEntity).isExpanded;
  @override
  set isExpanded(bool value) {
    (item as FolderEntity).isExpanded = value;
  }

  @override
  String title;

  @override
  BrowserItemEntity? item;

  @override
  List<Object?> get props => [item, children];
}
