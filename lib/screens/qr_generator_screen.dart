import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../widgets/section_header.dart';

class QrGeneratorScreen extends StatefulWidget {
  const QrGeneratorScreen({super.key});

  @override
  State<QrGeneratorScreen> createState() => _QrGeneratorScreenState();
}

class _QrGeneratorScreenState extends State<QrGeneratorScreen> {
  final _textCtrl = TextEditingController();
  String _data = 'https://flutter.dev';
  int _size = 300;
  Color _foregroundColor = Colors.black;
  Color _backgroundColor = Colors.white;
  String _errorCorrection = 'M';

  final _presets = {
    'Website URL': 'https://example.com',
    'Email': 'mailto:hello@example.com',
    'Phone': 'tel:+1234567890',
    'SMS': 'sms:+1234567890?body=Hello',
    'WiFi': 'WIFI:T:WPA;S:NetworkName;P:Password;;',
    'vCard': 'BEGIN:VCARD\nVERSION:3.0\nFN:John Doe\nTEL:+1234567890\nEMAIL:john@example.com\nEND:VCARD',
  };

  @override
  void initState() {
    super.initState();
    _textCtrl.text = _data;
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildPresets(colors),
                    const SizedBox(height: 24),
                    _buildInput(colors),
                    const SizedBox(height: 24),
                    _buildOptions(theme, colors),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildQrPreview(theme, colors),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresets(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'QUICK PRESETS'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.entries.map((entry) {
            return ActionChip(
              label: Text(entry.key),
              onPressed: () {
                _textCtrl.text = entry.value;
                setState(() => _data = entry.value);
              },
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'QR CODE DATA'),
        TextField(
          controller: _textCtrl,
          maxLines: 5,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Enter text, URL, or data to encode...',
          ),
          onChanged: (v) => setState(() => _data = v),
        ),
        const SizedBox(height: 8),
        Text(
          '${_data.length} characters',
          style: TextStyle(
            fontSize: 11,
            color: colors.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'OPTIONS'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Size: ${_size}px', style: const TextStyle(fontSize: 13)),
                Slider(
                  value: _size.toDouble(),
                  min: 100,
                  max: 500,
                  divisions: 40,
                  onChanged: (v) => setState(() => _size = v.toInt()),
                ),
                const SizedBox(height: 12),
                Text('Error Correction', style: theme.textTheme.labelMedium),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'L', label: Text('Low')),
                    ButtonSegment(value: 'M', label: Text('Medium')),
                    ButtonSegment(value: 'Q', label: Text('Quartile')),
                    ButtonSegment(value: 'H', label: Text('High')),
                  ],
                  selected: {_errorCorrection},
                  onSelectionChanged: (v) =>
                      setState(() => _errorCorrection = v.first),
                  style: SegmentedButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Foreground', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickColor(true),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _foregroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.outline),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Background', style: theme.textTheme.labelMedium),
                          const SizedBox(height: 6),
                          InkWell(
                            onTap: () => _pickColor(false),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: _backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: colors.outline),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQrPreview(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PREVIEW'),
        Card(
          child: Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: _data.isEmpty
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.qr_code_rounded,
                            size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'Enter data to generate QR code',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    )
                  : QrImageView(
                      data: _data,
                      version: QrVersions.auto,
                      size: _size.toDouble(),
                      backgroundColor: _backgroundColor,
                      eyeStyle: QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: _foregroundColor,
                      ),
                      dataModuleStyle: QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: _foregroundColor,
                      ),
                      errorCorrectionLevel: _getErrorLevel(),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  int _getErrorLevel() {
    switch (_errorCorrection) {
      case 'L':
        return QrErrorCorrectLevel.L;
      case 'Q':
        return QrErrorCorrectLevel.Q;
      case 'H':
        return QrErrorCorrectLevel.H;
      default:
        return QrErrorCorrectLevel.M;
    }
  }

  void _pickColor(bool isForeground) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Pick ${isForeground ? 'Foreground' : 'Background'} Color'),
        content: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Colors.black,
            Colors.white,
            Colors.red,
            Colors.blue,
            Colors.green,
            Colors.purple,
            Colors.orange,
            Colors.pink,
          ].map((color) {
            return InkWell(
              onTap: () {
                setState(() {
                  if (isForeground) {
                    _foregroundColor = color;
                  } else {
                    _backgroundColor = color;
                  }
                });
                Navigator.pop(context);
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
