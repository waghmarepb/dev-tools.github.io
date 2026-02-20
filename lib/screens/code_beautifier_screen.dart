import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:provider/provider.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';
import '../providers/theme_provider.dart';

class CodeBeautifierScreen extends StatefulWidget {
  const CodeBeautifierScreen({super.key});

  @override
  State<CodeBeautifierScreen> createState() => _CodeBeautifierScreenState();
}

class _CodeBeautifierScreenState extends State<CodeBeautifierScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String _language = 'JSON';
  String _mode = 'beautify';
  int _indentSize = 2;

  void _process() {
    if (_inputCtrl.text.trim().isEmpty) {
      setState(() => _output = '');
      return;
    }

    try {
      if (_language == 'JSON') {
        _output = _processJson();
      } else if (_language == 'CSS') {
        _output = _processCss();
      } else if (_language == 'HTML') {
        _output = _processHtml();
      } else if (_language == 'JS') {
        _output = _processJs();
      }
      setState(() {});
    } catch (e) {
      setState(() => _output = 'Error: ${e.toString()}');
    }
  }

  String _processJson() {
    final data = json.decode(_inputCtrl.text);
    if (_mode == 'beautify') {
      return const JsonEncoder.withIndent('  ').convert(data);
    } else {
      return json.encode(data);
    }
  }

  String _processCss() {
    final input = _inputCtrl.text;
    if (_mode == 'minify') {
      return input
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'\s*([{}:;,])\s*'), r'\1')
          .replaceAll(RegExp(r'/\*.*?\*/', multiLine: true), '')
          .trim();
    } else {
      return _beautifyCss(input);
    }
  }

  String _beautifyCss(String css) {
    final buffer = StringBuffer();
    int indentLevel = 0;
    final indent = ' ' * _indentSize;
    
    css = css.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    for (int i = 0; i < css.length; i++) {
      final char = css[i];
      
      if (char == '{') {
        buffer.write(' {\n');
        indentLevel++;
        buffer.write(indent * indentLevel);
      } else if (char == '}') {
        buffer.write('\n');
        indentLevel--;
        buffer.write(indent * indentLevel);
        buffer.write('}');
        if (i < css.length - 1) buffer.write('\n');
        if (indentLevel > 0) buffer.write(indent * indentLevel);
      } else if (char == ';') {
        buffer.write(';\n');
        if (indentLevel > 0) buffer.write(indent * indentLevel);
      } else {
        buffer.write(char);
      }
    }
    
    return buffer.toString().trim();
  }

  String _processHtml() {
    final input = _inputCtrl.text;
    if (_mode == 'minify') {
      return input
          .replaceAll(RegExp(r'>\s+<'), '><')
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'<!--.*?-->', multiLine: true), '')
          .trim();
    } else {
      return _beautifyHtml(input);
    }
  }

  String _beautifyHtml(String html) {
    final buffer = StringBuffer();
    int indentLevel = 0;
    final indent = ' ' * _indentSize;
    final tokens = _tokenizeHtml(html);
    
    for (final token in tokens) {
      if (token.startsWith('</')) {
        indentLevel--;
        buffer.write(indent * indentLevel);
        buffer.writeln(token);
      } else if (token.startsWith('<') && !token.endsWith('/>') && !token.startsWith('<!')) {
        buffer.write(indent * indentLevel);
        buffer.writeln(token);
        if (!_isSelfClosing(token)) {
          indentLevel++;
        }
      } else {
        buffer.write(indent * indentLevel);
        buffer.writeln(token);
      }
    }
    
    return buffer.toString().trim();
  }

  List<String> _tokenizeHtml(String html) {
    final tokens = <String>[];
    final buffer = StringBuffer();
    
    for (int i = 0; i < html.length; i++) {
      final char = html[i];
      
      if (char == '<') {
        if (buffer.isNotEmpty) {
          final text = buffer.toString().trim();
          if (text.isNotEmpty) tokens.add(text);
          buffer.clear();
        }
        buffer.write(char);
      } else if (char == '>') {
        buffer.write(char);
        tokens.add(buffer.toString());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }
    
    if (buffer.isNotEmpty) {
      final text = buffer.toString().trim();
      if (text.isNotEmpty) tokens.add(text);
    }
    
    return tokens;
  }

  bool _isSelfClosing(String tag) {
    final selfClosing = ['br', 'hr', 'img', 'input', 'meta', 'link', 'area', 'base', 'col', 'embed', 'param', 'source', 'track', 'wbr'];
    final tagName = tag.replaceAll(RegExp(r'[<>/\s].*'), '').toLowerCase();
    return selfClosing.contains(tagName) || tag.endsWith('/>');
  }

  String _processJs() {
    final input = _inputCtrl.text;
    if (_mode == 'minify') {
      return input
          .replaceAll(RegExp(r'//.*'), '')
          .replaceAll(RegExp(r'/\*.*?\*/', multiLine: true), '')
          .replaceAll(RegExp(r'\s+'), ' ')
          .replaceAll(RegExp(r'\s*([{}();,:])\s*'), r'\1')
          .trim();
    } else {
      return _beautifyJs(input);
    }
  }

  String _beautifyJs(String js) {
    final buffer = StringBuffer();
    int indentLevel = 0;
    final indent = ' ' * _indentSize;
    
    js = js.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    for (int i = 0; i < js.length; i++) {
      final char = js[i];
      
      if (char == '{') {
        buffer.write(' {\n');
        indentLevel++;
        buffer.write(indent * indentLevel);
      } else if (char == '}') {
        buffer.write('\n');
        indentLevel--;
        buffer.write(indent * indentLevel);
        buffer.write('}');
        if (i < js.length - 1 && js[i + 1] != ';') buffer.write('\n');
        if (indentLevel > 0) buffer.write(indent * indentLevel);
      } else if (char == ';') {
        buffer.write(';\n');
        if (indentLevel > 0) buffer.write(indent * indentLevel);
      } else {
        buffer.write(char);
      }
    }
    
    return buffer.toString().trim();
  }

  String _getStats() {
    if (_output.isEmpty || _inputCtrl.text.isEmpty) return '';
    
    final inputSize = _inputCtrl.text.length;
    final outputSize = _output.length;
    final diff = inputSize - outputSize;
    final percent = ((diff / inputSize) * 100).abs().toStringAsFixed(1);
    
    if (_mode == 'minify' && diff > 0) {
      return '-$percent% (saved ${diff}B)';
    } else if (_mode == 'beautify' && diff < 0) {
      return '+$percent% (added ${diff.abs()}B)';
    }
    return '';
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
                Text('Language:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'JSON', label: Text('JSON')),
                    ButtonSegment(value: 'CSS', label: Text('CSS')),
                    ButtonSegment(value: 'HTML', label: Text('HTML')),
                    ButtonSegment(value: 'JS', label: Text('JavaScript')),
                  ],
                  selected: {_language},
                  onSelectionChanged: (v) {
                    setState(() => _language = v.first);
                    _process();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 24),
                Text('Mode:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'beautify',
                      label: Text('Beautify'),
                      icon: Icon(Icons.auto_fix_high, size: 16),
                    ),
                    ButtonSegment(
                      value: 'minify',
                      label: Text('Minify'),
                      icon: Icon(Icons.compress_rounded, size: 16),
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
            if (_mode == 'beautify') ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('Indent:', style: const TextStyle(fontSize: 13)),
                  const SizedBox(width: 12),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 2, label: Text('2 spaces')),
                      ButtonSegment(value: 4, label: Text('4 spaces')),
                      ButtonSegment(value: 8, label: Text('Tab')),
                    ],
                    selected: {_indentSize},
                    onSelectionChanged: (v) {
                      setState(() => _indentSize = v.first);
                      _process();
                    },
                    style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                  ),
                ],
              ),
            ],
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
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'Paste your $_language code here...',
            ),
            onChanged: (_) => _process(),
          ),
        ),
      ],
    );
  }

  Widget _buildOutputPanel(ColorScheme colors) {
    final stats = _getStats();
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'OUTPUT',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (stats.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stats,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              CopyButton(text: _output),
            ],
          ),
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
            child: _output.isEmpty
                ? Center(
                    child: Text(
                      'Processed code will appear here...',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: HighlightView(
                      _output,
                      language: _getHighlightLanguage(),
                      theme: isDark ? monokaiSublimeTheme : githubTheme,
                      padding: EdgeInsets.zero,
                      textStyle: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _getHighlightLanguage() {
    switch (_language) {
      case 'JSON':
        return 'json';
      case 'CSS':
        return 'css';
      case 'HTML':
        return 'xml';
      case 'JS':
        return 'javascript';
      default:
        return 'plaintext';
    }
  }
}
