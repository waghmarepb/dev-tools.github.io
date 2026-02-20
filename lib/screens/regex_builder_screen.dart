import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/regex_pattern.dart';
import '../providers/regex_provider.dart';
import '../widgets/copy_button.dart';
import '../widgets/match_highlight_text.dart';
import '../widgets/section_header.dart';

class RegexBuilderScreen extends StatefulWidget {
  const RegexBuilderScreen({super.key});

  @override
  State<RegexBuilderScreen> createState() => _RegexBuilderScreenState();
}

class _RegexBuilderScreenState extends State<RegexBuilderScreen> {
  late final TextEditingController _patternCtrl;
  late final TextEditingController _testCtrl;
  late final TextEditingController _replaceCtrl;
  bool _showReplace = false;
  bool _showReference = false;

  @override
  void initState() {
    super.initState();
    final provider = context.read<RegexProvider>();
    _patternCtrl = TextEditingController(text: provider.pattern);
    _testCtrl = TextEditingController(text: provider.testString);
    _replaceCtrl = TextEditingController(text: provider.replaceWith);
    provider.addListener(_syncControllers);
  }

  void _syncControllers() {
    final provider = context.read<RegexProvider>();
    if (_patternCtrl.text != provider.pattern) {
      _patternCtrl.text = provider.pattern;
    }
    if (_testCtrl.text != provider.testString) {
      _testCtrl.text = provider.testString;
    }
    if (_replaceCtrl.text != provider.replaceWith) {
      _replaceCtrl.text = provider.replaceWith;
    }
  }

  @override
  void dispose() {
    context.read<RegexProvider>().removeListener(_syncControllers);
    _patternCtrl.dispose();
    _testCtrl.dispose();
    _replaceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex Builder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_outline_rounded),
            tooltip: 'Common Patterns',
            onPressed: () => _showCommonPatterns(context),
          ),
          IconButton(
            icon: Icon(_showReference
                ? Icons.menu_book_rounded
                : Icons.menu_book_outlined),
            tooltip: 'Quick Reference',
            onPressed: () => setState(() => _showReference = !_showReference),
          ),
          Consumer<RegexProvider>(
            builder: (_, provider, __) => IconButton(
              icon: const Icon(Icons.clear_all_rounded),
              tooltip: 'Clear All',
              onPressed: () {
                provider.clear();
                _patternCtrl.clear();
                _testCtrl.clear();
                _replaceCtrl.clear();
              },
            ),
          ),
        ],
      ),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: _buildMainContent(theme, colors),
          ),
          if (_showReference)
            Container(
              width: 300,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: colors.outlineVariant),
                ),
              ),
              child: _buildReferencePanel(theme, colors),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(ThemeData theme, ColorScheme colors) {
    return Consumer<RegexProvider>(
      builder: (context, provider, _) {
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildPatternInput(provider, colors),
            const SizedBox(height: 8),
            _buildFlagChips(provider, colors),
            const SizedBox(height: 20),
            _buildTestInput(provider),
            const SizedBox(height: 20),
            _buildMatchResults(provider, theme, colors),
            const SizedBox(height: 20),
            _buildReplaceSection(provider, theme, colors),
            if (provider.matches.isNotEmpty) ...[
              const SizedBox(height: 20),
              _buildMatchDetails(provider, theme, colors),
            ],
          ],
        );
      },
    );
  }

  Widget _buildPatternInput(RegexProvider provider, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'PATTERN',
          trailing: provider.error != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 16, color: colors.error),
                    const SizedBox(width: 4),
                    Text(
                      'Invalid pattern',
                      style: TextStyle(color: colors.error, fontSize: 12),
                    ),
                  ],
                )
              : null,
        ),
        TextField(
          controller: _patternCtrl,
          onChanged: provider.setPattern,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
          decoration: InputDecoration(
            hintText: r'Enter regex pattern (e.g., \d+)',
            prefixText: '/ ',
            suffixText: ' /',
            suffixIcon: CopyButton(text: provider.pattern),
            errorText: provider.error,
            errorMaxLines: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildFlagChips(RegexProvider provider, ColorScheme colors) {
    return Wrap(
      spacing: 8,
      children: [
        _flagChip('Case Insensitive', !provider.caseSensitive,
            provider.toggleCaseSensitive, colors),
        _flagChip('Multi-line', provider.multiLine,
            provider.toggleMultiLine, colors),
        _flagChip('Dot All', provider.dotAll,
            provider.toggleDotAll, colors),
        _flagChip('Unicode', provider.unicode,
            provider.toggleUnicode, colors),
      ],
    );
  }

  Widget _flagChip(
      String label, bool selected, VoidCallback onTap, ColorScheme colors) {
    return FilterChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      showCheckmark: true,
      selectedColor: colors.primaryContainer,
    );
  }

  Widget _buildTestInput(RegexProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'TEST STRING'),
        TextField(
          controller: _testCtrl,
          onChanged: provider.setTestString,
          maxLines: 5,
          minLines: 3,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
          decoration: const InputDecoration(
            hintText: 'Enter text to test against your regex...',
          ),
        ),
      ],
    );
  }

  Widget _buildMatchResults(
      RegexProvider provider, ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'MATCHES',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: provider.matchCount > 0
                  ? colors.primaryContainer
                  : colors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${provider.matchCount} match${provider.matchCount == 1 ? '' : 'es'}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: provider.matchCount > 0
                    ? colors.onPrimaryContainer
                    : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
          ),
          constraints: const BoxConstraints(minHeight: 80),
          child: MatchHighlightText(
            text: provider.testString,
            matches: provider.matches,
          ),
        ),
      ],
    );
  }

  Widget _buildReplaceSection(
      RegexProvider provider, ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _showReplace = !_showReplace),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Icon(
                  _showReplace
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  'REPLACE',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.primary,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_showReplace) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _replaceCtrl,
            onChanged: provider.setReplaceWith,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: const InputDecoration(
              hintText: r'Replacement string (supports $1, $2 groups)',
            ),
          ),
          if (provider.replacedString.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Result',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                CopyButton(text: provider.replacedString),
              ],
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5)),
              ),
              child: SelectableText(
                provider.replacedString,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Widget _buildMatchDetails(
      RegexProvider provider, ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'MATCH DETAILS'),
        ...provider.matches.asMap().entries.map((entry) {
          final i = entry.key;
          final match = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: colors.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Match ${i + 1}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Index ${match.start}-${match.end}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    CopyButton(text: match.group(0) ?? '', iconSize: 14),
                  ],
                ),
                const SizedBox(height: 6),
                SelectableText(
                  '"${match.group(0)}"',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: colors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (match.groupCount > 0)
                  ...List.generate(match.groupCount, (gi) {
                    final group = match.group(gi + 1);
                    if (group == null) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Group ${gi + 1}: "$group"',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildReferencePanel(ThemeData theme, ColorScheme colors) {
    final grouped = <String, List<RegexToken>>{};
    for (final token in RegexToken.referenceTokens) {
      grouped.putIfAbsent(token.category, () => []).add(token);
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Quick Reference',
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                onPressed: () => setState(() => _showReference = false),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
        ),
        Divider(height: 1, color: colors.outlineVariant),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  ...entry.value.map((token) => _referenceItem(token, colors)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _referenceItem(RegexToken token, ColorScheme colors) {
    return InkWell(
      onTap: () {
        final provider = context.read<RegexProvider>();
        final newPattern = provider.pattern + token.token;
        _patternCtrl.text = newPattern;
        provider.setPattern(newPattern);
      },
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                token.token,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.primary,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                token.description,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCommonPatterns(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final grouped = <String, List<RegexPatternTemplate>>{};
    for (final p in RegexPatternTemplate.commonPatterns) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (_, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        'Common Patterns',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1, color: colors.outlineVariant),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: grouped.entries.expand((entry) {
                      return [
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 8),
                          child: Text(
                            entry.key,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.primary,
                              fontSize: 13,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        ...entry.value.map((pattern) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(
                                pattern.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500, fontSize: 14),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    pattern.pattern,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 12,
                                      color: colors.primary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    pattern.description,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: colors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                final provider = context.read<RegexProvider>();
                                _patternCtrl.text = pattern.pattern;
                                provider.loadPattern(pattern.pattern);
                                Navigator.pop(ctx);
                              },
                            ),
                          );
                        }),
                      ];
                    }).toList(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
