import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RootPage extends StatefulWidget {
  const RootPage({required this.navigationShell, Key? key})
      : super(
            key: key ?? const ValueKey<String>('ScaffoldBottomNavigationBar'));

  // * value of go_router for navigation
  final StatefulNavigationShell navigationShell;

  @override
  State<RootPage> createState() => _RootPageState();
}

class _RootPageState extends State<RootPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // resizeToAvoidBottomInset: true,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: LayoutBuilder(
          builder: (context, constraits) {
            return widget.navigationShell;
          }
        )),
    );
  }
}
