import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/tool_card.dart';
import 'regex_builder_screen.dart';
import 'regex_samples_screen.dart';
import 'json_formatter_screen.dart';
import 'base64_screen.dart';
import 'url_encoder_screen.dart';
import 'hash_generator_screen.dart';
import 'uuid_generator_screen.dart';
import 'timestamp_converter_screen.dart';
import 'lorem_ipsum_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('DevTools'),
            actions: [
              Consumer<ThemeProvider>(
                builder: (_, provider, __) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return IconButton(
                    icon: Icon(isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined),
                    tooltip: 'Toggle theme',
                    onPressed: provider.toggleTheme,
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
            sliver: SliverToBoxAdapter(
              child: _heroCard(context, colors),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Developer Utilities',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid.extent(
              maxCrossAxisExtent: 280,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: _tools(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heroCard(BuildContext context, ColorScheme colors) {
    return Card(
      color: colors.primaryContainer,
      child: InkWell(
        onTap: () => _navigate(context, const RegexBuilderScreen()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_fix_high_rounded,
                          color: colors.onPrimaryContainer,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Regex Builder',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colors.onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Build, test, and debug regular expressions with real-time '
                      'matching, group capture, and find & replace.',
                      style: TextStyle(
                        color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          onPressed: () =>
                              _navigate(context, const RegexBuilderScreen()),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                          label: const Text('Open Builder'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.onPrimaryContainer,
                            foregroundColor: colors.primaryContainer,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _navigate(context, const RegexSamplesScreen()),
                          icon: const Icon(Icons.collections_bookmark_outlined, size: 18),
                          label: const Text('Browse Samples'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colors.onPrimaryContainer,
                            side: BorderSide(
                              color: colors.onPrimaryContainer.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.onPrimaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '/.*/',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _tools(BuildContext context) {
    return [
      ToolCard(
        title: 'Regex Samples',
        description: '30+ ready-to-use patterns with test data',
        icon: Icons.collections_bookmark_rounded,
        iconColor: Colors.indigo,
        onTap: () => _navigate(context, const RegexSamplesScreen()),
      ),
      ToolCard(
        title: 'JSON Formatter',
        description: 'Format, validate, and minify JSON data',
        icon: Icons.data_object_rounded,
        iconColor: Colors.orange,
        onTap: () => _navigate(context, const JsonFormatterScreen()),
      ),
      ToolCard(
        title: 'Base64',
        description: 'Encode and decode Base64 strings',
        icon: Icons.lock_outline_rounded,
        iconColor: Colors.teal,
        onTap: () => _navigate(context, const Base64Screen()),
      ),
      ToolCard(
        title: 'URL Encoder',
        description: 'Encode and decode URL components',
        icon: Icons.link_rounded,
        iconColor: Colors.blue,
        onTap: () => _navigate(context, const UrlEncoderScreen()),
      ),
      ToolCard(
        title: 'Hash Generator',
        description: 'Generate MD5, SHA-1, SHA-256, SHA-512 hashes',
        icon: Icons.fingerprint_rounded,
        iconColor: Colors.deepPurple,
        onTap: () => _navigate(context, const HashGeneratorScreen()),
      ),
      ToolCard(
        title: 'UUID Generator',
        description: 'Generate v1 and v4 UUIDs with options',
        icon: Icons.key_rounded,
        iconColor: Colors.green,
        onTap: () => _navigate(context, const UuidGeneratorScreen()),
      ),
      ToolCard(
        title: 'Timestamp',
        description: 'Convert between Unix timestamps and dates',
        icon: Icons.schedule_rounded,
        iconColor: Colors.red,
        onTap: () => _navigate(context, const TimestampConverterScreen()),
      ),
      ToolCard(
        title: 'Lorem Ipsum',
        description: 'Generate placeholder text for designs',
        icon: Icons.text_fields_rounded,
        iconColor: Colors.brown,
        onTap: () => _navigate(context, const LoremIpsumScreen()),
      ),
    ];
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
