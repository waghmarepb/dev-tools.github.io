import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/regex_pattern.dart';
import '../providers/regex_provider.dart';

class RegexSamplesScreen extends StatefulWidget {
  const RegexSamplesScreen({super.key});

  @override
  State<RegexSamplesScreen> createState() => _RegexSamplesScreenState();
}

class _RegexSamplesScreenState extends State<RegexSamplesScreen> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  List<String> get _categories {
    final cats = RegexPatternTemplate.commonPatterns
        .map((p) => p.category)
        .toSet()
        .toList()
      ..sort();
    return ['All', ...cats];
  }

  List<RegexPatternTemplate> get _filteredPatterns {
    return RegexPatternTemplate.commonPatterns.where((p) {
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.pattern.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final filtered = _filteredPatterns;

    final grouped = <String, List<RegexPatternTemplate>>{};
    for (final p in filtered) {
      grouped.putIfAbsent(p.category, () => []).add(p);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Regex Samples'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Search patterns...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final isSelected = cat == _selectedCategory;
                return FilterChip(
                  label: Text(cat),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = cat),
                  selectedColor: colors.primaryContainer,
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            size: 48, color: colors.onSurfaceVariant),
                        const SizedBox(height: 12),
                        Text(
                          'No patterns found',
                          style: TextStyle(color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: grouped.entries.expand((entry) {
                      return [
                        Padding(
                          padding: const EdgeInsets.only(top: 12, bottom: 8),
                          child: Row(
                            children: [
                              Icon(_categoryIcon(entry.key),
                                  size: 18, color: colors.primary),
                              const SizedBox(width: 8),
                              Text(
                                entry.key.toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12,
                                  color: colors.primary,
                                  letterSpacing: 1,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colors.primaryContainer,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '${entry.value.length}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: colors.onPrimaryContainer,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...entry.value
                            .map((p) => _SampleCard(
                                  pattern: p,
                                  onTryIt: () => _openInBuilder(p),
                                )),
                      ];
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  IconData _categoryIcon(String category) {
    return switch (category) {
      'Validation' => Icons.verified_outlined,
      'Network' => Icons.lan_outlined,
      'Code' => Icons.code_rounded,
      'Date & Time' => Icons.schedule_rounded,
      'Finance' => Icons.account_balance_outlined,
      'Text' => Icons.text_fields_rounded,
      'Data Extraction' => Icons.manage_search_rounded,
      _ => Icons.pattern_rounded,
    };
  }

  void _openInBuilder(RegexPatternTemplate pattern) {
    context.read<RegexProvider>().loadSample(
          pattern: pattern.pattern,
          testString: pattern.sampleText,
        );
    Navigator.of(context).pushReplacementNamed('/regex-builder');
  }
}

class _SampleCard extends StatefulWidget {
  final RegexPatternTemplate pattern;
  final VoidCallback onTryIt;

  const _SampleCard({required this.pattern, required this.onTryIt});

  @override
  State<_SampleCard> createState() => _SampleCardState();
}

class _SampleCardState extends State<_SampleCard> {
  bool _expanded = false;

  int get _matchCount {
    try {
      final regex = RegExp(widget.pattern.pattern);
      return regex.allMatches(widget.pattern.sampleText).length;
    } catch (_) {
      return 0;
    }
  }

  List<RegExpMatch> get _matches {
    try {
      final regex = RegExp(widget.pattern.pattern);
      return regex.allMatches(widget.pattern.sampleText).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final matches = _matches;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.pattern.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: matches.isNotEmpty
                              ? Colors.green.withValues(alpha: 0.1)
                              : colors.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$_matchCount match${_matchCount == 1 ? '' : 'es'}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: matches.isNotEmpty
                                ? Colors.green.shade700
                                : colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        size: 20,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.pattern.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '/',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            widget.pattern.pattern,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '/',
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            Clipboard.setData(
                                ClipboardData(text: widget.pattern.pattern));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Pattern copied'),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Icon(Icons.copy_rounded,
                              size: 15, color: colors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            Divider(height: 1, color: colors.outlineVariant.withValues(alpha: 0.5)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SAMPLE TEXT',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.5)),
                    ),
                    child: _buildHighlightedSample(colors),
                  ),
                  if (matches.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'MATCHED VALUES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: colors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: matches.take(12).map((m) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color:
                                colors.primaryContainer.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '"${m.group(0)}"',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    if (matches.length > 12) ...[
                      const SizedBox(height: 4),
                      Text(
                        '+${matches.length - 12} more',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                  if (widget.pattern.hint != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colors.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_outline_rounded,
                              size: 16, color: colors.tertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.pattern.hint!,
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
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      FilledButton.icon(
                        onPressed: widget.onTryIt,
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text('Try in Builder'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () {
                          final text =
                              '${widget.pattern.pattern}\n\n${widget.pattern.sampleText}';
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Pattern & sample text copied'),
                              behavior: SnackBarBehavior.floating,
                              duration: const Duration(seconds: 1),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_all_rounded, size: 18),
                        label: const Text('Copy All'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightedSample(ColorScheme colors) {
    final text = widget.pattern.sampleText;
    final matches = _matches;

    if (matches.isEmpty) {
      return SelectableText(
        text,
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.5),
      );
    }

    final spans = <TextSpan>[];
    int lastEnd = 0;
    final highlightColors = [
      colors.primary.withValues(alpha: 0.2),
      colors.tertiary.withValues(alpha: 0.2),
      colors.secondary.withValues(alpha: 0.2),
    ];

    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      if (match.start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, match.start)));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: TextStyle(
          backgroundColor: highlightColors[i % highlightColors.length],
          fontWeight: FontWeight.w600,
          color: colors.onSurface,
        ),
      ));
      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return SelectableText.rich(
      TextSpan(
        style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.5),
        children: spans,
      ),
    );
  }
}
