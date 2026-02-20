import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class SqlFormatterScreen extends StatefulWidget {
  const SqlFormatterScreen({super.key});

  @override
  State<SqlFormatterScreen> createState() => _SqlFormatterScreenState();
}

class _SqlFormatterScreenState extends State<SqlFormatterScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  int _indentSize = 2;
  bool _uppercase = true;

  void _format() {
    if (_inputCtrl.text.trim().isEmpty) {
      setState(() => _output = '');
      return;
    }

    final formatted = _formatSql(_inputCtrl.text);
    setState(() => _output = formatted);
  }

  String _formatSql(String sql) {
    final keywords = [
      'SELECT', 'FROM', 'WHERE', 'JOIN', 'LEFT', 'RIGHT', 'INNER', 'OUTER',
      'ON', 'AND', 'OR', 'ORDER', 'BY', 'GROUP', 'HAVING', 'LIMIT', 'OFFSET',
      'INSERT', 'INTO', 'VALUES', 'UPDATE', 'SET', 'DELETE', 'CREATE', 'TABLE',
      'ALTER', 'DROP', 'INDEX', 'VIEW', 'AS', 'DISTINCT', 'UNION', 'ALL',
      'CASE', 'WHEN', 'THEN', 'ELSE', 'END', 'NULL', 'NOT', 'IN', 'EXISTS',
      'BETWEEN', 'LIKE', 'IS', 'ASC', 'DESC',
    ];

    String result = sql;
    final indent = ' ' * _indentSize;

    if (_uppercase) {
      for (final keyword in keywords) {
        result = result.replaceAllMapped(
          RegExp('\\b$keyword\\b', caseSensitive: false),
          (match) => keyword,
        );
      }
    }

    result = result
        .replaceAllMapped(RegExp(r'\bSELECT\b', caseSensitive: false),
            (m) => '\nSELECT\n$indent')
        .replaceAllMapped(
            RegExp(r'\bFROM\b', caseSensitive: false), (m) => '\nFROM\n$indent')
        .replaceAllMapped(
            RegExp(r'\bWHERE\b', caseSensitive: false), (m) => '\nWHERE\n$indent')
        .replaceAllMapped(RegExp(r'\b(LEFT|RIGHT|INNER)\s+JOIN\b',
            caseSensitive: false), (m) => '\n${m.group(0)}\n$indent')
        .replaceAllMapped(
            RegExp(r'\bAND\b', caseSensitive: false), (m) => '\n${indent}AND')
        .replaceAllMapped(
            RegExp(r'\bOR\b', caseSensitive: false), (m) => '\n${indent}OR')
        .replaceAllMapped(RegExp(r'\bORDER\s+BY\b', caseSensitive: false),
            (m) => '\nORDER BY\n$indent')
        .replaceAllMapped(RegExp(r'\bGROUP\s+BY\b', caseSensitive: false),
            (m) => '\nGROUP BY\n$indent')
        .replaceAllMapped(RegExp(r'\bHAVING\b', caseSensitive: false),
            (m) => '\nHAVING\n$indent')
        .replaceAllMapped(
            RegExp(r'\bLIMIT\b', caseSensitive: false), (m) => '\nLIMIT')
        .replaceAllMapped(
            RegExp(r'\bOFFSET\b', caseSensitive: false), (m) => '\nOFFSET')
        .replaceAll(',', ',\n$indent')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n\s*\n'), '\n')
        .trim();

    return result;
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader(title: 'OPTIONS')),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 2, label: Text('2 spaces')),
                    ButtonSegment(value: 4, label: Text('4 spaces')),
                  ],
                  selected: {_indentSize},
                  onSelectionChanged: (v) {
                    setState(() => _indentSize = v.first);
                    _format();
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 12),
                FilterChip(
                  label: const Text('UPPERCASE Keywords'),
                  selected: _uppercase,
                  onSelected: (v) {
                    setState(() => _uppercase = v);
                    _format();
                  },
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'INPUT SQL'),
                        Expanded(
                          child: TextField(
                            controller: _inputCtrl,
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Paste your SQL query here...',
                            ),
                            onChanged: (_) => _format(),
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
                          title: 'FORMATTED OUTPUT',
                          trailing: CopyButton(text: _output),
                        ),
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: colors.outlineVariant
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: SingleChildScrollView(
                              child: SelectableText(
                                _output.isEmpty
                                    ? 'Formatted SQL will appear here...'
                                    : _output,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 13,
                                  height: 1.5,
                                  color: _output.isEmpty
                                      ? colors.onSurfaceVariant
                                          .withValues(alpha: 0.5)
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
