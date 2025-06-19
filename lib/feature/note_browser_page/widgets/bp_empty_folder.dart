import 'package:flutter/material.dart';

class BpEmptyFolder extends StatelessWidget {
  const BpEmptyFolder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentDirectional.bottomStart,
      padding: const EdgeInsets.only(left: 0),
      child: Text(
        '(Folder is empty)',
        style:
            TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}
