import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:object_tree/data/data.dart';
import 'package:object_tree/domain/repositories/i_node_repository.dart';
import 'package:object_tree/feature/general/gen_test_drawer.dart';
import 'package:object_tree/feature/general/root_bottom_nav_bar.dart';
import 'package:object_tree/feature/note_page/bloc/note_bloc.dart';
import 'package:object_tree/feature/note_page/widgets/widgets.dart';



class NotePage extends StatefulWidget {
  const NotePage({super.key, required this.notesRelativePath});
  final String notesRelativePath;

  @override
  State<NotePage> createState() => _NotePageState();
}

class _NotePageState extends State<NotePage> {
  late NoteBloc _noteBloc;
  final GlobalKey _contentKey = GlobalKey();
  final GlobalKey _myDrawerKey = GlobalKey<GenTestDrawerState>();

  @override
  void initState() {
    _noteBloc = NoteBloc(
        dbProvider: GetIt.I<INodeRepository>().db,
        nodeRepository: GetIt.I<INodeRepository>());

    _noteBloc.noteRepository = NoteRepository(
        relativePath: widget.notesRelativePath,
        path: GetIt.I<INodeRepository>().path);

    _noteBloc.add(const NoteLoadContent());

    super.initState();
  }

  @override
  void didUpdateWidget(covariant NotePage oldWidget) {
    if (oldWidget.notesRelativePath != widget.notesRelativePath) {
      _noteBloc.noteRepository = NoteRepository(
          relativePath: widget.notesRelativePath,
          path: GetIt.I<INodeRepository>().path);

      _noteBloc.add(const NoteInit());
      _noteBloc.add(const NoteLoadContent());
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => _noteBloc,
      child: BlocBuilder<NoteBloc, NoteState>(
        buildWhen: (previous, current) => current is NoteInitial,
        builder: (context, state) {

          return GenTestDrawer(
            key: _myDrawerKey,
            drawer: NPDrawer(),
            content: _DrawerContent2(key: _contentKey,)
          );
        },
      ),
    );
  }
}

class _DrawerContent2 extends StatelessWidget {
  const _DrawerContent2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: NotePageAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: CustomScrollView(physics: ScrollPhysics(), slivers: [
          SliverToBoxAdapter(
            child: const NpbTitle(),
          ),

          SliverFillRemaining(
            hasScrollBody: false,
            child: SizedBox.expand(child: const NpContent()),
          ),
        ]),
      ),
      bottomNavigationBar: RootNavBarClassic(
          pageIndex: 0,
          navigationShell: StatefulNavigationShell.of(context).widget),
    );
  }
}
