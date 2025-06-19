import 'package:flutter/material.dart';

class DadTitleWidget extends StatelessWidget {
  const DadTitleWidget({required this.title, super.key, this.style});

  final String title;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: style ??
          TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
              decoration: TextDecoration.none),
    );
  }
}
