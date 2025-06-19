import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:object_tree/data/entities/note_entity.dart';
import 'package:object_tree/data/model/db_model.dart';
import 'package:object_tree/feature/general/gen_drawer.dart';
import 'package:object_tree/feature/general/gen_searchbar.dart';
import 'package:object_tree/feature/notes_tree/bloc/nt_bloc.dart';
import 'package:object_tree/i18n/strings.g.dart';

class NtEnddrawer extends StatefulWidget {
  const NtEnddrawer({super.key});

  @override
  State<NtEnddrawer> createState() => _NtEnddrawerState();
}

class _NtEnddrawerState extends State<NtEnddrawer> {
  bool _isSearchMode = false;

  @override
  Widget build(BuildContext context) {
    return GenDrawer(
      drawerExpandedBodyPadding: EdgeInsetsDirectional.zero,
      isLeft: false,
      drawerExpandedBody: AnimatedSwitcher(
          duration: Durations.short3,
          child: !_isSearchMode
              ? _NtEndDrawerFirst(
                  key: ValueKey(1),
                  onSearchTap: () {
                    setState(() {
                      _isSearchMode = true;
                    });
                  },
                )
              : _NtEndDrawerSecond(
                  key: ValueKey(2),
                  onSearchTap: () {
                    setState(() {
                      _isSearchMode = false;
                    });
                  },
                )),
      drawerFooter: SizedBox.shrink(),
    );
  }
}

/// Present search bar with its result
/// Show notes
class _NtEndDrawerSecond extends StatelessWidget {
  const _NtEndDrawerSecond({
    super.key,
    required this.onSearchTap,
  });
  final void Function() onSearchTap;

  @override
  Widget build(BuildContext context) {
    BlocProvider.of<NtBloc>(context).add(NtLoadSearchList(word: ""));

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 5, top: 18),
      child: Column(
        children: [
          LayoutBuilder(builder: (context, constrait) {
            return SizedBox(
                height: 40,
                width: constrait.maxWidth,
                child: Row(
                  children: [
                    Flexible(
                        flex: 9,
                        child: GenSearchbar(searchListener: (word) {
                          BlocProvider.of<NtBloc>(context)
                              .add(NtLoadSearchList(word: word));
                        })),
                    Flexible(
                      flex: 1,
                      child: GestureDetector(
                        onTap: onSearchTap,
                        child: SizedBox(
                          height: double.infinity,
                          child: Icon(
                            Icons.exit_to_app_outlined,
                          ),
                        ),
                      ),
                    )
                  ],
                ));
          }),
          Expanded(
            child: BlocBuilder<NtBloc, NtState>(
              buildWhen: (previous, current) => current is NtSearchListLoaded,
              builder: (context, state) {
                if (state is NtSearchListLoaded) {
                  return ListView.builder(
                    itemCount: state.nodes.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(state.nodes.elementAt(index)),
                        onTap: () {
                          BlocProvider.of<NtBloc>(context).add(NtLoadRelative(
                              note: DbNote.relativePath(
                                  relativePath: state.nodes.elementAt(index))
                              ));
                        },
                      );
                    },
                  );
                }
                return SizedBox.shrink();
              },
            ),
          )
        ],
      ),
    );
  }
}

class _NtEndDrawerFirst extends StatelessWidget {
  const _NtEndDrawerFirst({
    super.key,
    required this.onSearchTap,
  });

  final void Function() onSearchTap;

  @override
  Widget build(BuildContext context) {
    final Color emptyHistoryTextColor = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10, start: 12, top: 10),
      child: Column(children: [
        // Search
        ListTile(
          contentPadding: EdgeInsets.only(left: 5),
          title: Text(t.note_tree_drawer.search_menu),
          trailing: Icon(Icons.search),
          onTap: onSearchTap,
        ),
        // Global tree
        Material(
          child: InkWell(
            child: ListTile(
              contentPadding: EdgeInsets.only(left: 5),
              title: Text(t.note_tree_drawer.show_all),
              onTap: () => BlocProvider.of<NtBloc>(context).add(NtLoadAll()),
            ),
          ),
        ),
        // History
        BlocBuilder<NtBloc, NtState>(
          buildWhen: (previous, current) =>
              current is NtLoaded || current is NtSorted,
          builder: (context, state) {
            final historyNotes = BlocProvider.of<NtBloc>(context)
                .relativeNotesHistory
                .map((el) => NoteEntity(relativePath: el.relativePath))
                .toList();
            return ExpansionTile(
                title: Text(t.note_tree_drawer.history),
                tilePadding: EdgeInsets.only(left: 5),
                subtitle: historyNotes.isEmpty
                    ? Text(
                        t.note_tree_drawer.history_empty,
                        style: TextStyle(color: emptyHistoryTextColor),
                      )
                    : null,
                children: List<Widget>.generate(historyNotes.length, (index) {
                  return ListTile(
                    key: ValueKey(historyNotes.elementAt(index)),
                    title: Text(historyNotes.elementAt(index).relativePath),
                    onTap: () => BlocProvider.of<NtBloc>(context).add(
                        NtLoadRelative(
                            note: DbNote.relativePath(
                                relativePath:
                                    historyNotes.elementAt(index).relativePath)

                            )),
                  );
                }));
          },
        ),
      ]),
    );
  }
}
