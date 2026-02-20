import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class HtmlEntityScreen extends StatefulWidget {
  const HtmlEntityScreen({super.key});

  @override
  State<HtmlEntityScreen> createState() => _HtmlEntityScreenState();
}

class _HtmlEntityScreenState extends State<HtmlEntityScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _mode = 'encode';
  bool _useNumeric = false;
  bool _useHex = false;

  final Map<String, String> _namedEntities = {
    '&': '&amp;',
    '<': '&lt;',
    '>': '&gt;',
    '"': '&quot;',
    "'": '&apos;',
    ' ': '&nbsp;',
    '¡': '&iexcl;',
    '¢': '&cent;',
    '£': '&pound;',
    '¤': '&curren;',
    '¥': '&yen;',
    '©': '&copy;',
    '®': '&reg;',
    '°': '&deg;',
    '±': '&plusmn;',
    '×': '&times;',
    '÷': '&divide;',
    '€': '&euro;',
    '™': '&trade;',
  };

  void _process() {
    if (_inputCtrl.text.isEmpty) {
      setState(() => _output = '');
      return;
    }

    setState(() {
      _output = _mode == 'encode' ? _encode(_inputCtrl.text) : _decode(_inputCtrl.text);
    });
  }

  String _encode(String text) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < text.length; i++) {
      final char = text[i];
      final code = char.codeUnitAt(0);
      
      if (_namedEntities.containsKey(char) && !_useNumeric) {
        buffer.write(_namedEntities[char]);
      } else if (code > 127 || (_useNumeric && _namedEntities.containsKey(char))) {
        if (_useHex) {
          buffer.write('&#x${code.toRadixString(16)};');
        } else {
          buffer.write('&#$code;');
        }
      } else {
        buffer.write(char);
      }
    }
    
    return buffer.toString();
  }

  String _decode(String text) {
    String result = text;
    
    _namedEntities.forEach((char, entity) {
      result = result.replaceAll(entity, char);
    });
    
    result = result.replaceAllMapped(
      RegExp(r'&#x([0-9a-fA-F]+);'),
      (match) => String.fromCharCode(int.parse(match.group(1)!, radix: 16)),
    );
    
    result = result.replaceAllMapped(
      RegExp(r'&#(\d+);'),
      (match) => String.fromCharCode(int.parse(match.group(1)!)),
    );
    
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
            _buildEntityReference(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(
                  value: 'encode',
                  label: Text('Encode'),
                  icon: Icon(Icons.lock_outline, size: 16),
                ),
                ButtonSegment(
                  value: 'decode',
                  label: Text('Decode'),
                  icon: Icon(Icons.lock_open_outlined, size: 16),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (v) {
                setState(() => _mode = v.first);
                _process();
              },
            ),
            if (_mode == 'encode') ...[
              const SizedBox(width: 24),
              FilterChip(
                label: const Text('Use Numeric'),
                selected: _useNumeric,
                onSelected: (v) {
                  setState(() => _useNumeric = v);
                  _process();
                },
                visualDensity: VisualDensity.compact,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Hex Format'),
                selected: _useHex,
                onSelected: (v) {
                  setState(() => _useHex = v);
                  _process();
                },
                visualDensity: VisualDensity.compact,
              ),
            ],
            const Spacer(),
            IconButton.filled(
              icon: const Icon(Icons.swap_horiz_rounded, size: 20),
              tooltip: 'Swap input/output',
              onPressed: () {
                setState(() {
                  final temp = _inputCtrl.text;
                  _inputCtrl.text = _output;
                  _output = temp;
                  _mode = _mode == 'encode' ? 'decode' : 'encode';
                });
                _process();
              },
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
              hintText: _mode == 'encode'
                  ? 'Enter text with special characters...'
                  : 'Enter HTML entities...',
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
                _output.isEmpty ? 'Converted text will appear here...' : _output,
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

  Widget _buildEntityReference(ColorScheme colors) {
    return Card(
      child: ExpansionTile(
        title: const Text('Common HTML Entities Reference', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _namedEntities.entries.map((entry) {
                return InkWell(
                  onTap: () {
                    _inputCtrl.text += entry.key;
                    _process();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          entry.value,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
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
