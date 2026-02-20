import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class HashGeneratorScreen extends StatefulWidget {
  const HashGeneratorScreen({super.key});

  @override
  State<HashGeneratorScreen> createState() => _HashGeneratorScreenState();
}

class _HashGeneratorScreenState extends State<HashGeneratorScreen> {
  final _inputCtrl = TextEditingController();

  String get _md5Hash =>
      _inputCtrl.text.isEmpty ? '' : md5.convert(utf8.encode(_inputCtrl.text)).toString();

  String get _sha1Hash =>
      _inputCtrl.text.isEmpty ? '' : sha1.convert(utf8.encode(_inputCtrl.text)).toString();

  String get _sha256Hash =>
      _inputCtrl.text.isEmpty ? '' : sha256.convert(utf8.encode(_inputCtrl.text)).toString();

  String get _sha512Hash =>
      _inputCtrl.text.isEmpty ? '' : sha512.convert(utf8.encode(_inputCtrl.text)).toString();

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Hash Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'INPUT'),
            TextField(
              controller: _inputCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: const InputDecoration(
                hintText: 'Enter text to hash...',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'HASHES'),
            Expanded(
              child: ListView(
                children: [
                  _hashCard('MD5', _md5Hash, colors),
                  _hashCard('SHA-1', _sha1Hash, colors),
                  _hashCard('SHA-256', _sha256Hash, colors),
                  _hashCard('SHA-512', _sha512Hash, colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hashCard(String algorithm, String hash, ColorScheme colors) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    algorithm,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const Spacer(),
                CopyButton(text: hash),
              ],
            ),
            const SizedBox(height: 10),
            SelectableText(
              hash.isEmpty ? 'Hash will appear here...' : hash,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                color: hash.isEmpty
                    ? colors.onSurfaceVariant.withValues(alpha: 0.5)
                    : colors.onSurface,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
