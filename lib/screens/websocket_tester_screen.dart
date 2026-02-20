import 'dart:async';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class WebsocketTesterScreen extends StatefulWidget {
  const WebsocketTesterScreen({super.key});

  @override
  State<WebsocketTesterScreen> createState() => _WebsocketTesterScreenState();
}

class _WebsocketTesterScreenState extends State<WebsocketTesterScreen> {
  final _urlCtrl = TextEditingController(text: 'wss://echo.websocket.org');
  final _messageCtrl = TextEditingController();
  final List<_Message> _messages = [];
  
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _connected = false;
  String? _error;

  void _connect() {
    if (_urlCtrl.text.isEmpty) return;

    try {
      setState(() {
        _error = null;
        _connected = false;
      });

      final uri = Uri.parse(_urlCtrl.text);
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        (message) {
          setState(() {
            _messages.add(_Message(
              content: message.toString(),
              timestamp: DateTime.now(),
              isOutgoing: false,
            ));
          });
        },
        onError: (error) {
          setState(() {
            _error = error.toString();
            _connected = false;
          });
        },
        onDone: () {
          setState(() {
            _connected = false;
            _messages.add(_Message(
              content: '[Connection closed]',
              timestamp: DateTime.now(),
              isOutgoing: false,
              isSystem: true,
            ));
          });
        },
      );

      setState(() {
        _connected = true;
        _messages.add(_Message(
          content: '[Connected to ${_urlCtrl.text}]',
          timestamp: DateTime.now(),
          isOutgoing: false,
          isSystem: true,
        ));
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _connected = false;
      });
    }
  }

  void _disconnect() {
    _subscription?.cancel();
    _channel?.sink.close();
    setState(() {
      _connected = false;
      _messages.add(_Message(
        content: '[Disconnected]',
        timestamp: DateTime.now(),
        isOutgoing: false,
        isSystem: true,
      ));
    });
  }

  void _sendMessage() {
    if (_messageCtrl.text.isEmpty || !_connected) return;

    final message = _messageCtrl.text;
    _channel?.sink.add(message);

    setState(() {
      _messages.add(_Message(
        content: message,
        timestamp: DateTime.now(),
        isOutgoing: true,
      ));
      _messageCtrl.clear();
    });
  }

  void _clearMessages() {
    setState(() => _messages.clear());
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _channel?.sink.close();
    _urlCtrl.dispose();
    _messageCtrl.dispose();
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
            _buildConnectionPanel(colors),
            const SizedBox(height: 16),
            if (_error != null) _buildErrorBanner(colors),
            if (_error != null) const SizedBox(height: 16),
            Expanded(child: _buildMessagesPanel(colors)),
            const SizedBox(height: 16),
            _buildSendPanel(colors),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionPanel(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _connected ? Colors.green : Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _urlCtrl,
                enabled: !_connected,
                decoration: const InputDecoration(
                  hintText: 'wss://example.com/socket',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              ),
            ),
            const SizedBox(width: 12),
            if (_connected)
              FilledButton.icon(
                onPressed: _disconnect,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Disconnect'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              )
            else
              FilledButton.icon(
                onPressed: _connect,
                icon: const Icon(Icons.power, size: 18),
                label: const Text('Connect'),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(ColorScheme colors) {
    return Container(
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
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            onPressed: () => setState(() => _error = null),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesPanel(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'MESSAGES (${_messages.length})',
          trailing: _messages.isNotEmpty
              ? TextButton.icon(
                  onPressed: _clearMessages,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear'),
                )
              : null,
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_outlined, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
                        const SizedBox(height: 16),
                        Text(
                          'No messages yet',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (_, i) {
                      final msg = _messages[_messages.length - 1 - i];
                      return _buildMessageBubble(msg, colors);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(_Message msg, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: msg.isOutgoing ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!msg.isOutgoing) ...[
            Icon(
              msg.isSystem ? Icons.info_outline : Icons.arrow_downward,
              size: 16,
              color: msg.isSystem ? colors.tertiary : colors.primary,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: msg.isSystem
                    ? colors.tertiaryContainer.withValues(alpha: 0.5)
                    : msg.isOutgoing
                        ? colors.primaryContainer
                        : colors.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SelectableText(
                    msg.content,
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: msg.isSystem ? null : 'monospace',
                      fontStyle: msg.isSystem ? FontStyle.italic : null,
                      color: msg.isSystem
                          ? colors.onTertiaryContainer
                          : msg.isOutgoing
                              ? colors.onPrimaryContainer
                              : colors.onSecondaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatTime(msg.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          color: (msg.isSystem
                                  ? colors.onTertiaryContainer
                                  : msg.isOutgoing
                                      ? colors.onPrimaryContainer
                                      : colors.onSecondaryContainer)
                              .withValues(alpha: 0.7),
                        ),
                      ),
                      if (!msg.isSystem) ...[
                        const SizedBox(width: 8),
                        CopyButton(text: msg.content, iconSize: 12),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (msg.isOutgoing) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_upward, size: 16, color: colors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildSendPanel(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageCtrl,
                enabled: _connected,
                decoration: const InputDecoration(
                  hintText: 'Type a message...',
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: _connected ? _sendMessage : null,
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
  }
}

class _Message {
  final String content;
  final DateTime timestamp;
  final bool isOutgoing;
  final bool isSystem;

  _Message({
    required this.content,
    required this.timestamp,
    required this.isOutgoing,
    this.isSystem = false,
  });
}
