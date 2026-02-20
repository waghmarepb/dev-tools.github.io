import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class ApiRequestScreen extends StatefulWidget {
  const ApiRequestScreen({super.key});

  @override
  State<ApiRequestScreen> createState() => _ApiRequestScreenState();
}

class _ApiRequestScreenState extends State<ApiRequestScreen> {
  final _urlCtrl = TextEditingController(text: 'https://jsonplaceholder.typicode.com/posts/1');
  String _method = 'GET';
  String _activeTab = 'headers';
  final List<_KeyValue> _headers = [_KeyValue(key: 'Content-Type', value: 'application/json')];
  final List<_KeyValue> _queryParams = [];
  String _body = '';
  final _bodyCtrl = TextEditingController();
  
  String? _responseBody;
  int? _statusCode;
  Map<String, String>? _responseHeaders;
  int? _responseTime;
  bool _loading = false;
  String? _error;

  Future<void> _sendRequest() async {
    setState(() {
      _loading = true;
      _error = null;
      _responseBody = null;
      _statusCode = null;
      _responseHeaders = null;
      _responseTime = null;
    });

    try {
      final url = _buildUrl();
      final headers = Map.fromEntries(
        _headers.where((h) => h.key.isNotEmpty).map((h) => MapEntry(h.key, h.value)),
      );

      final startTime = DateTime.now();
      http.Response response;

      switch (_method) {
        case 'GET':
          response = await http.get(url, headers: headers);
          break;
        case 'POST':
          response = await http.post(url, headers: headers, body: _body);
          break;
        case 'PUT':
          response = await http.put(url, headers: headers, body: _body);
          break;
        case 'PATCH':
          response = await http.patch(url, headers: headers, body: _body);
          break;
        case 'DELETE':
          response = await http.delete(url, headers: headers, body: _body);
          break;
        default:
          response = await http.get(url, headers: headers);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime).inMilliseconds;

      setState(() {
        _statusCode = response.statusCode;
        _responseBody = _formatResponse(response.body);
        _responseHeaders = response.headers;
        _responseTime = duration;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Uri _buildUrl() {
    final uri = Uri.parse(_urlCtrl.text);
    final params = Map.fromEntries(
      _queryParams.where((p) => p.key.isNotEmpty).map((p) => MapEntry(p.key, p.value)),
    );
    
    if (params.isEmpty) return uri;
    
    return uri.replace(queryParameters: {...uri.queryParameters, ...params});
  }

  String _formatResponse(String body) {
    try {
      final decoded = json.decode(body);
      return const JsonEncoder.withIndent('  ').convert(decoded);
    } catch (_) {
      return body;
    }
  }

  String _generateCurl() {
    final url = _buildUrl();
    final buffer = StringBuffer('curl -X $_method');
    
    for (final header in _headers.where((h) => h.key.isNotEmpty)) {
      buffer.write(' -H "${header.key}: ${header.value}"');
    }
    
    if (_body.isNotEmpty && (_method == 'POST' || _method == 'PUT' || _method == 'PATCH')) {
      buffer.write(' -d \'$_body\'');
    }
    
    buffer.write(' "$url"');
    return buffer.toString();
  }

  @override
  void dispose() {
    _urlCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildRequestPanel(theme, colors),
          ),
          Container(
            width: 1,
            color: colors.outlineVariant,
          ),
          Expanded(
            flex: 3,
            child: _buildResponsePanel(theme, colors),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestPanel(ThemeData theme, ColorScheme colors) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionHeader(title: 'REQUEST'),
        Row(
          children: [
            SizedBox(
              width: 100,
              child: DropdownButtonFormField<String>(
                initialValue: _method,
                isDense: true,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (v) => setState(() => _method = v!),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _urlCtrl,
                decoration: const InputDecoration(
                  hintText: 'https://api.example.com/endpoint',
                  isDense: true,
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _sendRequest,
              icon: _loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded, size: 18),
              label: const Text('Send'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildTabs(colors),
        const SizedBox(height: 16),
        if (_activeTab == 'headers')
          _buildHeadersTab(colors)
        else if (_activeTab == 'params')
          _buildParamsTab(colors)
        else if (_activeTab == 'body')
          _buildBodyTab(colors)
        else
          _buildCurlTab(theme, colors),
      ],
    );
  }

  Widget _buildTabs(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'headers', label: Text('Headers')),
          ButtonSegment(value: 'params', label: Text('Query')),
          ButtonSegment(value: 'body', label: Text('Body')),
          ButtonSegment(value: 'curl', label: Text('cURL')),
        ],
        selected: {_activeTab},
        onSelectionChanged: (v) => setState(() => _activeTab = v.first),
        style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
      ),
    );
  }

  Widget _buildHeadersTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._headers.asMap().entries.map((entry) {
          final i = entry.key;
          final header = entry.value;
          return _buildKeyValueRow(
            header,
            (key, value) {
              setState(() {
                _headers[i] = _KeyValue(key: key, value: value);
              });
            },
            () => setState(() => _headers.removeAt(i)),
            colors,
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _headers.add(_KeyValue(key: '', value: ''))),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Header'),
        ),
      ],
    );
  }

  Widget _buildParamsTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._queryParams.asMap().entries.map((entry) {
          final i = entry.key;
          final param = entry.value;
          return _buildKeyValueRow(
            param,
            (key, value) {
              setState(() {
                _queryParams[i] = _KeyValue(key: key, value: value);
              });
            },
            () => setState(() => _queryParams.removeAt(i)),
            colors,
          );
        }),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => setState(() => _queryParams.add(_KeyValue(key: '', value: ''))),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Add Parameter'),
        ),
      ],
    );
  }

  Widget _buildBodyTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _bodyCtrl,
          maxLines: 12,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
          decoration: const InputDecoration(
            hintText: 'Request body (JSON, XML, form data, etc.)',
          ),
          onChanged: (v) => setState(() => _body = v),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            TextButton.icon(
              onPressed: () {
                try {
                  final decoded = json.decode(_bodyCtrl.text);
                  final formatted = const JsonEncoder.withIndent('  ').convert(decoded);
                  _bodyCtrl.text = formatted;
                  setState(() => _body = formatted);
                } catch (_) {}
              },
              icon: const Icon(Icons.format_align_left, size: 16),
              label: const Text('Format JSON'),
            ),
            const SizedBox(width: 8),
            TextButton.icon(
              onPressed: () {
                _bodyCtrl.clear();
                setState(() => _body = '');
              },
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCurlTab(ThemeData theme, ColorScheme colors) {
    final curl = _generateCurl();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'cURL Command',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  CopyButton(text: curl),
                ],
              ),
              const SizedBox(height: 12),
              SelectableText(
                curl,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyValueRow(
    _KeyValue kv,
    Function(String, String) onChange,
    VoidCallback onRemove,
    ColorScheme colors,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: kv.key)
                ..selection = TextSelection.collapsed(offset: kv.key.length),
              decoration: const InputDecoration(
                hintText: 'Key',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => onChange(v, kv.value),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: TextEditingController(text: kv.value)
                ..selection = TextSelection.collapsed(offset: kv.value.length),
              decoration: const InputDecoration(
                hintText: 'Value',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => onChange(kv.key, v),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildResponsePanel(ThemeData theme, ColorScheme colors) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Expanded(child: SectionHeader(title: 'RESPONSE')),
            if (_statusCode != null) ...[
              _buildStatusChip(_statusCode!, colors),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_responseTime}ms',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (_error != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.shade300),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _error!,
                    style: TextStyle(color: Colors.red.shade700, fontSize: 13),
                  ),
                ),
              ],
            ),
          )
        else if (_loading)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Sending request...',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else if (_responseBody == null)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.http_rounded, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Send a request to see the response',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else ...[
          const SizedBox(height: 8),
          _buildResponseTabs(colors),
          const SizedBox(height: 16),
          if (_activeTab == 'response-body')
            _buildResponseBody(colors)
          else
            _buildResponseHeaders(colors),
        ],
      ],
    );
  }

  Widget _buildStatusChip(int status, ColorScheme colors) {
    Color chipColor;
    if (status >= 200 && status < 300) {
      chipColor = Colors.green;
    } else if (status >= 300 && status < 400) {
      chipColor = Colors.blue;
    } else if (status >= 400 && status < 500) {
      chipColor = Colors.orange;
    } else {
      chipColor = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: chipColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        '$status ${_getStatusText(status)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: chipColor,
        ),
      ),
    );
  }

  String _getStatusText(int status) {
    if (status == 200) return 'OK';
    if (status == 201) return 'Created';
    if (status == 204) return 'No Content';
    if (status == 400) return 'Bad Request';
    if (status == 401) return 'Unauthorized';
    if (status == 403) return 'Forbidden';
    if (status == 404) return 'Not Found';
    if (status == 500) return 'Server Error';
    return '';
  }

  Widget _buildResponseTabs(ColorScheme colors) {
    return SegmentedButton<String>(
      segments: [
        ButtonSegment(
          value: 'response-body',
          label: Text('Body (${_responseBody?.length ?? 0} bytes)'),
        ),
        ButtonSegment(
          value: 'response-headers',
          label: Text('Headers (${_responseHeaders?.length ?? 0})'),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
      style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
    );
  }

  Widget _buildResponseBody(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Spacer(),
            CopyButton(text: _responseBody ?? ''),
          ],
        ),
        Container(
          constraints: const BoxConstraints(minHeight: 200, maxHeight: 600),
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: SingleChildScrollView(
            child: SelectableText(
              _responseBody ?? '',
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 12,
                height: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseHeaders(ColorScheme colors) {
    if (_responseHeaders == null || _responseHeaders!.isEmpty) {
      return const Text('No headers');
    }

    return Column(
      children: _responseHeaders!.entries.map((entry) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 150,
                child: Text(
                  entry.key,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
              CopyButton(text: entry.value, iconSize: 14),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _KeyValue {
  final String key;
  final String value;

  _KeyValue({required this.key, required this.value});
}
