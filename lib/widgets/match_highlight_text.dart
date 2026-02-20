import 'package:flutter/material.dart';

class MatchHighlightText extends StatelessWidget {
  final String text;
  final List<RegExpMatch> matches;

  const MatchHighlightText({
    super.key,
    required this.text,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    if (text.isEmpty) {
      return Text(
        'Enter test string above...',
        style: TextStyle(
          color: colors.onSurfaceVariant.withValues(alpha: 0.5),
          fontFamily: 'monospace',
          fontSize: 14,
        ),
      );
    }

    if (matches.isEmpty) {
      return SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;
    final highlightColors = [
      colors.primary.withValues(alpha: 0.25),
      colors.tertiary.withValues(alpha: 0.25),
      colors.secondary.withValues(alpha: 0.25),
    ];

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];

      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
        ));
      }

      final colorIndex = i % highlightColors.length;
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          backgroundColor: highlightColors[colorIndex],
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ));

      lastEnd = match.end;
    }

    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
        children: spans,
      ),
    );
  }
}
