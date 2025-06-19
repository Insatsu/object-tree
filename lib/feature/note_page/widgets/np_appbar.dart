import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/general/general.dart';
import 'package:object_tree/feature/note_page/bloc/note_bloc.dart';
import 'package:talker_flutter/talker_flutter.dart';

class NotePageAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NotePageAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    GetIt.I<Talker>().debug(
        "build appbar: ${BlocProvider.of<NoteBloc>(context).noteRepository!.relativePath}");
    bool isRawFormated = true;

    return BlocBuilder<NoteBloc, NoteState>(
      buildWhen: (previous, current) => switch(current){
        NoteChangedTitile() || NoteLoadedContent() || NoteTitleFailure() => true,
        _ => false,
      },
      builder: (context, state) {
        return AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.menu,
            ),
            onPressed: () {
              GenTestDrawer.maybeOf(context)?.open();
            },
          ),
          titleTextStyle: TextStyle(
              fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          title: Text(
            BlocProvider.of<NoteBloc>(context).noteRepository!.relativePath,
          ),
          centerTitle: true,
          actions: [
            BlocProvider.of<NoteBloc>(context).noteRepository!.contentType
                    is NoteContentText
                ? StatefulBuilder(builder: (context, setState) {
                    return IconButton(
                        onPressed: () {
                          isRawFormated
                              ? BlocProvider.of<NoteBloc>(context)
                                  .add(const NoteChangeFormatToMd())
                              : BlocProvider.of<NoteBloc>(context)
                                  .add(const NoteChangeFormatToRaw());
                          isRawFormated = !isRawFormated;
                          setState(() {});
                        },
                        icon: isRawFormated
                            ? const Icon(Icons.visibility_outlined)
                            : const Icon(Icons.visibility_off_outlined));
                  })
                : SizedBox.shrink()
          ],
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(APPBAR_HEIGHT);
}
