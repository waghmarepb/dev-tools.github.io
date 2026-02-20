import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class ColorConverterScreen extends StatefulWidget {
  const ColorConverterScreen({super.key});

  @override
  State<ColorConverterScreen> createState() => _ColorConverterScreenState();
}

class _ColorConverterScreenState extends State<ColorConverterScreen> {
  Color _currentColor = const Color(0xFF6C63FF);
  final _hexCtrl = TextEditingController(text: '6C63FF');
  final _rgbRCtrl = TextEditingController(text: '108');
  final _rgbGCtrl = TextEditingController(text: '99');
  final _rgbBCtrl = TextEditingController(text: '255');
  final _hslHCtrl = TextEditingController();
  final _hslSCtrl = TextEditingController();
  final _hslLCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateFromColor(_currentColor);
  }

  void _updateFromColor(Color color) {
    _currentColor = color;
    final r = (color.r * 255).round();
    final g = (color.g * 255).round();
    final b = (color.b * 255).round();
    _hexCtrl.text = color.toARGB32().toRadixString(16).substring(2).toUpperCase();
    _rgbRCtrl.text = r.toString();
    _rgbGCtrl.text = g.toString();
    _rgbBCtrl.text = b.toString();
    
    final hsl = _rgbToHsl(r, g, b);
    _hslHCtrl.text = hsl[0].toStringAsFixed(0);
    _hslSCtrl.text = hsl[1].toStringAsFixed(0);
    _hslLCtrl.text = hsl[2].toStringAsFixed(0);
  }

  void _updateFromHex() {
    try {
      final hex = _hexCtrl.text.replaceAll('#', '').trim();
      if (hex.length == 6) {
        final color = Color(int.parse('FF$hex', radix: 16));
        setState(() => _updateFromColor(color));
      }
    } catch (_) {}
  }

  void _updateFromRgb() {
    try {
      final r = int.parse(_rgbRCtrl.text).clamp(0, 255);
      final g = int.parse(_rgbGCtrl.text).clamp(0, 255);
      final b = int.parse(_rgbBCtrl.text).clamp(0, 255);
      final color = Color.fromARGB(255, r, g, b);
      setState(() => _updateFromColor(color));
    } catch (_) {}
  }

  void _updateFromHsl() {
    try {
      final h = double.parse(_hslHCtrl.text).clamp(0.0, 360.0);
      final s = double.parse(_hslSCtrl.text).clamp(0.0, 100.0);
      final l = double.parse(_hslLCtrl.text).clamp(0.0, 100.0);
      final rgb = _hslToRgb(h, s, l);
      final color = Color.fromARGB(255, rgb[0], rgb[1], rgb[2]);
      setState(() => _updateFromColor(color));
    } catch (_) {}
  }

  List<double> _rgbToHsl(int r, int g, int b) {
    final rNorm = r / 255.0;
    final gNorm = g / 255.0;
    final bNorm = b / 255.0;
    
    final max = math.max(rNorm, math.max(gNorm, bNorm)).toDouble();
    final min = math.min(rNorm, math.min(gNorm, bNorm)).toDouble();
    final delta = max - min;
    
    double h = 0;
    double s = 0;
    final l = (max + min) / 2;
    
    if (delta != 0) {
      s = l > 0.5 ? delta / (2 - max - min) : delta / (max + min);
      
      if (max == rNorm) {
        h = ((gNorm - bNorm) / delta + (gNorm < bNorm ? 6 : 0)) / 6;
      } else if (max == gNorm) {
        h = ((bNorm - rNorm) / delta + 2) / 6;
      } else {
        h = ((rNorm - gNorm) / delta + 4) / 6;
      }
    }
    
    return [h * 360, s * 100, l * 100];
  }

  List<int> _hslToRgb(double h, double s, double l) {
    h = h / 360;
    s = s / 100;
    l = l / 100;
    
    double r, g, b;
    
    if (s == 0) {
      r = g = b = l;
    } else {
      final q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      final p = 2 * l - q;
      r = _hueToRgb(p, q, h + 1 / 3);
      g = _hueToRgb(p, q, h);
      b = _hueToRgb(p, q, h - 1 / 3);
    }
    
    return [(r * 255).round(), (g * 255).round(), (b * 255).round()];
  }

  double _hueToRgb(double p, double q, double t) {
    double tNorm = t;
    if (t < 0) tNorm += 1;
    if (t > 1) tNorm -= 1;
    if (tNorm < 1 / 6) return p + (q - p) * 6 * tNorm;
    if (tNorm < 1 / 2) return q;
    if (tNorm < 2 / 3) return p + (q - p) * (2 / 3 - tNorm) * 6;
    return p;
  }

  @override
  void dispose() {
    _hexCtrl.dispose();
    _rgbRCtrl.dispose();
    _rgbGCtrl.dispose();
    _rgbBCtrl.dispose();
    _hslHCtrl.dispose();
    _hslSCtrl.dispose();
    _hslLCtrl.dispose();
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
          _buildColorPreview(colors),
          const SizedBox(height: 24),
          _buildColorPicker(),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildHexInput(colors)),
              const SizedBox(width: 16),
              Expanded(child: _buildRgbInput(colors)),
              const SizedBox(width: 16),
              Expanded(child: _buildHslInput(colors)),
            ],
          ),
          const SizedBox(height: 24),
          _buildCodeSnippets(theme, colors),
          const SizedBox(height: 24),
          _buildContrastChecker(theme, colors),
        ],
      ),
    );
  }

  Widget _buildColorPreview(ColorScheme colors) {
    final isLight = _currentColor.computeLuminance() > 0.5;
    
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: _currentColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: _currentColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.palette_rounded,
              size: 48,
              color: isLight ? Colors.black87 : Colors.white,
            ),
            const SizedBox(height: 12),
            Text(
              '#${_hexCtrl.text}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace',
                color: isLight ? Colors.black87 : Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'RGB(${(_currentColor.r * 255).round()}, ${(_currentColor.g * 255).round()}, ${(_currentColor.b * 255).round()})',
              style: TextStyle(
                fontSize: 14,
                color: isLight ? Colors.black54 : Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'COLOR PICKER'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildHueSlider(),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSaturationSlider()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildLightnessSlider()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHueSlider() {
    final r = (_currentColor.r * 255).round();
    final g = (_currentColor.g * 255).round();
    final b = (_currentColor.b * 255).round();
    final hsl = _rgbToHsl(r, g, b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hue: ${hsl[0].toStringAsFixed(0)}°', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 24,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: hsl[0],
            min: 0,
            max: 360,
            onChanged: (v) {
              _hslHCtrl.text = v.toStringAsFixed(0);
              _updateFromHsl();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSaturationSlider() {
    final r = (_currentColor.r * 255).round();
    final g = (_currentColor.g * 255).round();
    final b = (_currentColor.b * 255).round();
    final hsl = _rgbToHsl(r, g, b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Saturation: ${hsl[1].toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Slider(
          value: hsl[1],
          min: 0,
          max: 100,
          onChanged: (v) {
            _hslSCtrl.text = v.toStringAsFixed(0);
            _updateFromHsl();
          },
        ),
      ],
    );
  }

  Widget _buildLightnessSlider() {
    final r = (_currentColor.r * 255).round();
    final g = (_currentColor.g * 255).round();
    final b = (_currentColor.b * 255).round();
    final hsl = _rgbToHsl(r, g, b);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Lightness: ${hsl[2].toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
        const SizedBox(height: 4),
        Slider(
          value: hsl[2],
          min: 0,
          max: 100,
          onChanged: (v) {
            _hslLCtrl.text = v.toStringAsFixed(0);
            _updateFromHsl();
          },
        ),
      ],
    );
  }

  Widget _buildHexInput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'HEX'),
        TextField(
          controller: _hexCtrl,
          decoration: InputDecoration(
            prefixText: '#',
            suffixIcon: CopyButton(text: '#${_hexCtrl.text}'),
          ),
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9A-Fa-f]')),
            LengthLimitingTextInputFormatter(6),
          ],
          onChanged: (_) => _updateFromHex(),
        ),
      ],
    );
  }

  Widget _buildRgbInput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'RGB'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _rgbRCtrl,
                decoration: const InputDecoration(labelText: 'R', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromRgb(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _rgbGCtrl,
                decoration: const InputDecoration(labelText: 'G', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromRgb(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _rgbBCtrl,
                decoration: const InputDecoration(labelText: 'B', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromRgb(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CopyButton(
          text: 'rgb(${(_currentColor.r * 255).round()}, ${(_currentColor.g * 255).round()}, ${(_currentColor.b * 255).round()})',
          tooltip: 'Copy RGB',
        ),
      ],
    );
  }

  Widget _buildHslInput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'HSL'),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _hslHCtrl,
                decoration: const InputDecoration(labelText: 'H', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromHsl(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _hslSCtrl,
                decoration: const InputDecoration(labelText: 'S%', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromHsl(),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _hslLCtrl,
                decoration: const InputDecoration(labelText: 'L%', isDense: true),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) => _updateFromHsl(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        CopyButton(
          text: 'hsl(${_hslHCtrl.text}, ${_hslSCtrl.text}%, ${_hslLCtrl.text}%)',
          tooltip: 'Copy HSL',
        ),
      ],
    );
  }

  Widget _buildCodeSnippets(ThemeData theme, ColorScheme colors) {
    final snippets = {
      'CSS': '#${_hexCtrl.text}',
      'Flutter': 'Color(0xFF${_hexCtrl.text})',
      'Android': '#FF${_hexCtrl.text}',
      'iOS (Swift)': 'UIColor(red: ${_currentColor.r.toStringAsFixed(2)}, green: ${_currentColor.g.toStringAsFixed(2)}, blue: ${_currentColor.b.toStringAsFixed(2)}, alpha: 1.0)',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CODE SNIPPETS'),
        ...snippets.entries.map((entry) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 80,
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                Expanded(
                  child: SelectableText(
                    entry.value,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
                CopyButton(text: entry.value, iconSize: 16),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildContrastChecker(ThemeData theme, ColorScheme colors) {
    final onWhite = _calculateContrast(_currentColor, Colors.white);
    final onBlack = _calculateContrast(_currentColor, Colors.black);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CONTRAST CHECKER (WCAG)'),
        Row(
          children: [
            Expanded(
              child: _buildContrastCard('On White', onWhite, Colors.white, colors),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildContrastCard('On Black', onBlack, Colors.black, colors),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildContrastCard(String label, double ratio, Color bgColor, ColorScheme colors) {
    final passAA = ratio >= 4.5;
    final passAAA = ratio >= 7.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: bgColor == Colors.white ? Colors.black54 : Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _currentColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Sample',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: bgColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${ratio.toStringAsFixed(2)}:1',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: bgColor == Colors.white ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildBadge('AA', passAA, bgColor),
              const SizedBox(width: 6),
              _buildBadge('AAA', passAAA, bgColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, bool pass, Color bgColor) {
    final badgeColor = pass ? Colors.green : Colors.red;
    final textColor = bgColor == Colors.white ? Colors.white : Colors.black;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  double _calculateContrast(Color color1, Color color2) {
    final l1 = _relativeLuminance(color1);
    final l2 = _relativeLuminance(color2);
    final lighter = math.max(l1, l2);
    final darker = math.min(l1, l2);
    return (lighter + 0.05) / (darker + 0.05);
  }

  double _relativeLuminance(Color color) {
    final r = _linearize(color.r);
    final g = _linearize(color.g);
    final b = _linearize(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  double _linearize(double channel) {
    return channel <= 0.03928
        ? channel / 12.92
        : math.pow((channel + 0.055) / 1.055, 2.4).toDouble();
  }
}
