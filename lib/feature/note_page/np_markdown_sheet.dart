import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class NpMarkdownSheet extends MarkdownStyleSheet {
  NpMarkdownSheet(ThemeData theme, double screenWidth)
      : super(
          a: TextStyle(color: theme.colorScheme.primary),
          p: theme.textTheme.bodyLarge,
          pPadding: EdgeInsets.zero,
          code: theme.textTheme.bodyLarge!.copyWith(
            backgroundColor: theme.cardTheme.color,
            fontFamily: 'monospace',
            fontSize: theme.textTheme.bodyLarge!.fontSize! * 0.85,
          ),
          h1: theme.textTheme.headlineMedium,
          h1Padding: EdgeInsets.zero,
          h2: theme.textTheme.headlineSmall,
          h2Padding: EdgeInsets.zero,
          h3: theme.textTheme.titleLarge,
          h3Padding: EdgeInsets.zero,
          h4: theme.textTheme.titleMedium,
          h4Padding: EdgeInsets.zero,
          h5: theme.textTheme.titleMedium,
          h5Padding: EdgeInsets.zero,
          h6: theme.textTheme.titleMedium,
          h6Padding: EdgeInsets.zero,
          em: const TextStyle(fontStyle: FontStyle.italic),
          strong: const TextStyle(fontWeight: FontWeight.bold),
          del: const TextStyle(decoration: TextDecoration.lineThrough),
          blockquote: theme.textTheme.bodyLarge!
              .copyWith(color: theme.colorScheme.onTertiaryContainer),
          img: theme.textTheme.bodyLarge,
          checkbox: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.primary,
          ),
          blockSpacing: 8.0,
          listIndent: 24.0,
          listBullet: theme.textTheme.bodyLarge,
          listBulletPadding: const EdgeInsets.only(right: 4),
          tableHead: const TextStyle(fontWeight: FontWeight.w600),
          tableBody: theme.textTheme.bodyLarge,
          tableHeadAlign: TextAlign.center,
          tablePadding: const EdgeInsets.only(bottom: 4.0),
          tableBorder: TableBorder.all(
            color: theme.colorScheme.onSurface,
          ),
          // tableColumnWidth: const IntrinsicColumnWidth(flex: 1),
          tableColumnWidth: MinColumnWidth(FixedColumnWidth(screenWidth*0.8), const IntrinsicColumnWidth()),
          // tableColumnWidth: const FixedColumnWidth(200),
          tableCellsPadding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          tableCellsDecoration: const BoxDecoration(),
          blockquotePadding: const EdgeInsets.all(8.0),
          blockquoteDecoration: BoxDecoration(
            color: theme.colorScheme.tertiaryContainer,
            borderRadius: BorderRadius.circular(2.0),
          ),
          codeblockPadding: const EdgeInsets.all(8.0),
          codeblockDecoration: BoxDecoration(
            color: theme.cardTheme.color ?? theme.cardColor,
            borderRadius: BorderRadius.circular(2.0),
          ),
          horizontalRuleDecoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                width: 3.0,
                color: theme.colorScheme.secondary,
              ),
            ),
          ),

        );
}
