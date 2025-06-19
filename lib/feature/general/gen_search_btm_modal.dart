import 'package:flutter/material.dart';
import 'package:object_tree/feature/general/gen_searchbar.dart';

class GenSearchBtmModal extends StatelessWidget {
  const GenSearchBtmModal({
    super.key,
    required this.searchListener,
    required this.searchResults,
  });

  final void Function(String) searchListener;
  final Widget searchResults;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // * Search widget
        GenSearchbar(searchListener: searchListener),

        // * Notes
        Expanded(child: searchResults)
      ],
    );
  }
}
