import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_browser_page/note_browser_page.dart';
import 'package:object_tree/feature/notes_tree/bloc/nt_bloc.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_appbar.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_body.dart';
import 'package:object_tree/feature/notes_tree/widgets/nt_enddrawer.dart';

class NotesTree extends StatefulWidget {
  const NotesTree({super.key});
  @override
  State<NotesTree> createState() => _NotesTreeState();
}

class _NotesTreeState extends State<NotesTree> {
  NtBloc ntBloc = NtBloc();
  final _bodyKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    ntBlocSetLoad();
  }

  @override
  Widget build(BuildContext context) {
    TreeNode.colorByType = {
      TreeNodeHeadColor(): Colors.deepOrange,
      TreeNodeChildColor(): Colors.cyanAccent,
      TreeNodeDefaultColor(): Colors.deepPurpleAccent,
    };

    return BlocProvider<NtBloc>(
      create: (context) => ntBloc,
      child: BlocListener<RootBloc, RootState>(
        bloc: GetIt.I<RootBloc>(),
        listener: (context, state) {},
        child: BlocListener<BrowserBloc, BrowserState>(
          bloc: GetIt.I<BrowserBloc>(),
          listener: (context, state) {
            if (state is BrowserUpdatedTree) {
              ntBlocSetLoadWith(state.note);
            }
            if (state is BrowserLoaded || state is BrowserUpdatedLinks) {
              ntBloc.add(NtUpdateTree());
            }
          },
          child: Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: const NtAppBar(),
            endDrawer: NtEnddrawer(),
            endDrawerEnableOpenDragGesture: false,
            body: NtBody(
              key: _bodyKey,
            ),
            bottomNavigationBar: RootNavBarClassic(
              pageIndex: 1,
              navigationShell: StatefulNavigationShell.of(context).widget,
            ),
          ),
        ),
      ),
    );
  }

  void ntBlocSetLoad() {
    ntBloc.add(NtLoadAll());
  }

  void ntBlocSetLoadWith(DbNote note) {
    ntBloc.add(NtLoadRelative(note: note));
  }
}
