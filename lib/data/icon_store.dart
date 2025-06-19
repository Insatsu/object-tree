import 'package:flutter/material.dart';

class IconsStore {
  const IconsStore({this.size});

  final double? size;

  Icon openFolder() {
    return Icon(
      Icons.folder_open_outlined,
      size: size,
    );
  }

  Icon closedFolder() {
    return Icon(
      Icons.folder,
      size: size,
    );
  }

  Icon file() {
    return Icon(
      Icons.text_snippet_outlined,
      size: size,
    );
  }

  Icon emptyFolder() {
    return Icon(
      Icons.folder_off_outlined,
      size: size,
    );
  }
}
