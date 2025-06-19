import 'package:flutter/material.dart';

class GenSearchbar extends StatefulWidget {
  const GenSearchbar({super.key, required this.searchListener});
  final void Function(String) searchListener;

  @override
  State<GenSearchbar> createState() => _GenSearchbarState();
}

class _GenSearchbarState extends State<GenSearchbar> {
  final TextEditingController _controller = TextEditingController();
  late Color searchBorderColor;

  void _listener() {
    widget.searchListener(_controller.text);
  }

  @override
  void initState() {
    // Set listener on textField controller
    _controller.addListener(_listener);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    searchBorderColor = Theme.of(context).colorScheme.onSurface;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: SearchBar(
        padding:
            const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10)),
        leading: const Icon(Icons.search),
        backgroundColor: WidgetStatePropertyAll(
            Theme.of(context).colorScheme.surfaceContainer),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            side: BorderSide(color: searchBorderColor),
            borderRadius: BorderRadius.circular(5))),
        controller: _controller,
        
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_listener);
    _controller.dispose();
    super.dispose();
  }
}
