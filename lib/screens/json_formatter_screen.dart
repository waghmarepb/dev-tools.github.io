import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class JsonFormatterScreen extends StatefulWidget {
  const JsonFormatterScreen({super.key});

  @override
  State<JsonFormatterScreen> createState() => _JsonFormatterScreenState();
}

class _JsonFormatterScreenState extends State<JsonFormatterScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String? _error;
  int _indent = 2;
  bool _minify = false;

  void _format() {
    if (_inputCtrl.text.trim().isEmpty) {
      setState(() {
        _output = '';
        _error = null;
      });
      return;
    }

    try {
      final decoded = json.decode(_inputCtrl.text);
      setState(() {
        if (_minify) {
          _output = json.encode(decoded);
        } else {
          final encoder = JsonEncoder.withIndent(' ' * _indent);
          _output = encoder.convert(decoded);
        }
        _error = null;
      });
    } on FormatException catch (e) {
      setState(() {
        _error = 'Invalid JSON: ${e.message}';
        _output = '';
      });
    }
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
      appBar: AppBar(
        title: const Text('JSON Formatter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all_rounded),
            tooltip: 'Clear',
            onPressed: () {
              _inputCtrl.clear();
              setState(() {
                _output = '';
                _error = null;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                const SectionHeader(title: 'OPTIONS'),
                const Spacer(),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('Format')),
                    ButtonSegment(value: true, label: Text('Minify')),
                  ],
                  selected: {_minify},
                  onSelectionChanged: (v) {
                    setState(() => _minify = v.first);
                    _format();
                  },
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(width: 12),
                if (!_minify)
                  DropdownButton<int>(
                    value: _indent,
                    underline: const SizedBox.shrink(),
                    isDense: true,
                    items: const [
                      DropdownMenuItem(value: 2, child: Text('2 spaces')),
                      DropdownMenuItem(value: 4, child: Text('4 spaces')),
                      DropdownMenuItem(value: 8, child: Text('Tab (8)')),
                    ],
                    onChanged: (v) {
                      if (v != null) {
                        setState(() => _indent = v);
                        _format();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SectionHeader(title: 'INPUT'),
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
                            decoration: InputDecoration(
                              hintText: 'Paste your JSON here...',
                              errorText: _error,
                              errorMaxLines: 2,
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
                          title: 'OUTPUT',
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
                            child: SelectableText(
                              _output.isEmpty
                                  ? 'Formatted output will appear here...'
                                  : _output,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                color: _output.isEmpty
                                    ? colors.onSurfaceVariant
                                        .withValues(alpha: 0.5)
                                    : null,
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
