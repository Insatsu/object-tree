import 'dart:math';

import 'package:flutter/material.dart';
import 'package:object_tree/i18n/strings.g.dart';

class GenDrawer extends StatelessWidget {
  const GenDrawer(
      {super.key,
      Widget? drawerHead,
      required this.drawerExpandedBody,
      required this.drawerFooter,
      this.width,
      this.isLeft = true,
      this.drawerPadding,
      this.drawerExpandedBodyPadding})
      : drawerHead = drawerHead ?? const _GenDefaultDrawerHead();

  final Widget drawerHead;
  final Widget drawerExpandedBody;
  final Widget drawerFooter;
  final double? width;
  final EdgeInsetsGeometry? drawerPadding;
  final EdgeInsetsGeometry? drawerExpandedBodyPadding;
  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      left: false,
      right: false,
      child: Container(
          height: double.infinity,
          width: width ?? min(MediaQuery.of(context).size.width * 0.9, 304),
          decoration: ShapeDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: isLeft ? const BorderRadius.only(
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20)) 
                  : const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
          ),
          padding: drawerPadding ?? const EdgeInsets.only(bottom: 5, top: 5),
          child: SafeArea(
            top: true,
            child: Column(
              children: [
                // * Text "Actions"
                drawerHead,
                // * Main drawer content
                Expanded(
                  child: Padding(
                    padding: drawerExpandedBodyPadding ??
                        const EdgeInsetsDirectional.only(end: 10, start: 12, top: 10),
                    child: drawerExpandedBody,
                  ),
                ),
                // * Footer part
                drawerFooter
              ],
            ),
          )),
    );
  }
}

class _GenDefaultDrawerHead extends StatelessWidget {
  const _GenDefaultDrawerHead();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Text(
            t.browser_drawer.header,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          // * Divider
          Padding(
            padding: EdgeInsets.only(top: 10, right: 16, left: 16),
            child: const Divider(),
          ),
        ],
      ),
    );
  }
}
