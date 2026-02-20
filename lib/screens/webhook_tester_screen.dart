import 'dart:convert';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class WebhookTesterScreen extends StatefulWidget {
  const WebhookTesterScreen({super.key});

  @override
  State<WebhookTesterScreen> createState() => _WebhookTesterScreenState();
}

class _WebhookTesterScreenState extends State<WebhookTesterScreen> {
  final List<_WebhookRequest> _requests = [];
  _WebhookRequest? _selectedRequest;
  String _webhookUrl = '';
  String _filterMethod = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _generateWebhookUrl();
    _addSampleRequests();
  }

  void _generateWebhookUrl() {
    final id = DateTime.now().millisecondsSinceEpoch.toRadixString(36);
    setState(() {
      _webhookUrl = 'https://webhook.site/$id';
    });
  }

  void _addSampleRequests() {
    _requests.addAll([
      _WebhookRequest(
        'POST',
        '/webhook/payment',
        {
          'Content-Type': 'application/json',
          'X-Signature': 'sha256=abc123...',
          'User-Agent': 'Stripe/1.0',
        },
        jsonEncode({
          'event': 'payment.succeeded',
          'amount': 5000,
          'currency': 'usd',
          'customer': 'cus_123456',
        }),
        {'status': 'success'},
        200,
        DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      _WebhookRequest(
        'POST',
        '/webhook/github',
        {
          'Content-Type': 'application/json',
          'X-GitHub-Event': 'push',
          'X-Hub-Signature-256': 'sha256=def456...',
        },
        jsonEncode({
          'ref': 'refs/heads/main',
          'repository': {'name': 'my-repo', 'full_name': 'user/my-repo'},
          'commits': [
            {'message': 'Fix bug', 'author': {'name': 'John Doe'}}
          ],
        }),
        {'status': 'received'},
        200,
        DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      _WebhookRequest(
        'GET',
        '/webhook/health',
        {
          'User-Agent': 'HealthCheck/1.0',
        },
        '',
        {'status': 'ok', 'uptime': 3600},
        200,
        DateTime.now().subtract(const Duration(minutes: 1)),
      ),
    ]);
  }

  void _simulateWebhook() {
    final newRequest = _WebhookRequest(
      'POST',
      '/webhook/test',
      {
        'Content-Type': 'application/json',
        'X-Custom-Header': 'test-value',
        'User-Agent': 'WebhookTester/1.0',
      },
      jsonEncode({
        'event': 'test.event',
        'timestamp': DateTime.now().toIso8601String(),
        'data': {'message': 'This is a test webhook'}
      }),
      {'status': 'received', 'message': 'Webhook processed successfully'},
      200,
      DateTime.now(),
    );

    setState(() {
      _requests.insert(0, newRequest);
      _selectedRequest = newRequest;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Simulated webhook request received')),
    );
  }

  void _clearRequests() {
    setState(() {
      _requests.clear();
      _selectedRequest = null;
    });
  }

  void _deleteRequest(_WebhookRequest request) {
    setState(() {
      _requests.remove(request);
      if (_selectedRequest == request) {
        _selectedRequest = null;
      }
    });
  }

  void _replayRequest(_WebhookRequest request) {
    final replayed = _WebhookRequest(
      request.method,
      request.path,
      Map.from(request.headers),
      request.body,
      request.response,
      request.statusCode,
      DateTime.now(),
    );

    setState(() {
      _requests.insert(0, replayed);
      _selectedRequest = replayed;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Request replayed')),
    );
  }

  List<_WebhookRequest> get _filteredRequests {
    return _requests.where((r) {
      final matchesMethod = _filterMethod == 'all' || r.method == _filterMethod;
      final matchesSearch = _searchQuery.isEmpty ||
          r.path.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          r.body.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesMethod && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildRequestList(colors),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildRequestDetails(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequestList(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'WEBHOOK ENDPOINT',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.refresh, size: 18),
                onPressed: _generateWebhookUrl,
                tooltip: 'Generate New URL',
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 18),
                onPressed: _clearRequests,
                tooltip: 'Clear All',
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: SelectableText(
                    _webhookUrl,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CopyButton(text: _webhookUrl, iconSize: 14),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: colors.primaryContainer.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'This is a simulated webhook endpoint. Click "Simulate Webhook" to test.',
                    style: TextStyle(fontSize: 10, color: colors.onPrimaryContainer),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'REQUESTS (${_filteredRequests.length})',
          trailing: FilledButton.icon(
            onPressed: _simulateWebhook,
            icon: const Icon(Icons.send, size: 16),
            label: const Text('Simulate Webhook'),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search requests...',
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildMethodChip('all', 'All'),
                      _buildMethodChip('GET', 'GET'),
                      _buildMethodChip('POST', 'POST'),
                      _buildMethodChip('PUT', 'PUT'),
                      _buildMethodChip('DELETE', 'DELETE'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredRequests.isEmpty
              ? Card(
                  child: Center(
                    child: Text(
                      'No requests yet',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredRequests.length,
                  itemBuilder: (_, i) => _buildRequestCard(_filteredRequests[i], colors),
                ),
        ),
      ],
    );
  }

  Widget _buildMethodChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: _filterMethod == value,
        onSelected: (_) => setState(() => _filterMethod = value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildRequestCard(_WebhookRequest request, ColorScheme colors) {
    final isSelected = _selectedRequest == request;
    final methodColor = _getMethodColor(request.method);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? colors.primaryContainer.withValues(alpha: 0.3) : null,
      child: InkWell(
        onTap: () => setState(() => _selectedRequest = request),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: methodColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.method,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: methodColor,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getStatusColor(request.statusCode).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      request.statusCode.toString(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _getStatusColor(request.statusCode),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.replay, size: 16),
                    onPressed: () => _replayRequest(request),
                    tooltip: 'Replay',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    onPressed: () => _deleteRequest(request),
                    tooltip: 'Delete',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                request.path,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTimestamp(request.timestamp),
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestDetails(ColorScheme colors) {
    if (_selectedRequest == null) {
      return Card(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.webhook, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
              const SizedBox(height: 16),
              Text(
                'Select a request to view details',
                style: TextStyle(color: colors.onSurfaceVariant),
              ),
            ],
          ),
        ),
      );
    }

    final request = _selectedRequest!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: 'REQUEST DETAILS',
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.replay, size: 18),
                  onPressed: () => _replayRequest(request),
                  tooltip: 'Replay',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _deleteRequest(request),
                  tooltip: 'Delete',
                ),
              ],
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        request.method,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _getMethodColor(request.method),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          request.path,
                          style: const TextStyle(
                            fontSize: 13,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(request.statusCode).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          request.statusCode.toString(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: _getStatusColor(request.statusCode),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTimestamp(request.timestamp),
                    style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'HEADERS (${request.headers.length})',
            trailing: CopyButton(text: jsonEncode(request.headers)),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: request.headers.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: SelectableText(
                            entry.value,
                            style: const TextStyle(
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        CopyButton(text: entry.value, iconSize: 12),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'REQUEST BODY',
            trailing: CopyButton(text: request.body),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                request.body.isEmpty ? '(empty)' : request.body,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                  color: request.body.isEmpty ? colors.onSurfaceVariant : null,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionHeader(
            title: 'RESPONSE',
            trailing: CopyButton(text: jsonEncode(request.response)),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                jsonEncode(request.response),
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'GET':
        return Colors.blue;
      case 'POST':
        return Colors.green;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(int status) {
    if (status >= 200 && status < 300) return Colors.green;
    if (status >= 300 && status < 400) return Colors.blue;
    if (status >= 400 && status < 500) return Colors.orange;
    if (status >= 500) return Colors.red;
    return Colors.grey;
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return '${diff.inSeconds}s ago';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }
}

class _WebhookRequest {
  final String method;
  final String path;
  final Map<String, String> headers;
  final String body;
  final Map<String, dynamic> response;
  final int statusCode;
  final DateTime timestamp;

  _WebhookRequest(
    this.method,
    this.path,
    this.headers,
    this.body,
    this.response,
    this.statusCode,
    this.timestamp,
  );
}
