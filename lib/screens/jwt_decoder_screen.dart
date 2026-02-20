import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class JwtDecoderScreen extends StatefulWidget {
  const JwtDecoderScreen({super.key});

  @override
  State<JwtDecoderScreen> createState() => _JwtDecoderScreenState();
}

class _JwtDecoderScreenState extends State<JwtDecoderScreen> {
  final _tokenCtrl = TextEditingController();
  final _secretCtrl = TextEditingController();
  Map<String, dynamic>? _header;
  Map<String, dynamic>? _payload;
  String? _signature;
  String? _error;
  bool _isExpired = false;
  DateTime? _expiryDate;
  DateTime? _issuedAt;
  DateTime? _notBefore;

  void _decode() {
    if (_tokenCtrl.text.trim().isEmpty) {
      setState(() {
        _header = null;
        _payload = null;
        _signature = null;
        _error = null;
        _isExpired = false;
        _expiryDate = null;
        _issuedAt = null;
        _notBefore = null;
      });
      return;
    }

    try {
      final parts = _tokenCtrl.text.trim().split('.');
      if (parts.length != 3) {
        throw const FormatException('Invalid JWT format. Expected 3 parts separated by dots.');
      }

      final headerJson = utf8.decode(base64Url.decode(base64Url.normalize(parts[0])));
      final payloadJson = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));

      final header = json.decode(headerJson) as Map<String, dynamic>;
      final payload = json.decode(payloadJson) as Map<String, dynamic>;
      final signature = parts[2];

      DateTime? exp;
      DateTime? iat;
      DateTime? nbf;
      bool expired = false;

      if (payload.containsKey('exp')) {
        exp = DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
        expired = exp.isBefore(DateTime.now());
      }

      if (payload.containsKey('iat')) {
        iat = DateTime.fromMillisecondsSinceEpoch(payload['iat'] * 1000);
      }

      if (payload.containsKey('nbf')) {
        nbf = DateTime.fromMillisecondsSinceEpoch(payload['nbf'] * 1000);
      }

      setState(() {
        _header = header;
        _payload = payload;
        _signature = signature;
        _error = null;
        _isExpired = expired;
        _expiryDate = exp;
        _issuedAt = iat;
        _notBefore = nbf;
      });
    } catch (e) {
      setState(() {
        _header = null;
        _payload = null;
        _signature = null;
        _error = e.toString();
        _isExpired = false;
        _expiryDate = null;
        _issuedAt = null;
        _notBefore = null;
      });
    }
  }

  bool _verifySignature() {
    if (_secretCtrl.text.isEmpty || _header == null || _payload == null) {
      return false;
    }

    try {
      final parts = _tokenCtrl.text.trim().split('.');
      final data = '${parts[0]}.${parts[1]}';
      final algorithm = _header!['alg'] as String?;

      if (algorithm == null) return false;

      List<int> hash;
      switch (algorithm.toUpperCase()) {
        case 'HS256':
          final hmac = Hmac(sha256, utf8.encode(_secretCtrl.text));
          hash = hmac.convert(utf8.encode(data)).bytes;
          break;
        case 'HS384':
          final hmac = Hmac(sha384, utf8.encode(_secretCtrl.text));
          hash = hmac.convert(utf8.encode(data)).bytes;
          break;
        case 'HS512':
          final hmac = Hmac(sha512, utf8.encode(_secretCtrl.text));
          hash = hmac.convert(utf8.encode(data)).bytes;
          break;
        default:
          return false;
      }

      final expectedSignature = base64Url.encode(hash).replaceAll('=', '');
      return expectedSignature == _signature;
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _secretCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'JWT TOKEN'),
            TextField(
              controller: _tokenCtrl,
              maxLines: 4,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
              decoration: InputDecoration(
                hintText: 'Paste your JWT token here...',
                errorText: _error,
                errorMaxLines: 3,
              ),
              onChanged: (_) => _decode(),
            ),
            const SizedBox(height: 16),
            if (_header != null) ...[
              Row(
                children: [
                  if (_isExpired)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.red.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline, size: 16, color: Colors.red.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Token Expired',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (_expiryDate != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.shade300),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, size: 16, color: Colors.green.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'Valid Token',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: _header == null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.vpn_key_outlined, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
                          const SizedBox(height: 16),
                          Text(
                            'Paste a JWT token to decode',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  : ListView(
                      children: [
                        _buildInfoCards(theme, colors),
                        const SizedBox(height: 16),
                        _buildSection('HEADER', _header!, colors),
                        const SizedBox(height: 16),
                        _buildSection('PAYLOAD', _payload!, colors),
                        const SizedBox(height: 16),
                        _buildSignatureSection(colors),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCards(ThemeData theme, ColorScheme colors) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (_expiryDate != null)
          _buildInfoCard(
            'Expires',
            _formatDateTime(_expiryDate!),
            Icons.event_outlined,
            _isExpired ? Colors.red : colors.primary,
            colors,
          ),
        if (_issuedAt != null)
          _buildInfoCard(
            'Issued At',
            _formatDateTime(_issuedAt!),
            Icons.access_time_outlined,
            colors.primary,
            colors,
          ),
        if (_notBefore != null)
          _buildInfoCard(
            'Not Before',
            _formatDateTime(_notBefore!),
            Icons.schedule_outlined,
            colors.primary,
            colors,
          ),
        if (_header!.containsKey('alg'))
          _buildInfoCard(
            'Algorithm',
            _header!['alg'].toString(),
            Icons.security_outlined,
            colors.primary,
            colors,
          ),
        if (_header!.containsKey('typ'))
          _buildInfoCard(
            'Type',
            _header!['typ'].toString(),
            Icons.label_outlined,
            colors.primary,
            colors,
          ),
      ],
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color iconColor, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: colors.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Map<String, dynamic> data, ColorScheme colors) {
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: title,
          trailing: CopyButton(text: jsonStr),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          child: SelectableText(
            jsonStr,
            style: const TextStyle(
              fontFamily: 'monospace',
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignatureSection(ColorScheme colors) {
    final isHmac = _header!['alg']?.toString().toUpperCase().startsWith('HS') ?? false;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'SIGNATURE',
          trailing: CopyButton(text: _signature ?? ''),
        ),
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
              SelectableText(
                _signature ?? '',
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  wordSpacing: 4,
                ),
              ),
              if (isHmac) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
                Text(
                  'Verify Signature (HMAC)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _secretCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Enter secret key...',
                    isDense: true,
                  ),
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
                  onChanged: (_) => setState(() {}),
                ),
                if (_secretCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _verifySignature()
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _verifySignature()
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _verifySignature() ? Icons.check_circle : Icons.cancel,
                          color: _verifySignature()
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _verifySignature()
                              ? 'Signature verified successfully'
                              : 'Signature verification failed',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _verifySignature()
                                ? Colors.green.shade700
                                : Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ] else ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.tertiary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Signature verification only supports HMAC algorithms (HS256, HS384, HS512)',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onTertiaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.toLocal().toString().substring(0, 19)} (${_timeAgo(dt)})';
  }

  String _timeAgo(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    
    if (diff.isNegative) {
      final absDiff = dt.difference(now);
      if (absDiff.inDays > 0) return 'in ${absDiff.inDays}d';
      if (absDiff.inHours > 0) return 'in ${absDiff.inHours}h';
      if (absDiff.inMinutes > 0) return 'in ${absDiff.inMinutes}m';
      return 'in ${absDiff.inSeconds}s';
    }
    
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return '${diff.inSeconds}s ago';
  }
}
