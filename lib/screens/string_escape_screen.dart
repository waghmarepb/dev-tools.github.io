import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class StringEscapeScreen extends StatefulWidget {
  const StringEscapeScreen({super.key});

  @override
  State<StringEscapeScreen> createState() => _StringEscapeScreenState();
}

class _StringEscapeScreenState extends State<StringEscapeScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _format = 'javascript';
  String _mode = 'escape';

  void _process() {
    if (_inputCtrl.text.isEmpty) {
      setState(() => _output = '');
      return;
    }

    setState(() {
      _output = _mode == 'escape' ? _escape(_inputCtrl.text) : _unescape(_inputCtrl.text);
    });
  }

  String _escape(String text) {
    switch (_format) {
      case 'javascript':
        return text
            .replaceAll('\\', '\\\\')
            .replaceAll('"', '\\"')
            .replaceAll("'", "\\'")
            .replaceAll('\n', '\\n')
            .replaceAll('\r', '\\r')
            .replaceAll('\t', '\\t');
      case 'json':
        return text
            .replaceAll('\\', '\\\\')
            .replaceAll('"', '\\"')
            .replaceAll('\n', '\\n')
            .replaceAll('\r', '\\r')
            .replaceAll('\t', '\\t')
            .replaceAll('\b', r'\b')
            .replaceAll('\f', r'\f');
      case 'sql':
        return text.replaceAll("'", "''");
      case 'regex':
        return text.replaceAllMapped(
          RegExp(r'[.*+?^${}()|[\]\\]'),
          (match) => '\\${match.group(0)}',
        );
      case 'xml':
        return text
            .replaceAll('&', '&amp;')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;')
            .replaceAll('"', '&quot;')
            .replaceAll("'", '&apos;');
      case 'csv':
        if (text.contains(',') || text.contains('"') || text.contains('\n')) {
          return '"${text.replaceAll('"', '""')}"';
        }
        return text;
      case 'shell':
        return text.replaceAllMapped(
          RegExp(r'[\\$`"\s!*?]'),
          (match) => '\\${match.group(0)}',
        );
      case 'c':
        return text
            .replaceAll('\\', '\\\\')
            .replaceAll('"', '\\"')
            .replaceAll('\n', '\\n')
            .replaceAll('\r', '\\r')
            .replaceAll('\t', '\\t')
            .replaceAll(String.fromCharCode(0), '\\0');
      default:
        return text;
    }
  }

  String _unescape(String text) {
    switch (_format) {
      case 'javascript':
      case 'json':
      case 'c':
        return text
            .replaceAll('\\n', '\n')
            .replaceAll('\\r', '\r')
            .replaceAll('\\t', '\t')
            .replaceAll('\\b', '\b')
            .replaceAll('\\f', '\f')
            .replaceAll('\\"', '"')
            .replaceAll("\\'", "'")
            .replaceAll('\\\\', '\\');
      case 'sql':
        return text.replaceAll("''", "'");
      case 'xml':
        return text
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&quot;', '"')
            .replaceAll('&apos;', "'")
            .replaceAll('&amp;', '&');
      case 'csv':
        if (text.startsWith('"') && text.endsWith('"')) {
          return text.substring(1, text.length - 1).replaceAll('""', '"');
        }
        return text;
      case 'regex':
        return text.replaceAllMapped(
          RegExp(r'\\(.)'),
          (match) => match.group(1)!,
        );
      case 'shell':
        return text.replaceAllMapped(
          RegExp(r'\\(.)'),
          (match) => match.group(1)!,
        );
      default:
        return text;
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
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildControls(colors),
            const SizedBox(height: 24),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildInputPanel(colors)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildOutputPanel(colors)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildExamples(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('Format:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('JavaScript'),
                        selected: _format == 'javascript',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'javascript');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('JSON'),
                        selected: _format == 'json',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'json');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('SQL'),
                        selected: _format == 'sql',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'sql');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Regex'),
                        selected: _format == 'regex',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'regex');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('XML'),
                        selected: _format == 'xml',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'xml');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('CSV'),
                        selected: _format == 'csv',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'csv');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Shell'),
                        selected: _format == 'shell',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'shell');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('C/C++'),
                        selected: _format == 'c',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _format = 'c');
                            _process();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'escape',
                      label: Text('Escape'),
                    ),
                    ButtonSegment(
                      value: 'unescape',
                      label: Text('Unescape'),
                    ),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (v) {
                    setState(() => _mode = v.first);
                    _process();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputPanel(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'INPUT'),
        Expanded(
          child: TextField(
            controller: _inputCtrl,
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: _mode == 'escape'
                  ? 'Enter text to escape...'
                  : 'Enter escaped text...',
            ),
            onChanged: (_) => _process(),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputPanel(ColorScheme colors) {
    return Column(
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
                color: colors.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _output.isEmpty ? 'Escaped text will appear here...' : _output,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: _output.isEmpty
                      ? colors.onSurfaceVariant.withValues(alpha: 0.5)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExamples(ColorScheme colors) {
    final examples = {
      'javascript': 'He said "Hello\\nWorld"',
      'json': '{"text": "Line 1\\nLine 2"}',
      'sql': "SELECT * WHERE name='O''Brien'",
      'regex': 'Match \\(parentheses\\) and \\[brackets\\]',
      'xml': '&lt;tag attr=&quot;value&quot;&gt;',
      'csv': '"Field with, comma"',
      'shell': 'echo "Hello\\ World"',
      'c': 'printf("Line\\nBreak\\0");',
    };

    return Card(
      child: ExpansionTile(
        title: const Text('Examples', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: examples.entries.map((entry) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          entry.key.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: colors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, size: 16),
                        tooltip: 'Try this example',
                        onPressed: () {
                          setState(() {
                            _format = entry.key;
                            _inputCtrl.text = entry.value;
                            _mode = 'unescape';
                          });
                          _process();
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
