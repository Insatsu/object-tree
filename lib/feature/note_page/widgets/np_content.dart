import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:object_tree/domain/domain.dart';
import 'package:object_tree/feature/note_page/bloc/note_bloc.dart';
import 'package:object_tree/feature/note_page/np_markdown_sheet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path/path.dart' as p;

class NpContent extends StatefulWidget {
  const NpContent({super.key});

  @override
  State<NpContent> createState() => _NpContentState();
}

class _NpContentState extends State<NpContent> {
  final _controller = TextEditingController();
  final _contentFocus = FocusNode();
  final _mdKey = GlobalKey();
  Timer? timer;
  NoteBloc? noteBloc;

  @override
  Widget build(BuildContext context) {
    _controller.addListener(() => fieldListener(context));
    final screenWidth = MediaQuery.of(context).size.width;
    noteBloc = BlocProvider.of<NoteBloc>(context);

    return Padding(
      padding: const EdgeInsets.only(left: 5.0, right: 5, top: 10),
      child: BlocConsumer<NoteBloc, NoteState>(
        listener: (context, state) {
          if (state is NoteLoadedTextContent) {
            _controller.text = state.content;
          }
        },
        buildWhen: (previous, current) {
          return switch (current) {
            NoteContentFailure() ||
            NoteLoadedTextContent() ||
            NoteLoadedMediaContent() ||
            NoteLoadingContent() ||
            NoteMdContent() ||
            NoteRawContent() =>
              true,
            _ => false
          };
        },
        builder: (context, state) {
          if (state is NoteContentFailure) {
            return Center(
              child: Icon(
                Icons.error_outline,
                size: 60,
              ),
            );
          }

          // * If content is image just show it
          if (noteBloc?.noteRepository!.contentType is NoteContentMedia) {
            return MarkdownBody(
              shrinkWrap: true,
              data: "![](${noteBloc!.noteRepository!.relativePath})",
              imageDirectory: "${noteBloc!.noteRepository!.path}${p.separator}",
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
            );

          }

          // * Else
          if (state is NoteMdContent) {
            return MarkdownBody(
              key: _mdKey,
              shrinkWrap: true,
              data: _controller.text,
              imageDirectory: "${noteBloc?.noteRepository!.path}${p.separator}",
              styleSheet: NpMarkdownSheet(Theme.of(context), screenWidth),
              selectable: true,
              checkboxBuilder: (isCheck) {
                return SizedBox.square(
                  dimension: 28,
                  child: Checkbox.adaptive(
                    value: isCheck,
                    onChanged: (value) {},
                  ),
                );
              },
              onTapLink: (text, href, title) {
                // [<title>](<href> "<title>")
                _onTapLink(href);
              },
            );
          }

          return TextField(
            focusNode: _contentFocus,
            autofillHints: [],
            maxLines: null,
            minLines: null,
            scrollPhysics: NeverScrollableScrollPhysics(),
            style: Theme.of(context).textTheme.bodyLarge!,
            controller: _controller,
          );
        },
      ),
    );
  }

  void _onTapLink(String? href) {
    if (href == null) {
      return;
    }

    if (href.startsWith('https') || href.startsWith('http')) {
      launchUrl(Uri.parse(href), mode: LaunchMode.externalApplication);
      return;
    }
  }

  void fieldListener(BuildContext context) {
    timer?.cancel();
    timer = Timer(const Duration(seconds: 15), () {
      BlocProvider.of<NoteBloc>(context)
          .add(NoteSaveContent(newContent: _controller.text));
    });
  }

  @override
  void dispose() {
    // * Save if content is text (inner logic)
    noteBloc?.add(NoteSaveContent(newContent: _controller.text));
    _controller.dispose();
    timer?.cancel();

    super.dispose();
  }
}

/// Baseline wrapper
/// (not used)
// ignore: unused_element
class _CheckboxBaselineWrapper extends SingleChildRenderObjectWidget {
  const _CheckboxBaselineWrapper({Key? key, Widget? child})
      : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _CheckboxBaselineRenderObject();
  }
}

class _CheckboxBaselineRenderObject extends RenderProxyBox {
  @override
  double? computeDryBaseline(
      covariant BoxConstraints constraints, TextBaseline baseline) {
    return constraints.maxWidth;
  }
}
