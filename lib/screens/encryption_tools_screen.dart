import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class EncryptionToolsScreen extends StatefulWidget {
  const EncryptionToolsScreen({super.key});

  @override
  State<EncryptionToolsScreen> createState() => _EncryptionToolsScreenState();
}

class _EncryptionToolsScreenState extends State<EncryptionToolsScreen> {
  String _activeTab = 'aes';
  final _inputCtrl = TextEditingController();
  final _keyCtrl = TextEditingController();
  final _ivCtrl = TextEditingController();
  String _output = '';
  String _mode = 'encrypt';

  void _processAes() {
    final input = _inputCtrl.text;
    final key = _keyCtrl.text;

    if (input.isEmpty) {
      setState(() => _output = '');
      return;
    }

    try {
      if (_mode == 'encrypt') {
        final bytes = utf8.encode(input);
        final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
        
        final xorResult = <int>[];
        for (var i = 0; i < bytes.length; i++) {
          xorResult.add(bytes[i] ^ keyBytes[i % keyBytes.length]);
        }
        
        setState(() => _output = base64.encode(xorResult));
      } else {
        final decoded = base64.decode(input);
        final keyBytes = utf8.encode(key.padRight(32, '0').substring(0, 32));
        
        final xorResult = <int>[];
        for (var i = 0; i < decoded.length; i++) {
          xorResult.add(decoded[i] ^ keyBytes[i % keyBytes.length]);
        }
        
        setState(() => _output = utf8.decode(xorResult));
      }
    } catch (e) {
      setState(() => _output = 'Error: ${e.toString()}');
    }
  }

  void _processRsa() {
    setState(() {
      _output = 'RSA encryption requires a full cryptographic library.\n\n'
          'For production use, consider:\n'
          '• OpenSSL command-line tools\n'
          '• pointycastle package (Dart)\n'
          '• Web Crypto API (JavaScript)\n\n'
          'Example RSA key generation:\n'
          'openssl genrsa -out private.pem 2048\n'
          'openssl rsa -in private.pem -pubout -out public.pem';
    });
  }

  void _processHash() {
    final input = _inputCtrl.text;
    if (input.isEmpty) {
      setState(() => _output = '');
      return;
    }

    final bytes = utf8.encode(input);
    final md5Hash = md5.convert(bytes);
    final sha1Hash = sha1.convert(bytes);
    final sha256Hash = sha256.convert(bytes);
    final sha512Hash = sha512.convert(bytes);

    setState(() {
      _output = 'MD5:\n$md5Hash\n\n'
          'SHA-1:\n$sha1Hash\n\n'
          'SHA-256:\n$sha256Hash\n\n'
          'SHA-512:\n$sha512Hash';
    });
  }

  void _processHmac() {
    final input = _inputCtrl.text;
    final key = _keyCtrl.text;

    if (input.isEmpty || key.isEmpty) {
      setState(() => _output = '');
      return;
    }

    final keyBytes = utf8.encode(key);
    final inputBytes = utf8.encode(input);

    final hmacSha256 = Hmac(sha256, keyBytes);
    final hmacSha512 = Hmac(sha512, keyBytes);

    final digest256 = hmacSha256.convert(inputBytes);
    final digest512 = hmacSha512.convert(inputBytes);

    setState(() {
      _output = 'HMAC-SHA256:\n$digest256\n\n'
          'HMAC-SHA512:\n$digest512';
    });
  }

  void _processBcrypt() {
    setState(() {
      _output = 'Bcrypt requires native implementation.\n\n'
          'For production use, consider:\n'
          '• bcrypt package (Node.js)\n'
          '• bcrypt package (Python)\n'
          '• bcrypt_hash package (Dart)\n\n'
          'Example usage (Node.js):\n'
          'const bcrypt = require(\'bcrypt\');\n'
          'const hash = await bcrypt.hash(password, 10);\n'
          'const match = await bcrypt.compare(password, hash);';
    });
  }

  void _processRot13() {
    final input = _inputCtrl.text;
    if (input.isEmpty) {
      setState(() => _output = '');
      return;
    }

    final result = input.split('').map((char) {
      final code = char.codeUnitAt(0);
      if (code >= 65 && code <= 90) {
        return String.fromCharCode(((code - 65 + 13) % 26) + 65);
      } else if (code >= 97 && code <= 122) {
        return String.fromCharCode(((code - 97 + 13) % 26) + 97);
      }
      return char;
    }).join();

    setState(() => _output = result);
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _keyCtrl.dispose();
    _ivCtrl.dispose();
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
            _buildTabs(colors),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'aes',
            label: Text('AES (XOR)'),
            icon: Icon(Icons.lock, size: 18),
          ),
          ButtonSegment(
            value: 'rsa',
            label: Text('RSA Info'),
            icon: Icon(Icons.key, size: 18),
          ),
          ButtonSegment(
            value: 'hash',
            label: Text('Hash'),
            icon: Icon(Icons.tag, size: 18),
          ),
          ButtonSegment(
            value: 'hmac',
            label: Text('HMAC'),
            icon: Icon(Icons.verified_user, size: 18),
          ),
          ButtonSegment(
            value: 'bcrypt',
            label: Text('Bcrypt Info'),
            icon: Icon(Icons.shield, size: 18),
          ),
          ButtonSegment(
            value: 'rot13',
            label: Text('ROT13'),
            icon: Icon(Icons.rotate_right, size: 18),
          ),
        ],
        selected: {_activeTab},
        onSelectionChanged: (v) {
          setState(() {
            _activeTab = v.first;
            _output = '';
          });
        },
      ),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'aes':
        return _buildAesTab(colors);
      case 'rsa':
        return _buildInfoTab(colors, 'RSA ENCRYPTION INFO', _processRsa);
      case 'hash':
        return _buildHashTab(colors);
      case 'hmac':
        return _buildHmacTab(colors);
      case 'bcrypt':
        return _buildInfoTab(colors, 'BCRYPT INFO', _processBcrypt);
      case 'rot13':
        return _buildRot13Tab(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildAesTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'INPUT',
                trailing: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'encrypt', label: Text('Encrypt')),
                    ButtonSegment(value: 'decrypt', label: Text('Decrypt')),
                  ],
                  selected: {_mode},
                  onSelectionChanged: (v) => setState(() => _mode = v.first),
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _keyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Encryption Key',
                          hintText: 'Enter secret key...',
                          isDense: true,
                        ),
                        onChanged: (_) => _processAes(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _inputCtrl,
                        decoration: InputDecoration(
                          labelText: _mode == 'encrypt' ? 'Text to Encrypt' : 'Base64 to Decrypt',
                          hintText: _mode == 'encrypt' ? 'Enter text...' : 'Enter base64...',
                          isDense: true,
                        ),
                        maxLines: 8,
                        onChanged: (_) => _processAes(),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                color: colors.errorContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber, size: 16, color: colors.error),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Note: This uses simple XOR encryption for demonstration. Use proper AES libraries for production.',
                          style: TextStyle(fontSize: 11, color: colors.onErrorContainer),
                        ),
                      ),
                    ],
                  ),
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
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output.isEmpty ? 'Output will appear here...' : _output,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _output.isEmpty ? colors.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHashTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'INPUT'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _inputCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Text to Hash',
                        hintText: 'Enter text...',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      onChanged: (_) => _processHash(),
                    ),
                  ),
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
                title: 'HASHES',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output.isEmpty ? 'Hashes will appear here...' : _output,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _output.isEmpty ? colors.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHmacTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'INPUT'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _keyCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Secret Key',
                          hintText: 'Enter secret key...',
                          isDense: true,
                        ),
                        onChanged: (_) => _processHmac(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _inputCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Message',
                          hintText: 'Enter message...',
                          isDense: true,
                        ),
                        maxLines: 8,
                        onChanged: (_) => _processHmac(),
                      ),
                    ],
                  ),
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
                title: 'HMAC SIGNATURES',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output.isEmpty ? 'HMAC signatures will appear here...' : _output,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _output.isEmpty ? colors.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRot13Tab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'INPUT'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _inputCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Text',
                        hintText: 'Enter text...',
                        isDense: true,
                        border: InputBorder.none,
                      ),
                      maxLines: null,
                      expands: true,
                      onChanged: (_) => _processRot13(),
                    ),
                  ),
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
                title: 'OUTPUT (ROT13)',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output.isEmpty ? 'ROT13 output will appear here...' : _output,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _output.isEmpty ? colors.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
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
                          'ROT13 is a simple letter substitution cipher. Running it twice returns the original text.',
                          style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTab(ColorScheme colors, String title, VoidCallback onLoad) {
    if (_output.isEmpty) {
      onLoad();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                _output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
