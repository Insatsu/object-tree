import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get_it/get_it.dart';
import 'package:object_tree/core/constants.dart';
import 'package:object_tree/feature/note_page/note_page.dart';
import 'package:object_tree/i18n/strings.g.dart';
import 'package:talker_flutter/talker_flutter.dart';
import 'package:path/path.dart' as p;

class NpbTitle extends StatefulWidget {
  const NpbTitle({super.key});

  @override
  State<NpbTitle> createState() => _NpbTitleState();
}

class _NpbTitleState extends State<NpbTitle> {
  final _controller = TextEditingController();
  final _titleFocusNode = FocusNode();
  final _titleKey = GlobalKey();

  late StreamSubscription<bool> _keyboardSubscription;

  OverlayEntry? _errorMessage;

  bool _isExclusiveName = true;

  /// Saves the new title from [TextFile]
  ///
  /// If title is empty set default value
  ///
  /// Also check title on exclusive and makes it so if not
  void saveTitle() {
    hideError();
    BlocProvider.of<NoteBloc>(context)
        .add(NoteChangeTitle(title: _controller.text));
  }

  /// Get exclusive title and set [_isExclusiveName] to true
  String getExclusiveTitle() {
    var result = BlocProvider.of<NoteBloc>(context)
        .noteRepository!
        .getExclusiveTitle(_controller.text);
    _isExclusiveName = true;
    return result;
  }

  /// Check is title is exclusive and set it value in [_isExclusiveName]
  bool isExclusive() {
    if (BlocProvider.of<NoteBloc>(context)
        .noteRepository!
        .isExclusiveNotesTitle(_controller.text)) {
      _isExclusiveName = true;
    } else {
      _isExclusiveName = false;
    }
    return _isExclusiveName;
  }

  // ===============================================================
  // ===============================================================
  // Overrides
  /// Set text controller, listener on it
  /// Set keyboard change listener that saves title and unfocus if keyboard hides
  @override
  void initState() {
    _controller.addListener(controllerTextListener);

    _controller.text = BlocProvider.of<NoteBloc>(context).noteRepository!.title;

    _titleFocusNode.addListener(focusNodeListener);
    // * =====================================================================
    // * Keyboard listner
    var keyboardVisibilityController = KeyboardVisibilityController();

    // * Subscribe
    _keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      GetIt.I<Talker>()
          .debug('Keyboard visibility update. Is visible: $visible');

      // * Unfocus if keyboard is not visible
      if (!visible) _titleFocusNode.unfocus();

      saveTitle();
    });
    // * =====================================================================

    super.initState();
  }
  // ===============================================================
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NoteBloc, NoteState>(
      listener: (context, state) {
        if (state is NoteInclusiveTitleFailure) {
          _isExclusiveName = false;
          showError(t.note_content.title_snackbar_dublicate);
          _controller.selection = TextSelection(
              baseOffset: _controller.text.length,
              extentOffset: _controller.text.length);
        }
        if (state is NoteBadTitleFailure) {
          _controller.text =
              BlocProvider.of<NoteBloc>(context).noteRepository!.title;
          showError(t.note_content.ban_symbol_item_title);
          _controller.selection = TextSelection(
              baseOffset: _controller.text.length,
              extentOffset: _controller.text.length);
        }

        if (state is NoteChangedTitile) {
          _controller.text = state.newTitle;
          _controller.selection = TextSelection(
              baseOffset: _controller.text.length,
              extentOffset: _controller.text.length);
        }

        if (state is NoteInitial) {
          _controller.text =
              BlocProvider.of<NoteBloc>(context).noteRepository!.title;
        }

        /// If an error has occurred show message about it
        if (state is NoteContentFailure) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(t.note_content.title_snackbar_error),
            duration: Durations.extralong4,
            showCloseIcon: true,
            behavior: SnackBarBehavior.floating,
          ));
        }
      },
      buildWhen: (previous, current) {
        return current is NoteChangedTitile || current is NoteTitleFailure;
      },
      builder: (context, state) {
        return TextField(
          key: _titleKey,
          contextMenuBuilder: (context, editableTextState) {
            return AdaptiveTextSelectionToolbar.buttonItems(
                buttonItems: editableTextState.contextMenuButtonItems,
                anchors: editableTextState.contextMenuAnchors);
          },
          focusNode: _titleFocusNode,
          controller: _controller,
          maxLines: 1,
          autocorrect: false,
          decoration: InputDecoration(
            contentPadding: EdgeInsetsDirectional.only(start: 0),
          ),
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
          onChanged: (value) {
            if (_controller.text.isEmpty) {
              showError(t.note_content.title_empty);
              return;
            }
            if (!isExclusive()) {
              showError(t.note_content.title_snackbar_dublicate);
            } else {
              hideError();
            }
          },
        );
      },
    );
  }

  /// Show tooltip with error message if title is already used
  ///
  void showError(String message) {
    hideError();

    _errorMessage = OverlayEntry(
      builder: (context) {
        final titleRenderBox =
            _titleKey.currentContext?.findRenderObject() as RenderBox?;

        // Work with safeArea. 
        // A problem was that [MediaQuery] return full screen size, but [titleRenderBox] has offset
        // about safeArea body size
        final scaffoldTopPadding = MediaQuery.paddingOf(
                context.findAncestorStateOfType<ScaffoldState>()!.context)
            .top;

        final titleOffset =
            titleRenderBox?.localToGlobal(Offset(0, -scaffoldTopPadding)) ??
                Offset.zero;

        return Positioned(
          left: titleOffset.dx,
          top: titleOffset.dy + titleRenderBox!.size.height + 10,
          // top: titleOffset.dy,
          child: Material(
            color: Colors.white.withAlpha(0),
            child: SizedBox(
              width: titleRenderBox.size.width,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text(
                    message,
                    style: Theme.of(context)
                        .typography
                        .black
                        .bodyLarge
                        ?.copyWith(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                        ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    Overlay.of(context).insert(_errorMessage!);
  }

  /// Hide tooltip with error message
  void hideError() {
    _errorMessage?.remove();
    _errorMessage = null;
  }

  void focusNodeListener() {
    if (_titleFocusNode.hasFocus) {
      return;
    }

    saveTitle();
  }

  /// Change controller text if it invalid
  ///
  /// Ivalid text:
  ///  1. starts with '.'
  ///  2. 1^ and length > 2  ->  remove '.'
  ///  3. 1^ and lenght <= 2 ->  rename to default title
  void controllerTextListener() {
    if (!_controller.text.startsWith('.')) return;

    if (_controller.text.length > 2) {
      _controller.text = _controller.text.substring(1);
    } else {
      _controller.text = p.withoutExtension(NOTE_TITLE_WITH_EXTANSION_DEFAULT);
      _controller.text = getExclusiveTitle();
    }
  }

  // ===============================================================
  // ===============================================================
  // Overrides
  @override
  void deactivate() {
    saveTitle();

    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _controller.removeListener(controllerTextListener);
    _keyboardSubscription.cancel();
    _titleFocusNode.removeListener(focusNodeListener);
    _titleFocusNode.unfocus();
    _titleFocusNode.dispose();
    super.dispose();
  }
  // ===============================================================
  // ===============================================================
}
