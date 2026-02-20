import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class NumberBaseConverterScreen extends StatefulWidget {
  const NumberBaseConverterScreen({super.key});

  @override
  State<NumberBaseConverterScreen> createState() => _NumberBaseConverterScreenState();
}

class _NumberBaseConverterScreenState extends State<NumberBaseConverterScreen> {
  final _decimalCtrl = TextEditingController(text: '255');
  final _binaryCtrl = TextEditingController();
  final _octalCtrl = TextEditingController();
  final _hexCtrl = TextEditingController();
  int? _currentValue = 255;
  String? _error;

  @override
  void initState() {
    super.initState();
    _updateFromDecimal();
  }

  void _updateFromDecimal() {
    try {
      final value = int.parse(_decimalCtrl.text);
      setState(() {
        _currentValue = value;
        _binaryCtrl.text = value.toRadixString(2);
        _octalCtrl.text = value.toRadixString(8);
        _hexCtrl.text = value.toRadixString(16).toUpperCase();
        _error = null;
      });
    } catch (_) {
      setState(() {
        _error = 'Invalid decimal number';
        _currentValue = null;
      });
    }
  }

  void _updateFromBinary() {
    try {
      final value = int.parse(_binaryCtrl.text, radix: 2);
      setState(() {
        _currentValue = value;
        _decimalCtrl.text = value.toString();
        _octalCtrl.text = value.toRadixString(8);
        _hexCtrl.text = value.toRadixString(16).toUpperCase();
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Invalid binary number');
    }
  }

  void _updateFromOctal() {
    try {
      final value = int.parse(_octalCtrl.text, radix: 8);
      setState(() {
        _currentValue = value;
        _decimalCtrl.text = value.toString();
        _binaryCtrl.text = value.toRadixString(2);
        _hexCtrl.text = value.toRadixString(16).toUpperCase();
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Invalid octal number');
    }
  }

  void _updateFromHex() {
    try {
      final value = int.parse(_hexCtrl.text, radix: 16);
      setState(() {
        _currentValue = value;
        _decimalCtrl.text = value.toString();
        _binaryCtrl.text = value.toRadixString(2);
        _octalCtrl.text = value.toRadixString(8);
        _error = null;
      });
    } catch (_) {
      setState(() => _error = 'Invalid hexadecimal number');
    }
  }

  @override
  void dispose() {
    _decimalCtrl.dispose();
    _binaryCtrl.dispose();
    _octalCtrl.dispose();
    _hexCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ],
                ),
              ),
            _buildBaseInput(
              'DECIMAL (Base 10)',
              _decimalCtrl,
              _updateFromDecimal,
              FilteringTextInputFormatter.digitsOnly,
              colors,
            ),
            const SizedBox(height: 16),
            _buildBaseInput(
              'BINARY (Base 2)',
              _binaryCtrl,
              _updateFromBinary,
              FilteringTextInputFormatter.allow(RegExp(r'[01]')),
              colors,
            ),
            const SizedBox(height: 16),
            _buildBaseInput(
              'OCTAL (Base 8)',
              _octalCtrl,
              _updateFromOctal,
              FilteringTextInputFormatter.allow(RegExp(r'[0-7]')),
              colors,
            ),
            const SizedBox(height: 16),
            _buildBaseInput(
              'HEXADECIMAL (Base 16)',
              _hexCtrl,
              _updateFromHex,
              FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
              colors,
            ),
            const SizedBox(height: 24),
            if (_currentValue != null) ...[
              const SectionHeader(title: 'ADDITIONAL INFO'),
              _buildInfoGrid(colors),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBaseInput(
    String label,
    TextEditingController controller,
    VoidCallback onChanged,
    TextInputFormatter formatter,
    ColorScheme colors,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: label,
          trailing: CopyButton(text: controller.text),
        ),
        TextField(
          controller: controller,
          onChanged: (_) => onChanged(),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          inputFormatters: [formatter],
          decoration: const InputDecoration(
            hintText: 'Enter number...',
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid(ColorScheme colors) {
    final value = _currentValue!;
    final binary = _binaryCtrl.text;
    
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 2.5,
      children: [
        _buildInfoCard('Bit Length', binary.length.toString(), colors),
        _buildInfoCard('Byte Size', ((binary.length + 7) ~/ 8).toString(), colors),
        _buildInfoCard('Sign', value >= 0 ? 'Positive' : 'Negative', colors),
        _buildInfoCard('Even/Odd', value.isEven ? 'Even' : 'Odd', colors),
        _buildInfoCard('Powers of 2', _isPowerOfTwo(value) ? 'Yes (2^${_log2(value)})' : 'No', colors),
        _buildInfoCard('ASCII Char', value >= 32 && value <= 126 ? String.fromCharCode(value) : 'N/A', colors),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  bool _isPowerOfTwo(int n) {
    return n > 0 && (n & (n - 1)) == 0;
  }

  int _log2(int n) {
    int count = 0;
    while (n > 1) {
      n >>= 1;
      count++;
    }
    return count;
  }
}
