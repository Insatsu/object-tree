import 'package:flutter/material.dart';
import 'package:object_tree/feature/general/bloc/root_bloc.dart';
import 'package:object_tree/i18n/strings.g.dart';

class SwitchAppTheme extends StatefulWidget {
  const SwitchAppTheme({super.key, required this.bloc});

  final RootBloc bloc;

  @override
  State<SwitchAppTheme> createState() => _SwitchAppThemeState();
}

class _SwitchAppThemeState extends State<SwitchAppTheme> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          widget.bloc.isDarkTheme
              ? t.browser_drawer.change_theme_ligth
              : t.browser_drawer.change_theme_dark,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        const Spacer(),
        Switch(
            value: widget.bloc.isDarkTheme,
            onChanged: (bool value) {
              setState(() {
                widget.bloc.add(widget.bloc.isDarkTheme
                    ? const RootSetLightTheme()
                    : const RootSetDarkTheme());
              });
            })
      ],
    );
  }
}
