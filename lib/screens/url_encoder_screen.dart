import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class UrlEncoderScreen extends StatefulWidget {
  const UrlEncoderScreen({super.key});

  @override
  State<UrlEncoderScreen> createState() => _UrlEncoderScreenState();
}

class _UrlEncoderScreenState extends State<UrlEncoderScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String? _error;
  bool _encoding = true;
  bool _encodeComponent = true;

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
          _output = _encodeComponent
              ? Uri.encodeComponent(_inputCtrl.text)
              : Uri.encodeFull(_inputCtrl.text);
        } else {
          _output = _encodeComponent
              ? Uri.decodeComponent(_inputCtrl.text)
              : Uri.decodeFull(_inputCtrl.text);
        }
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Invalid input for ${_encoding ? "encoding" : "decoding"}';
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
      appBar: AppBar(title: const Text('URL Encoder / Decoder')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Wrap(
              spacing: 12,
              alignment: WrapAlignment.center,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Encode')),
                    ButtonSegment(value: false, label: Text('Decode')),
                  ],
                  selected: {_encoding},
                  onSelectionChanged: (v) {
                    setState(() => _encoding = v.first);
                    _convert();
                  },
                ),
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: true, label: Text('Component')),
                    ButtonSegment(value: false, label: Text('Full URL')),
                  ],
                  selected: {_encodeComponent},
                  onSelectionChanged: (v) {
                    setState(() => _encodeComponent = v.first);
                    _convert();
                  },
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
                              hintText: _encoding
                                  ? 'Enter URL or text to encode...'
                                  : 'Paste encoded URL...',
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
