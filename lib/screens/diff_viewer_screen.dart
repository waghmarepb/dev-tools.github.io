import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class DiffViewerScreen extends StatefulWidget {
  const DiffViewerScreen({super.key});

  @override
  State<DiffViewerScreen> createState() => _DiffViewerScreenState();
}

class _DiffViewerScreenState extends State<DiffViewerScreen> {
  final _leftCtrl = TextEditingController();
  final _rightCtrl = TextEditingController();
  List<_DiffLine> _diffLines = [];
  bool _ignoreWhitespace = false;
  bool _ignoreCase = false;

  void _computeDiff() {
    final leftLines = _leftCtrl.text.split('\n');
    final rightLines = _rightCtrl.text.split('\n');
    
    final diff = _computeLCS(leftLines, rightLines);
    setState(() => _diffLines = diff);
  }

  List<_DiffLine> _computeLCS(List<String> left, List<String> right) {
    final result = <_DiffLine>[];
    
    final m = left.length;
    final n = right.length;
    final lcs = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    
    for (int i = 1; i <= m; i++) {
      for (int j = 1; j <= n; j++) {
        if (_linesEqual(left[i - 1], right[j - 1])) {
          lcs[i][j] = lcs[i - 1][j - 1] + 1;
        } else {
          lcs[i][j] = lcs[i - 1][j] > lcs[i][j - 1] ? lcs[i - 1][j] : lcs[i][j - 1];
        }
      }
    }
    
    int i = m, j = n;
    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && _linesEqual(left[i - 1], right[j - 1])) {
        result.insert(0, _DiffLine(
          type: _DiffType.unchanged,
          leftLine: left[i - 1],
          rightLine: right[j - 1],
          leftNumber: i,
          rightNumber: j,
        ));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || lcs[i][j - 1] >= lcs[i - 1][j])) {
        result.insert(0, _DiffLine(
          type: _DiffType.added,
          leftLine: null,
          rightLine: right[j - 1],
          leftNumber: null,
          rightNumber: j,
        ));
        j--;
      } else if (i > 0) {
        result.insert(0, _DiffLine(
          type: _DiffType.removed,
          leftLine: left[i - 1],
          rightLine: null,
          leftNumber: i,
          rightNumber: null,
        ));
        i--;
      }
    }
    
    return result;
  }

  bool _linesEqual(String a, String b) {
    String processLine(String line) {
      String result = line;
      if (_ignoreWhitespace) result = result.replaceAll(RegExp(r'\s+'), '');
      if (_ignoreCase) result = result.toLowerCase();
      return result;
    }
    return processLine(a) == processLine(b);
  }

  @override
  void dispose() {
    _leftCtrl.dispose();
    _rightCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final stats = _computeStats();

    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              border: Border(
                bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('Ignore Whitespace'),
                        selected: _ignoreWhitespace,
                        onSelected: (v) {
                          setState(() => _ignoreWhitespace = v);
                          _computeDiff();
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      FilterChip(
                        label: const Text('Ignore Case'),
                        selected: _ignoreCase,
                        onSelected: (v) {
                          setState(() => _ignoreCase = v);
                          _computeDiff();
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
                if (_diffLines.isNotEmpty) ...[
                  _buildStatChip('${stats['added']} added', Colors.green, colors),
                  const SizedBox(width: 8),
                  _buildStatChip('${stats['removed']} removed', Colors.red, colors),
                  const SizedBox(width: 8),
                  _buildStatChip('${stats['unchanged']} unchanged', colors.primary, colors),
                ],
              ],
            ),
          ),
          Expanded(
            child: _diffLines.isEmpty
                ? _buildInputMode(colors)
                : _buildDiffMode(theme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInputMode(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'ORIGINAL TEXT',
                  trailing: CopyButton(text: _leftCtrl.text),
                ),
                Expanded(
                  child: TextField(
                    controller: _leftCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Paste original text here...',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionHeader(
                  title: 'MODIFIED TEXT',
                  trailing: CopyButton(text: _rightCtrl.text),
                ),
                Expanded(
                  child: TextField(
                    controller: _rightCtrl,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Paste modified text here...',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiffMode(ThemeData theme, ColorScheme colors) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'ORIGINAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'MODIFIED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            itemCount: _diffLines.length,
            itemBuilder: (_, i) => _buildDiffLine(_diffLines[i], colors),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            border: Border(
              top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: () {
                  setState(() => _diffLines = []);
                },
                icon: const Icon(Icons.edit_rounded, size: 18),
                label: const Text('Edit Text'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _leftCtrl.clear();
                  _rightCtrl.clear();
                  setState(() => _diffLines = []);
                },
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Clear All'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiffLine(_DiffLine line, ColorScheme colors) {
    Color? bgColor;
    IconData? icon;
    Color? iconColor;

    switch (line.type) {
      case _DiffType.added:
        bgColor = Colors.green.withValues(alpha: 0.1);
        icon = Icons.add_circle_outline;
        iconColor = Colors.green.shade700;
        break;
      case _DiffType.removed:
        bgColor = Colors.red.withValues(alpha: 0.1);
        icon = Icons.remove_circle_outline;
        iconColor = Colors.red.shade700;
        break;
      case _DiffType.unchanged:
        bgColor = null;
        icon = null;
        iconColor = null;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: bgColor,
        border: line.type != _DiffType.unchanged
            ? Border(
                left: BorderSide(
                  color: iconColor ?? colors.outline,
                  width: 3,
                ),
              )
            : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (line.leftNumber != null)
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${line.leftNumber}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const SizedBox(width: 8),
                  if (icon != null && line.type == _DiffType.removed)
                    Icon(icon, size: 14, color: iconColor),
                  if (icon != null && line.type == _DiffType.removed)
                    const SizedBox(width: 6),
                  Expanded(
                    child: SelectableText(
                      line.leftLine ?? '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: line.leftLine == null
                            ? colors.onSurfaceVariant.withValues(alpha: 0.3)
                            : null,
                        decoration: line.type == _DiffType.removed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (line.rightNumber != null)
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${line.rightNumber}',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 40),
                  const SizedBox(width: 8),
                  if (icon != null && line.type == _DiffType.added)
                    Icon(icon, size: 14, color: iconColor),
                  if (icon != null && line.type == _DiffType.added)
                    const SizedBox(width: 6),
                  Expanded(
                    child: SelectableText(
                      line.rightLine ?? '',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: line.rightLine == null
                            ? colors.onSurfaceVariant.withValues(alpha: 0.3)
                            : null,
                        fontWeight: line.type == _DiffType.added
                            ? FontWeight.w600
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _computeStats() {
    int added = 0, removed = 0, unchanged = 0;
    for (final line in _diffLines) {
      switch (line.type) {
        case _DiffType.added:
          added++;
          break;
        case _DiffType.removed:
          removed++;
          break;
        case _DiffType.unchanged:
          unchanged++;
          break;
      }
    }
    return {'added': added, 'removed': removed, 'unchanged': unchanged};
  }
}

enum _DiffType { added, removed, unchanged }

class _DiffLine {
  final _DiffType type;
  final String? leftLine;
  final String? rightLine;
  final int? leftNumber;
  final int? rightNumber;

  _DiffLine({
    required this.type,
    this.leftLine,
    this.rightLine,
    this.leftNumber,
    this.rightNumber,
  });
}
