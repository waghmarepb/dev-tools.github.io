import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class DeepLinkTesterScreen extends StatefulWidget {
  const DeepLinkTesterScreen({super.key});

  @override
  State<DeepLinkTesterScreen> createState() => _DeepLinkTesterScreenState();
}

class _DeepLinkTesterScreenState extends State<DeepLinkTesterScreen> {
  String _activeTab = 'builder';
  
  // URL Scheme Builder
  final _schemeCtrl = TextEditingController(text: 'myapp');
  final _hostCtrl = TextEditingController(text: 'open');
  final _pathCtrl = TextEditingController(text: '/product');
  final List<MapEntry<String, String>> _params = [];
  String _builtUrl = '';
  
  // Universal Links
  final _universalUrlCtrl = TextEditingController(text: 'https://myapp.com/product/123');
  Map<String, dynamic>? _universalLinkInfo;
  
  // App Links (Android)
  final _appLinkCtrl = TextEditingController(text: 'https://myapp.com/product/123');
  Map<String, dynamic>? _appLinkInfo;
  
  // Deep Link Tester
  final _testUrlCtrl = TextEditingController(text: 'myapp://open/product?id=123&name=test');
  Map<String, dynamic>? _parsedLink;

  @override
  void initState() {
    super.initState();
    _buildUrl();
  }

  @override
  void dispose() {
    _schemeCtrl.dispose();
    _hostCtrl.dispose();
    _pathCtrl.dispose();
    _universalUrlCtrl.dispose();
    _appLinkCtrl.dispose();
    _testUrlCtrl.dispose();
    super.dispose();
  }

  void _buildUrl() {
    final scheme = _schemeCtrl.text.trim();
    final host = _hostCtrl.text.trim();
    final path = _pathCtrl.text.trim();
    
    if (scheme.isEmpty) {
      setState(() => _builtUrl = '');
      return;
    }
    
    final buffer = StringBuffer(scheme);
    buffer.write('://');
    
    if (host.isNotEmpty) {
      buffer.write(host);
    }
    
    if (path.isNotEmpty) {
      if (!path.startsWith('/')) {
        buffer.write('/');
      }
      buffer.write(path);
    }
    
    if (_params.isNotEmpty) {
      buffer.write('?');
      buffer.write(_params.map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}').join('&'));
    }
    
    setState(() => _builtUrl = buffer.toString());
  }

  void _addParameter() {
    setState(() {
      _params.add(const MapEntry('key', 'value'));
    });
    _buildUrl();
  }

  void _removeParameter(int index) {
    setState(() {
      _params.removeAt(index);
    });
    _buildUrl();
  }

  void _updateParameter(int index, String key, String value) {
    setState(() {
      _params[index] = MapEntry(key, value);
    });
    _buildUrl();
  }

  void _parseUniversalLink() {
    final url = _universalUrlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _universalLinkInfo = null);
      return;
    }

    try {
      final uri = Uri.parse(url);
      
      setState(() {
        _universalLinkInfo = {
          'Valid': uri.isAbsolute && (uri.scheme == 'https' || uri.scheme == 'http'),
          'Scheme': uri.scheme,
          'Host': uri.host,
          'Port': uri.hasPort ? uri.port.toString() : 'Default',
          'Path': uri.path.isEmpty ? '/' : uri.path,
          'Query': uri.query.isEmpty ? 'None' : uri.query,
          'Fragment': uri.fragment.isEmpty ? 'None' : uri.fragment,
          'Parameters': uri.queryParameters.isEmpty ? {} : uri.queryParameters,
          'Path Segments': uri.pathSegments,
        };
      });
    } catch (e) {
      setState(() {
        _universalLinkInfo = {'Error': e.toString()};
      });
    }
  }

  void _parseAppLink() {
    final url = _appLinkCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _appLinkInfo = null);
      return;
    }

    try {
      final uri = Uri.parse(url);
      
      final isValid = uri.isAbsolute && uri.scheme == 'https';
      final hasAssetLinks = uri.host.isNotEmpty;
      
      setState(() {
        _appLinkInfo = {
          'Valid App Link': isValid,
          'Scheme': uri.scheme,
          'Host': uri.host,
          'Path': uri.path.isEmpty ? '/' : uri.path,
          'Requires assetlinks.json': hasAssetLinks,
          'Asset Links URL': hasAssetLinks ? 'https://${uri.host}/.well-known/assetlinks.json' : 'N/A',
          'Query Parameters': uri.queryParameters.isEmpty ? {} : uri.queryParameters,
          'Path Segments': uri.pathSegments,
          'Verification': isValid ? 'Must verify domain ownership' : 'Invalid HTTPS URL',
        };
      });
    } catch (e) {
      setState(() {
        _appLinkInfo = {'Error': e.toString()};
      });
    }
  }

  void _parseDeepLink() {
    final url = _testUrlCtrl.text.trim();
    if (url.isEmpty) {
      setState(() => _parsedLink = null);
      return;
    }

    try {
      final uri = Uri.parse(url);
      
      final isCustomScheme = uri.scheme != 'http' && uri.scheme != 'https';
      
      setState(() {
        _parsedLink = {
          'Type': isCustomScheme ? 'Custom URL Scheme' : 'Universal/App Link',
          'Valid': uri.isAbsolute,
          'Scheme': uri.scheme,
          'Host': uri.host.isEmpty ? 'None' : uri.host,
          'Path': uri.path.isEmpty ? '/' : uri.path,
          'Query String': uri.query.isEmpty ? 'None' : uri.query,
          'Fragment': uri.fragment.isEmpty ? 'None' : uri.fragment,
          'Parameters': uri.queryParameters,
          'Path Segments': uri.pathSegments,
          'Full URL': uri.toString(),
        };
      });
    } catch (e) {
      setState(() {
        _parsedLink = {'Error': e.toString()};
      });
    }
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
              child: _buildTabContent(colors),
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
          value: 'builder',
          label: Text('URL Scheme Builder'),
          icon: Icon(Icons.build, size: 18),
        ),
        ButtonSegment(
          value: 'universal',
          label: Text('Universal Links'),
          icon: Icon(Icons.link, size: 18),
        ),
        ButtonSegment(
          value: 'applinks',
          label: Text('App Links'),
          icon: Icon(Icons.android, size: 18),
        ),
        ButtonSegment(
          value: 'tester',
          label: Text('Deep Link Tester'),
          icon: Icon(Icons.bug_report, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildTabContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'builder':
        return _buildUrlSchemeBuilder(colors);
      case 'universal':
        return _buildUniversalLinksTab(colors);
      case 'applinks':
        return _buildAppLinksTab(colors);
      case 'tester':
        return _buildTesterTab(colors);
      default:
        return _buildUrlSchemeBuilder(colors);
    }
  }

  Widget _buildUrlSchemeBuilder(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'URL SCHEME BUILDER'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _schemeCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Scheme (e.g., myapp)',
                          hintText: 'myapp',
                          prefixIcon: Icon(Icons.label),
                        ),
                        onChanged: (_) => _buildUrl(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _hostCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Host (optional)',
                          hintText: 'open',
                          prefixIcon: Icon(Icons.dns),
                        ),
                        onChanged: (_) => _buildUrl(),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _pathCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Path (optional)',
                          hintText: '/product/123',
                          prefixIcon: Icon(Icons.route),
                        ),
                        onChanged: (_) => _buildUrl(),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Text(
                            'Query Parameters',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            onPressed: _addParameter,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Parameter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_params.isEmpty)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              'No parameters added',
                              style: TextStyle(
                                color: colors.onSurfaceVariant,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        )
                      else
                        ..._params.asMap().entries.map((entry) {
                          final index = entry.key;
                          final param = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Key',
                                      isDense: true,
                                    ),
                                    controller: TextEditingController(text: param.key)
                                      ..selection = TextSelection.collapsed(offset: param.key.length),
                                    onChanged: (v) => _updateParameter(index, v, param.value),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    decoration: const InputDecoration(
                                      labelText: 'Value',
                                      isDense: true,
                                    ),
                                    controller: TextEditingController(text: param.value)
                                      ..selection = TextSelection.collapsed(offset: param.value.length),
                                    onChanged: (v) => _updateParameter(index, param.key, v),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, size: 20),
                                  onPressed: () => _removeParameter(index),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ],
                            ),
                          );
                        }),
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
                title: 'GENERATED URL',
                trailing: _builtUrl.isNotEmpty ? CopyButton(text: _builtUrl) : null,
              ),
              Card(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_builtUrl.isEmpty)
                        Center(
                          child: Text(
                            'Enter a scheme to generate URL',
                            style: TextStyle(
                              color: colors.onSurfaceVariant,
                              fontSize: 13,
                            ),
                          ),
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: SelectableText(
                            _builtUrl,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildInfoSection('iOS Configuration', colors, [
                          'Add to Info.plist:',
                          '<key>CFBundleURLTypes</key>',
                          '<array>',
                          '  <dict>',
                          '    <key>CFBundleURLSchemes</key>',
                          '    <array>',
                          '      <string>${_schemeCtrl.text}</string>',
                          '    </array>',
                          '  </dict>',
                          '</array>',
                        ]),
                        const SizedBox(height: 16),
                        _buildInfoSection('Android Configuration', colors, [
                          'Add to AndroidManifest.xml:',
                          '<intent-filter>',
                          '  <action android:name="android.intent.action.VIEW" />',
                          '  <category android:name="android.intent.category.DEFAULT" />',
                          '  <category android:name="android.intent.category.BROWSABLE" />',
                          '  <data android:scheme="${_schemeCtrl.text}" />',
                          '</intent-filter>',
                        ]),
                        const SizedBox(height: 16),
                        _buildInfoSection('Flutter Handling', colors, [
                          'Use uni_links or app_links package:',
                          '',
                          'import \'package:uni_links/uni_links.dart\';',
                          '',
                          'StreamSubscription? _sub;',
                          '',
                          '_sub = uriLinkStream.listen((Uri? uri) {',
                          '  // Handle deep link',
                          '  print(uri?.path);',
                          '  print(uri?.queryParameters);',
                          '});',
                        ]),
                      ],
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

  Widget _buildUniversalLinksTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'UNIVERSAL LINKS (iOS)'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _universalUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Universal Link URL',
                          hintText: 'https://myapp.com/product/123',
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (_) => _parseUniversalLink(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _parseUniversalLink,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Parse Universal Link'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection('Requirements', colors, [
                        '✓ Must use HTTPS',
                        '✓ Domain must be verified',
                        '✓ apple-app-site-association file required',
                        '✓ File must be at: https://domain/.well-known/apple-app-site-association',
                      ]),
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
              const SectionHeader(title: 'PARSED INFORMATION'),
              if (_universalLinkInfo != null) ...[
                Expanded(
                  child: ListView(
                    children: _universalLinkInfo!.entries.map((entry) {
                      if (entry.value is Map) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            children: (entry.value as Map).entries.map((param) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                title: Text(
                                  param.key.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Text(
                                  param.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else if (entry.value is List) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.list, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            children: (entry.value as List).asMap().entries.map((item) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                leading: Text(
                                  '[${item.key}]',
                                  style: TextStyle(fontSize: 11, color: colors.primary),
                                ),
                                title: Text(
                                  item.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              entry.key == 'Valid' && entry.value == true
                                  ? Icons.check_circle
                                  : entry.key == 'Valid' && entry.value == false
                                      ? Icons.error
                                      : Icons.label_outline,
                              size: 18,
                              color: entry.key == 'Valid' && entry.value == true
                                  ? Colors.green
                                  : entry.key == 'Valid' && entry.value == false
                                      ? Colors.red
                                      : colors.primary,
                            ),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            trailing: Text(
                              entry.value.toString(),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Enter a URL and click Parse',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
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

  Widget _buildAppLinksTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'APP LINKS (Android)'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _appLinkCtrl,
                        decoration: const InputDecoration(
                          labelText: 'App Link URL',
                          hintText: 'https://myapp.com/product/123',
                          prefixIcon: Icon(Icons.android),
                        ),
                        onChanged: (_) => _parseAppLink(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _parseAppLink,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: const Text('Parse App Link'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection('Requirements', colors, [
                        '✓ Must use HTTPS',
                        '✓ Domain must be verified',
                        '✓ assetlinks.json file required',
                        '✓ File must be at: https://domain/.well-known/assetlinks.json',
                        '✓ autoVerify="true" in intent-filter',
                      ]),
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
              const SectionHeader(title: 'PARSED INFORMATION'),
              if (_appLinkInfo != null) ...[
                Expanded(
                  child: ListView(
                    children: _appLinkInfo!.entries.map((entry) {
                      if (entry.value is Map) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            children: (entry.value as Map).entries.map((param) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                title: Text(
                                  param.key.toString(),
                                  style: const TextStyle(fontSize: 11),
                                ),
                                trailing: Text(
                                  param.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else if (entry.value is List) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.list, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            children: (entry.value as List).asMap().entries.map((item) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                leading: Text(
                                  '[${item.key}]',
                                  style: TextStyle(fontSize: 11, color: colors.primary),
                                ),
                                title: Text(
                                  item.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              entry.key.contains('Valid') && entry.value == true
                                  ? Icons.check_circle
                                  : entry.key.contains('Valid') && entry.value == false
                                      ? Icons.error
                                      : Icons.label_outline,
                              size: 18,
                              color: entry.key.contains('Valid') && entry.value == true
                                  ? Colors.green
                                  : entry.key.contains('Valid') && entry.value == false
                                      ? Colors.red
                                      : colors.primary,
                            ),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            trailing: Flexible(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Enter a URL and click Parse',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
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

  Widget _buildTesterTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'DEEP LINK TESTER'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _testUrlCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Deep Link URL',
                          hintText: 'myapp://open/product?id=123',
                          prefixIcon: Icon(Icons.link),
                        ),
                        onChanged: (_) => _parseDeepLink(),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _parseDeepLink,
                          icon: const Icon(Icons.bug_report, size: 18),
                          label: const Text('Test Deep Link'),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildInfoSection('Test Examples', colors, [
                        'Custom Scheme:',
                        'myapp://open/product?id=123',
                        '',
                        'Universal Link (iOS):',
                        'https://myapp.com/product/123',
                        '',
                        'App Link (Android):',
                        'https://myapp.com/product/123',
                        '',
                        'With Fragment:',
                        'myapp://open/page#section',
                      ]),
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
              const SectionHeader(title: 'PARSED RESULT'),
              if (_parsedLink != null) ...[
                Expanded(
                  child: ListView(
                    children: _parsedLink!.entries.map((entry) {
                      if (entry.value is Map) {
                        final params = entry.value as Map;
                        if (params.isEmpty) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              trailing: const Text(
                                'None',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${params.length} parameter(s)',
                              style: const TextStyle(fontSize: 11),
                            ),
                            children: params.entries.map((param) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                title: Text(
                                  param.key.toString(),
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                                trailing: Text(
                                  param.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else if (entry.value is List) {
                        final list = entry.value as List;
                        if (list.isEmpty) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              dense: true,
                              leading: Icon(Icons.list, size: 18, color: colors.primary),
                              title: Text(
                                entry.key,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                              trailing: const Text(
                                'None',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          );
                        }
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ExpansionTile(
                            leading: Icon(Icons.list, size: 18, color: colors.primary),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              '${list.length} segment(s)',
                              style: const TextStyle(fontSize: 11),
                            ),
                            children: list.asMap().entries.map((item) {
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 4),
                                leading: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colors.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${item.key}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  item.value.toString(),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            dense: true,
                            leading: Icon(
                              entry.key == 'Valid' && entry.value == true
                                  ? Icons.check_circle
                                  : entry.key == 'Valid' && entry.value == false
                                      ? Icons.error
                                      : Icons.label_outline,
                              size: 18,
                              color: entry.key == 'Valid' && entry.value == true
                                  ? Colors.green
                                  : entry.key == 'Valid' && entry.value == false
                                      ? Colors.red
                                      : colors.primary,
                            ),
                            title: Text(
                              entry.key,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                            trailing: Flexible(
                              child: Text(
                                entry.value.toString(),
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      }
                    }).toList(),
                  ),
                ),
              ] else
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(48),
                    child: Center(
                      child: Text(
                        'Enter a deep link URL to test',
                        style: TextStyle(
                          color: colors.onSurfaceVariant,
                          fontSize: 13,
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

  Widget _buildInfoSection(String title, ColorScheme colors, List<String> lines) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...lines.map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  line,
                  style: TextStyle(
                    fontFamily: line.contains('://') || line.contains('<') ? 'monospace' : null,
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
