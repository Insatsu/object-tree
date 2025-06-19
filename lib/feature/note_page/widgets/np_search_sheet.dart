import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/feature/note_page/note_page.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NpSearchSheet extends StatefulWidget {
  const NpSearchSheet({super.key, required this.bloc});

  final NoteBloc bloc;

  @override
  State<NpSearchSheet> createState() => _NpSearchSheetState();
}

class _NpSearchSheetState extends State<NpSearchSheet> {
  bool shouldUpdateOnBuild = true;

  @override
  void didUpdateWidget(covariant NpSearchSheet oldWidget) {
    shouldUpdateOnBuild = false;
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return GenSearchBtmModal(
      searchListener: (word) =>
          widget.bloc.add(NoteSearchListWord(words: word)),
      searchResults: BlocBuilder<BrowserBloc, BrowserState>(
        bloc: GetIt.I<BrowserBloc>(),
        buildWhen: (previous, current) => current is! BrowserUpdatedLinks,
        builder: (context, state) {
          if (shouldUpdateOnBuild) {
            noteBlocLoads();
          } else {
            shouldUpdateOnBuild = true;
          }

          return BlocBuilder<NoteBloc, NoteState>(
            bloc: widget.bloc,
            buildWhen: (previous, current) => current is NoteLoadedSearchList || current is NoteLinkFailure,
            builder: (context, state) {
              if(state is NoteLinkFailure){
                showNeedSnackBar();
              }

              if (state is NoteLoadedSearchList) {
                return ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      return _NpSearchListTile(
                          listTileNote: state.notes.elementAt(index),
                          noteRlPath: widget.bloc.noteRepository!.relativePath,
                          bloc: widget.bloc,
                          isAdded: state.noteRelPathsIsAdded[
                              state.notes.elementAt(index).relativePath]);
                    });
              }

              return const SizedBox();
            },
          );
        },
      ),
    );
  }
  void showNeedSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(t.note_drawer.searh_snackbar_error),
      duration:Durations.short2,
    ));
  }

  void noteBlocLoads({NoteEntity? note}) async {
    widget.bloc.notes = (await GetIt.I<INodeRepository>().getNotes())
        .map((el) => NoteEntity(relativePath: el.relativePath))
        .toList();

    widget.bloc.add(NoteLoadForwardLinkedNotesFromDb());
    widget.bloc.add(NoteLoadSearchList());
  }
}

///
///
///
class _NpSearchListTile extends StatefulWidget {
  const _NpSearchListTile(
      {super.key,
      required this.listTileNote,
      required this.noteRlPath,
      required this.bloc,
      required this.isAdded});

  final NoteEntity listTileNote;
  final String noteRlPath;
  final NoteBloc bloc;
  final bool? isAdded;

  @override
  State<_NpSearchListTile> createState() => _NpSearchListTileState();
}

class _NpSearchListTileState extends State<_NpSearchListTile> {
  final double minHeight = 20;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        minTileHeight: minHeight,
        title: Text(
          widget.listTileNote.relativePath,
          style: getTextStyle(widget.isAdded),
        ),
        onTap: () {
          addOrDelete(widget.listTileNote, widget.isAdded);
        },
        trailing: getTrailing(widget.isAdded));
  }



  /// Get needed text style depending on a note is added or not
  TextStyle? getTextStyle(bool? isAdded) {
    if (isAdded == null) {
      return null;
    }
    if (isAdded) {
      return TextStyle(color: Theme.of(context).colorScheme.primary);
    }
    return TextStyle(color: Theme.of(context).colorScheme.error);
  }

  /// Get needed trailing depending on a note is added or not
  Icon? getTrailing(bool? isAdded) {
    if (isAdded == null) {
      return null;
    }
    if (isAdded) {
      return Icon(
        Icons.thumb_up_alt_outlined,
        color: Theme.of(context).colorScheme.primary,
      );
    }
    return Icon(
      Icons.thumb_down_alt_outlined,
      color: Theme.of(context).colorScheme.error,
    );
  }

  void addOrDelete(NoteEntity note, bool? isAdded) {
    if (isAdded == null || isAdded == false) {
      noteBlocAdd(note);
      return;
    }
    noteBlocDelete(note);
  }

  void noteBlocAdd(NoteEntity note) {
    widget.bloc.add(NoteSearchListAddForwardLink(forwardLinkedNote: note));
    widget.bloc.add(NoteLoadForwardLinkedNotesFromDb());
  }

  void noteBlocDelete(NoteEntity note) {
    widget.bloc.add(NoteSearchListDeleteForwardLink(forwardLinkedNote: note));
    widget.bloc
        .add(NoteDeleteForwardLinkedNoteFromDb(noteTo: widget.listTileNote));
  }
}
