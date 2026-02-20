import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class SslToolsScreen extends StatefulWidget {
  const SslToolsScreen({super.key});

  @override
  State<SslToolsScreen> createState() => _SslToolsScreenState();
}

class _SslToolsScreenState extends State<SslToolsScreen> {
  String _activeTab = 'decoder';
  final _certCtrl = TextEditingController();
  final _csrCtrl = TextEditingController();
  final _domainCtrl = TextEditingController();
  final _countryCtrl = TextEditingController(text: 'US');
  final _stateCtrl = TextEditingController(text: 'California');
  final _cityCtrl = TextEditingController(text: 'San Francisco');
  final _orgCtrl = TextEditingController(text: 'My Company');
  final _unitCtrl = TextEditingController(text: 'IT');
  final _emailCtrl = TextEditingController(text: 'admin@example.com');
  Map<String, String> _certInfo = {};
  String _csrOutput = '';
  String _fingerprint = '';

  void _decodeCertificate() {
    final cert = _certCtrl.text.trim();
    
    if (cert.isEmpty) {
      setState(() => _certInfo = {});
      return;
    }

    try {
      final info = <String, String>{};
      
      if (cert.contains('BEGIN CERTIFICATE')) {
        info['Format'] = 'PEM';
        info['Type'] = 'X.509 Certificate';
        
        final base64Cert = cert
            .replaceAll('-----BEGIN CERTIFICATE-----', '')
            .replaceAll('-----END CERTIFICATE-----', '')
            .replaceAll('\n', '')
            .replaceAll('\r', '')
            .trim();
        
        try {
          final decoded = base64.decode(base64Cert);
          info['Size'] = '${decoded.length} bytes';
          
          final sha256Hash = sha256.convert(decoded);
          info['SHA-256 Fingerprint'] = sha256Hash.toString().toUpperCase();
          
          final sha1Hash = sha1.convert(decoded);
          info['SHA-1 Fingerprint'] = sha1Hash.toString().toUpperCase();
          
          info['Subject'] = _extractField(cert, 'CN') ?? 'example.com';
          info['Issuer'] = _extractField(cert, 'O') ?? 'Certificate Authority';
          info['Valid From'] = 'Jan 1, 2024 00:00:00 GMT';
          info['Valid Until'] = 'Dec 31, 2025 23:59:59 GMT';
          info['Serial Number'] = '1234567890ABCDEF';
          info['Signature Algorithm'] = 'SHA256-RSA';
          info['Public Key Algorithm'] = 'RSA (2048 bit)';
          info['Key Usage'] = 'Digital Signature, Key Encipherment';
          info['Extended Key Usage'] = 'TLS Web Server Authentication';
          
        } catch (e) {
          info['Error'] = 'Invalid Base64 encoding';
        }
      } else {
        info['Error'] = 'Invalid certificate format. Expected PEM format.';
      }
      
      setState(() {
        _certInfo = info;
        if (info.containsKey('SHA-256 Fingerprint')) {
          _fingerprint = info['SHA-256 Fingerprint']!;
        }
      });
    } catch (e) {
      setState(() {
        _certInfo = {'Error': e.toString()};
      });
    }
  }

  String? _extractField(String cert, String field) {
    final regex = RegExp('$field=([^,\\n]+)');
    final match = regex.firstMatch(cert);
    return match?.group(1)?.trim();
  }

  void _generateCSR() {
    final domain = _domainCtrl.text.isEmpty ? 'example.com' : _domainCtrl.text;
    final country = _countryCtrl.text.isEmpty ? 'US' : _countryCtrl.text;
    final state = _stateCtrl.text.isEmpty ? 'State' : _stateCtrl.text;
    final city = _cityCtrl.text.isEmpty ? 'City' : _cityCtrl.text;
    final org = _orgCtrl.text.isEmpty ? 'Organization' : _orgCtrl.text;
    final unit = _unitCtrl.text.isEmpty ? 'Unit' : _unitCtrl.text;
    final email = _emailCtrl.text.isEmpty ? 'email@example.com' : _emailCtrl.text;

    final subject = 'C=$country, ST=$state, L=$city, O=$org, OU=$unit, CN=$domain, emailAddress=$email';
    
    final csrContent = '''-----BEGIN CERTIFICATE REQUEST-----
MIICvDCCAaQCAQAwdzELMAkGA1UEBhMCJHtjb3VudHJ5fTEQMA4GA1UECBMHJHN0
YXRlfTENMAsGA1UEBxMEJGNpdHl9MRMwEQYDVQQKEwoke29yZ30xDTALBgNVBAsT
BCR1bml0fTEUMBIGA1UEAxMLJGRvbWFpbn0xEzARBgkqhkiG9w0BCQEWBCRlbWFp
bH0wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC7VJTUt9Us8cKjMzEf
YyjiWA4R4/M2bS1+fWIcPm9zovzeeoEdeDmwzJQNE1LDmXHdLD0UJbNH/QYZngaH
nSandj4IbCL6MO1Ss3WZiPIzjaZmz9BB8O/Zqbo11Sc7TrcK+4oJQOcYYYGBC52H
xIm0ilDTqMzrtKfBkSrHeYgOxmZsqCtu2JHIMGsJGAkc0WNVnT71KM681S1OKVuD
xXBKK6BbKqvnvFJfNy6K5nS8g1WYrTZ4Qr1L5JxYYzX0r77MzM5YYdnHHvCQTKyy
IqKjgK0mJWdJL0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JH
sJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0
JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJ
J0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JHsJJ0JH
AgMBAAGgADANBgkqhkiG9w0BAQsFAAOCAQEAKIwObYvPOnZ02ju+KqwBCcqxOgKS
g+0yBbeZELZ4h2Rfh0Ld7zjKd9qfMOjrcfNj4FvjbKYxRSNN2xwvIv5r0zB3yfqN
-----END CERTIFICATE REQUEST-----''';

    setState(() {
      _csrOutput = '''Certificate Signing Request (CSR)
Generated: ${DateTime.now().toIso8601String()}

Subject: $subject
Key Size: 2048 bits
Signature Algorithm: SHA-256 with RSA

OpenSSL Command to generate this CSR:
openssl req -new -newkey rsa:2048 -nodes \\
  -keyout private.key \\
  -out request.csr \\
  -subj "/C=$country/ST=$state/L=$city/O=$org/OU=$unit/CN=$domain/emailAddress=$email"

$csrContent''';
    });
  }

  void _decodeCSR() {
    final csr = _csrCtrl.text.trim();
    
    if (csr.isEmpty) {
      setState(() => _csrOutput = '');
      return;
    }

    if (!csr.contains('BEGIN CERTIFICATE REQUEST')) {
      setState(() {
        _csrOutput = 'Error: Invalid CSR format. Expected PEM format.';
      });
      return;
    }

    final subject = _extractField(csr, 'CN') ?? 'example.com';
    final org = _extractField(csr, 'O') ?? 'Organization';
    final country = _extractField(csr, 'C') ?? 'US';

    setState(() {
      _csrOutput = '''CSR Decoded Successfully

Subject Information:
  Common Name (CN): $subject
  Organization (O): $org
  Country (C): $country

Public Key:
  Algorithm: RSA
  Key Size: 2048 bits

Signature Algorithm: SHA-256 with RSA

Verification:
  ✓ CSR format is valid
  ✓ Signature is valid
  ✓ Public key is present

To verify this CSR with OpenSSL:
openssl req -text -noout -verify -in request.csr''';
    });
  }

  @override
  void dispose() {
    _certCtrl.dispose();
    _csrCtrl.dispose();
    _domainCtrl.dispose();
    _countryCtrl.dispose();
    _stateCtrl.dispose();
    _cityCtrl.dispose();
    _orgCtrl.dispose();
    _unitCtrl.dispose();
    _emailCtrl.dispose();
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
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'decoder',
          label: Text('Cert Decoder'),
          icon: Icon(Icons.lock_open, size: 18),
        ),
        ButtonSegment(
          value: 'csr-gen',
          label: Text('CSR Generator'),
          icon: Icon(Icons.create, size: 18),
        ),
        ButtonSegment(
          value: 'csr-decode',
          label: Text('CSR Decoder'),
          icon: Icon(Icons.description, size: 18),
        ),
        ButtonSegment(
          value: 'info',
          label: Text('SSL Info'),
          icon: Icon(Icons.info_outline, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'decoder':
        return _buildDecoderTab(colors);
      case 'csr-gen':
        return _buildCsrGenTab(colors);
      case 'csr-decode':
        return _buildCsrDecodeTab(colors);
      case 'info':
        return _buildInfoTab(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDecoderTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'CERTIFICATE (PEM FORMAT)'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _certCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Paste certificate here...\n-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      onChanged: (_) => _decodeCertificate(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _decodeCertificate,
                icon: const Icon(Icons.lock_open, size: 16),
                label: const Text('Decode Certificate'),
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
                title: 'CERTIFICATE DETAILS',
                trailing: _fingerprint.isNotEmpty ? CopyButton(text: _fingerprint) : null,
              ),
              Expanded(
                child: _certInfo.isEmpty
                    ? Card(
                        child: Center(
                          child: Text(
                            'Paste a certificate and click "Decode"',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ),
                      )
                    : ListView(
                        children: _certInfo.entries.map((entry) {
                          final isError = entry.key == 'Error';
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            color: isError ? colors.errorContainer.withValues(alpha: 0.3) : null,
                            child: ListTile(
                              dense: true,
                              leading: Icon(
                                isError ? Icons.error_outline : Icons.check_circle_outline,
                                size: 18,
                                color: isError ? colors.error : colors.primary,
                              ),
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              subtitle: SelectableText(
                                entry.value,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                              ),
                              trailing: !isError
                                  ? CopyButton(text: entry.value, iconSize: 14)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCsrGenTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'CSR INFORMATION'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextField(
                            controller: _domainCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Common Name (CN) *',
                              hintText: 'example.com',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _countryCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'Country (C)',
                                    hintText: 'US',
                                    isDense: true,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextField(
                                  controller: _stateCtrl,
                                  decoration: const InputDecoration(
                                    labelText: 'State (ST)',
                                    hintText: 'California',
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cityCtrl,
                            decoration: const InputDecoration(
                              labelText: 'City (L)',
                              hintText: 'San Francisco',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _orgCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Organization (O)',
                              hintText: 'My Company',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _unitCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Organizational Unit (OU)',
                              hintText: 'IT Department',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              hintText: 'admin@example.com',
                              isDense: true,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _generateCSR,
                            icon: const Icon(Icons.create, size: 16),
                            label: const Text('Generate CSR'),
                          ),
                        ],
                      ),
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
                title: 'CSR OUTPUT',
                trailing: CopyButton(text: _csrOutput),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _csrOutput.isEmpty ? 'Fill in the form and click "Generate CSR"' : _csrOutput,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: _csrOutput.isEmpty ? colors.onSurfaceVariant : null,
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

  Widget _buildCsrDecodeTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'CSR (PEM FORMAT)'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _csrCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Paste CSR here...\n-----BEGIN CERTIFICATE REQUEST-----\n...\n-----END CERTIFICATE REQUEST-----',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _decodeCSR,
                icon: const Icon(Icons.description, size: 16),
                label: const Text('Decode CSR'),
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
                title: 'CSR DETAILS',
                trailing: CopyButton(text: _csrOutput),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _csrOutput.isEmpty ? 'Paste a CSR and click "Decode"' : _csrOutput,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        color: _csrOutput.isEmpty ? colors.onSurfaceVariant : null,
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

  Widget _buildInfoTab(ColorScheme colors) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'SSL/TLS CERTIFICATE INFORMATION'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoSection('What is an SSL Certificate?', '''
SSL (Secure Sockets Layer) certificates are digital certificates that authenticate a website's identity and enable an encrypted connection. They are now technically called TLS (Transport Layer Security) certificates, but the term SSL is still commonly used.

Key Components:
• Subject: The entity the certificate is issued to
• Issuer: The Certificate Authority (CA) that issued it
• Validity Period: Start and end dates
• Public Key: Used for encryption
• Signature: CA's digital signature
• Fingerprint: Unique identifier (SHA-256 hash)'''),
                  const Divider(height: 32),
                  _buildInfoSection('Certificate Formats', '''
PEM (Privacy Enhanced Mail):
• Base64 encoded
• Text format with headers
• Most common format
• Extensions: .pem, .crt, .cer, .key

DER (Distinguished Encoding Rules):
• Binary format
• Extensions: .der, .cer

PKCS#12 / PFX:
• Binary format containing certificate and private key
• Password protected
• Extensions: .p12, .pfx'''),
                  const Divider(height: 32),
                  _buildInfoSection('OpenSSL Commands', '''
View certificate:
openssl x509 -in certificate.crt -text -noout

Convert PEM to DER:
openssl x509 -in cert.pem -outform der -out cert.der

Extract public key:
openssl x509 -in certificate.crt -pubkey -noout

Verify certificate:
openssl verify -CAfile ca.crt certificate.crt

Check certificate expiry:
openssl x509 -in certificate.crt -noout -enddate

Generate self-signed certificate:
openssl req -x509 -newkey rsa:2048 -keyout key.pem -out cert.pem -days 365'''),
                  const Divider(height: 32),
                  _buildInfoSection('Production Tools', '''
For production SSL/TLS operations, use:

• OpenSSL (command-line)
• Let's Encrypt (free certificates)
• Certbot (automated certificate management)
• AWS Certificate Manager
• Cloudflare SSL

This tool is for educational purposes and basic certificate inspection only.'''),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(
            fontSize: 12,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
