import 'dart:convert';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class DataConverterScreen extends StatefulWidget {
  const DataConverterScreen({super.key});

  @override
  State<DataConverterScreen> createState() => _DataConverterScreenState();
}

class _DataConverterScreenState extends State<DataConverterScreen> {
  final _inputCtrl = TextEditingController();
  String _output = '';
  String? _error;
  String _fromFormat = 'JSON';
  String _toFormat = 'CSV';
  String _csvDelimiter = ',';
  bool _csvHasHeaders = true;

  void _convert() {
    if (_inputCtrl.text.trim().isEmpty) {
      setState(() {
        _output = '';
        _error = null;
      });
      return;
    }

    try {
      setState(() => _error = null);

      if (_fromFormat == 'JSON' && _toFormat == 'CSV') {
        _output = _jsonToCsv(_inputCtrl.text);
      } else if (_fromFormat == 'CSV' && _toFormat == 'JSON') {
        _output = _csvToJson(_inputCtrl.text);
      } else if (_fromFormat == 'JSON' && _toFormat == 'YAML') {
        _output = _jsonToYaml(_inputCtrl.text);
      } else if (_fromFormat == 'YAML' && _toFormat == 'JSON') {
        _output = _yamlToJson(_inputCtrl.text);
      } else if (_fromFormat == _toFormat) {
        _output = _inputCtrl.text;
      } else {
        _output = 'Conversion not yet supported';
      }

      setState(() {});
    } catch (e) {
      setState(() {
        _error = 'Conversion error: ${e.toString()}';
        _output = '';
      });
    }
  }

  String _jsonToCsv(String jsonStr) {
    final data = json.decode(jsonStr);
    
    if (data is List) {
      if (data.isEmpty) return '';
      if (data.first is! Map) throw Exception('JSON array must contain objects');
      
      final List<Map<String, dynamic>> items = data.cast<Map<String, dynamic>>();
      final headers = items.first.keys.toList();
      
      final rows = <List<dynamic>>[];
      if (_csvHasHeaders) rows.add(headers);
      
      for (final item in items) {
        rows.add(headers.map((h) => item[h] ?? '').toList());
      }
      
      return const ListToCsvConverter().convert(rows, fieldDelimiter: _csvDelimiter);
    } else if (data is Map) {
      final rows = <List<dynamic>>[];
      if (_csvHasHeaders) rows.add(['Key', 'Value']);
      
      data.forEach((key, value) {
        rows.add([key, value]);
      });
      
      return const ListToCsvConverter().convert(rows, fieldDelimiter: _csvDelimiter);
    }
    
    throw Exception('JSON must be an array or object');
  }

  String _csvToJson(String csvStr) {
    final rows = const CsvToListConverter().convert(
      csvStr,
      fieldDelimiter: _csvDelimiter,
      eol: '\n',
    );
    
    if (rows.isEmpty) return '[]';
    
    if (_csvHasHeaders) {
      final headers = rows.first.map((h) => h.toString()).toList();
      final data = rows.skip(1).map((row) {
        final obj = <String, dynamic>{};
        for (int i = 0; i < headers.length && i < row.length; i++) {
          obj[headers[i]] = row[i];
        }
        return obj;
      }).toList();
      
      return const JsonEncoder.withIndent('  ').convert(data);
    } else {
      return const JsonEncoder.withIndent('  ').convert(rows);
    }
  }

  String _jsonToYaml(String jsonStr) {
    final data = json.decode(jsonStr);
    return _toYaml(data, 0);
  }

  String _toYaml(dynamic data, int indent) {
    final buffer = StringBuffer();
    final indentStr = '  ' * indent;
    
    if (data is Map) {
      data.forEach((key, value) {
        if (value is Map || value is List) {
          buffer.writeln('$indentStr$key:');
          buffer.write(_toYaml(value, indent + 1));
        } else {
          buffer.writeln('$indentStr$key: ${_yamlValue(value)}');
        }
      });
    } else if (data is List) {
      for (final item in data) {
        if (item is Map || item is List) {
          buffer.writeln('$indentStr-');
          buffer.write(_toYaml(item, indent + 1));
        } else {
          buffer.writeln('$indentStr- ${_yamlValue(item)}');
        }
      }
    }
    
    return buffer.toString();
  }

  String _yamlValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) {
      if (value.contains(':') || value.contains('#') || value.contains('\n')) {
        return '"$value"';
      }
      return value;
    }
    return value.toString();
  }

  String _yamlToJson(String yamlStr) {
    final lines = yamlStr.split('\n').where((l) => l.trim().isNotEmpty).toList();
    final result = _parseYaml(lines, 0);
    return const JsonEncoder.withIndent('  ').convert(result['data']);
  }

  Map<String, dynamic> _parseYaml(List<String> lines, int startIndex) {
    final data = <String, dynamic>{};
    int i = startIndex;
    
    while (i < lines.length) {
      final line = lines[i];
      final trimmed = line.trim();
      
      if (trimmed.isEmpty || trimmed.startsWith('#')) {
        i++;
        continue;
      }
      
      if (trimmed.contains(':')) {
        final parts = trimmed.split(':');
        final key = parts[0].trim();
        final value = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
        
        if (value.isEmpty) {
          i++;
          if (i < lines.length && lines[i].startsWith('  ')) {
            final nested = _parseYaml(lines, i);
            data[key] = nested['data'];
            i = nested['nextIndex'] as int;
          }
        } else {
          data[key] = _parseYamlValue(value);
          i++;
        }
      } else {
        i++;
      }
    }
    
    return {'data': data, 'nextIndex': i};
  }

  dynamic _parseYamlValue(String value) {
    if (value == 'null') return null;
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value.replaceAll('"', '');
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
            _buildConverter(colors),
            const SizedBox(height: 24),
            if (_fromFormat == 'CSV' || _toFormat == 'CSV')
              _buildCsvOptions(colors),
            if ((_fromFormat == 'CSV' || _toFormat == 'CSV') && _error == null)
              const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SectionHeader(title: 'INPUT ($_fromFormat)'),
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
                              hintText: 'Paste your $_fromFormat data here...',
                              errorText: _error,
                              errorMaxLines: 2,
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
                          title: 'OUTPUT ($_toFormat)',
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
                                    ? 'Converted output will appear here...'
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

  Widget _buildConverter(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _fromFormat,
              underline: const SizedBox.shrink(),
              items: ['JSON', 'CSV', 'YAML']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _fromFormat = v);
                  _convert();
                }
              },
            ),
            const SizedBox(width: 16),
            Icon(Icons.arrow_forward_rounded, color: colors.primary),
            const SizedBox(width: 16),
            DropdownButton<String>(
              value: _toFormat,
              underline: const SizedBox.shrink(),
              items: ['JSON', 'CSV', 'YAML']
                  .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                  .toList(),
              onChanged: (v) {
                if (v != null) {
                  setState(() => _toFormat = v);
                  _convert();
                }
              },
            ),
            const SizedBox(width: 16),
            IconButton.filled(
              icon: const Icon(Icons.swap_horiz_rounded, size: 20),
              tooltip: 'Swap formats',
              onPressed: () {
                setState(() {
                  final temp = _fromFormat;
                  _fromFormat = _toFormat;
                  _toFormat = temp;
                  _inputCtrl.text = _output;
                  _output = '';
                });
                _convert();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCsvOptions(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text('CSV Options:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 16),
            Text('Delimiter:', style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: ',', label: Text('Comma')),
                ButtonSegment(value: ';', label: Text('Semicolon')),
                ButtonSegment(value: '\t', label: Text('Tab')),
              ],
              selected: {_csvDelimiter},
              onSelectionChanged: (v) {
                setState(() => _csvDelimiter = v.first);
                _convert();
              },
              style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(width: 16),
            FilterChip(
              label: const Text('Has Headers'),
              selected: _csvHasHeaders,
              onSelected: (v) {
                setState(() => _csvHasHeaders = v);
                _convert();
              },
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      ),
    );
  }
}
