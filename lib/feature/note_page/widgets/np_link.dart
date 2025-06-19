import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_tree/feature/note_page/bloc/note_bloc.dart';
import 'package:object_tree/feature/note_page/widgets/np_link_item.dart';
import 'package:object_tree/i18n/strings.g.dart';

/// const List<int> linkType = [1, 2];
List<String> linkTitles = [
  t.note_drawer.backLinked_notes,
  t.note_drawer.forwardLink_notes
];

class NpLink extends StatelessWidget {
  const NpLink({super.key, required this.linkType});

  final int linkType;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<NoteBloc>(context);
    if (linkType == 0) {
      bloc.add(NoteLoadBackLinkedNotesFromDb());
    } else {
      bloc.add(NoteLoadForwardLinkedNotesFromDb());
    }

    return BlocBuilder<NoteBloc, NoteState>(
      buildWhen: (previous, current) {
        if(current is NoteLoadedContent){
          return true;
        }
        if (linkType == 0) {
          return current is NoteLoadedBackLinkedList;
        } else {
          return current is NoteLoadedForwardLinkedList;
        }
      },
      builder: (context, state) {
        if (state is NoteLoadedLinks) {
          return NpLinkItem(
            linkType: linkType,
            notes: state.notes,
          );
        }

        return ExpansionTile(
          title: Text(linkTitles[linkType]),
          tilePadding: EdgeInsets.zero,
          childrenPadding:
              const EdgeInsetsDirectional.only(start: 20, top: 0, bottom: 0),
          minTileHeight: 15,
        );
      },
    );
  }
}
