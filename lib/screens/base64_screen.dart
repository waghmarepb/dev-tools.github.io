import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class Base64Screen extends StatefulWidget {
  const Base64Screen({super.key});

  @override
  State<Base64Screen> createState() => _Base64ScreenState();
}

class _Base64ScreenState extends State<Base64Screen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String? _error;
  bool _encoding = true;

  void _convert() {
    if (_inputCtrl.text.isEmpty) {
      setState(() {
        _output = '';
        _error = null;
      });
      return;
    }

    try {
      setState(() {
        if (_encoding) {
          _output = base64Encode(utf8.encode(_inputCtrl.text));
        } else {
          _output = utf8.decode(base64Decode(_inputCtrl.text));
        }
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = _encoding
            ? 'Failed to encode'
            : 'Invalid Base64 string';
        _output = '';
      });
    }
  }

  void _swap() {
    final currentOutput = _output;
    setState(() {
      _encoding = !_encoding;
      _inputCtrl.text = currentOutput;
      _output = '';
      _error = null;
    });
    _convert();
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
      appBar: AppBar(title: const Text('Base64 Encoder / Decoder')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(
                      value: true,
                      label: Text('Encode'),
                      icon: Icon(Icons.lock_outline, size: 18),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Text('Decode'),
                      icon: Icon(Icons.lock_open_outlined, size: 18),
                    ),
                  ],
                  selected: {_encoding},
                  onSelectionChanged: (v) {
                    setState(() => _encoding = v.first);
                    _convert();
                  },
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.swap_vert_rounded, size: 20),
                  tooltip: 'Swap input/output',
                  onPressed: _output.isNotEmpty ? _swap : null,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(
                          title: _encoding ? 'PLAIN TEXT' : 'BASE64 INPUT',
                        ),
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
                              hintText: _encoding
                                  ? 'Enter text to encode...'
                                  : 'Paste Base64 string...',
                              errorText: _error,
                            ),
                            onChanged: (_) => _convert(),
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
                          title: _encoding ? 'BASE64 OUTPUT' : 'DECODED TEXT',
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
                                  ? 'Output will appear here...'
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
