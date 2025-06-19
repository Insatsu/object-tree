import 'package:flutter/material.dart';
import 'package:object_tree/core/constants.dart';

const mainColor = Colors.teal;

final classicTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorSchemeSeed: mainColor,
    // * Navigation bar
    navigationBarTheme: const NavigationBarThemeData(
        indicatorShape: StadiumBorder(
            side: BorderSide(
                color: Colors.teal,
                strokeAlign: BorderSide.strokeAlignOutside,
                width: 0.5)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 55,
        iconTheme: WidgetStatePropertyAll(IconThemeData(
          size: 25,
        ))),
    // * Search
    searchBarTheme: SearchBarThemeData(
      elevation: WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          side: BorderSide(), borderRadius: BorderRadius.circular(5))),
    ),
    // * Text Button
    textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
      alignment: Alignment.centerLeft,
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 0)),
      iconSize: WidgetStatePropertyAll(30),
      shape: WidgetStatePropertyAll(LinearBorder.none),
    )),
    // * Expansion Tile
    expansionTileTheme: const ExpansionTileThemeData(
      childrenPadding: EdgeInsetsDirectional.only(start: 15),
      shape: LinearBorder(
        side: BorderSide(
            width: 1,
            color: Colors.teal,
            strokeAlign: BorderSide.strokeAlignInside),
        start: LinearBorderEdge(),
        top: LinearBorderEdge(size: 0.01, alignment: -1.0),
      ),
    ),
    // * Text
  
    // * TextField
    inputDecorationTheme: InputDecorationTheme(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.zero,
        filled: false),
    // * Appbar
    appBarTheme: const AppBarTheme(
        toolbarHeight: APPBAR_HEIGHT));

final classicThemeLight = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorSchemeSeed: mainColor,

    // * Navigation bar
    navigationBarTheme: const NavigationBarThemeData(
        indicatorShape: StadiumBorder(
            side: BorderSide(
                color: Colors.teal,
                strokeAlign: BorderSide.strokeAlignOutside,
                width: 0.5)),
        labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        height: 55,
        iconTheme: WidgetStatePropertyAll(IconThemeData(
          size: 25,
        ))),
    // * Search
    searchBarTheme: SearchBarThemeData(
      elevation: WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          side: BorderSide(), borderRadius: BorderRadius.circular(5))),
    ),
    // * Text Button
    textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
      alignment: Alignment.centerLeft,
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 0)),
      iconSize: WidgetStatePropertyAll(30),
      shape: WidgetStatePropertyAll(LinearBorder.none),
    )),
    // * Expansion Tile
    expansionTileTheme: const ExpansionTileThemeData(
      childrenPadding: EdgeInsetsDirectional.only(start: 15),
      shape: LinearBorder(
        side: BorderSide(
            width: 1,
            color: Colors.teal,
            strokeAlign: BorderSide.strokeAlignInside),
        start: LinearBorderEdge(),
        top: LinearBorderEdge(size: 0.01, alignment: -1.0),
      ),
    ),

    // * TextField
    inputDecorationTheme: InputDecorationTheme(
      isDense: true,
      border: InputBorder.none,
      contentPadding: EdgeInsets.zero,
      filled: false,
    ),
    // * Appbar
    appBarTheme: const AppBarTheme(
        toolbarHeight: APPBAR_HEIGHT));
