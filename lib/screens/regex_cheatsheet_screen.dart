import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegexCheatsheetScreen extends StatefulWidget {
  const RegexCheatsheetScreen({super.key});

  @override
  State<RegexCheatsheetScreen> createState() => _RegexCheatsheetScreenState();
}

class _RegexCheatsheetScreenState extends State<RegexCheatsheetScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'all';

  final List<_CheatItem> _items = [
    _CheatItem('Character Classes', '.', 'Any character except newline', 'a.c matches "abc", "a1c"'),
    _CheatItem('Character Classes', '\\d', 'Any digit (0-9)', '\\d+ matches "123"'),
    _CheatItem('Character Classes', '\\D', 'Any non-digit', '\\D+ matches "abc"'),
    _CheatItem('Character Classes', '\\w', 'Word character (a-z, A-Z, 0-9, _)', '\\w+ matches "hello_123"'),
    _CheatItem('Character Classes', '\\W', 'Non-word character', '\\W+ matches "!@#"'),
    _CheatItem('Character Classes', '\\s', 'Whitespace (space, tab, newline)', '\\s+ matches "   "'),
    _CheatItem('Character Classes', '\\S', 'Non-whitespace', '\\S+ matches "hello"'),
    _CheatItem('Character Classes', '[abc]', 'Any of a, b, or c', '[aeiou] matches vowels'),
    _CheatItem('Character Classes', '[^abc]', 'Not a, b, or c', '[^0-9] matches non-digits'),
    _CheatItem('Character Classes', '[a-z]', 'Range from a to z', '[A-Z] matches uppercase'),
    
    _CheatItem('Anchors', '^', 'Start of string/line', r'^Hello matches "Hello world"'),
    _CheatItem('Anchors', r'$', 'End of string/line', r'world$ matches "Hello world"'),
    _CheatItem('Anchors', '\\b', 'Word boundary', '\\bcat\\b matches "cat" not "catch"'),
    _CheatItem('Anchors', '\\B', 'Non-word boundary', '\\Bcat matches "catch" not "cat"'),
    
    _CheatItem('Quantifiers', '*', 'Zero or more', 'a* matches "", "a", "aaa"'),
    _CheatItem('Quantifiers', '+', 'One or more', 'a+ matches "a", "aaa" not ""'),
    _CheatItem('Quantifiers', '?', 'Zero or one (optional)', 'colou?r matches "color", "colour"'),
    _CheatItem('Quantifiers', '{n}', 'Exactly n times', '\\d{3} matches "123"'),
    _CheatItem('Quantifiers', '{n,}', 'n or more times', '\\d{2,} matches "12", "123"'),
    _CheatItem('Quantifiers', '{n,m}', 'Between n and m times', '\\d{2,4} matches "12", "1234"'),
    _CheatItem('Quantifiers', '*?', 'Lazy zero or more', '<.*?> matches "<a>" not "<a><b>"'),
    _CheatItem('Quantifiers', '+?', 'Lazy one or more', 'a+? matches "a" in "aaa"'),
    
    _CheatItem('Groups', '(abc)', 'Capture group', '(\\d+) captures numbers'),
    _CheatItem('Groups', '(?:abc)', 'Non-capturing group', '(?:https?://) groups without capture'),
    _CheatItem('Groups', '(?<name>abc)', 'Named capture group', '(?<year>\\d{4}) captures year'),
    _CheatItem('Groups', '\\1', 'Backreference to group 1', '(\\w)\\1 matches "aa", "bb"'),
    
    _CheatItem('Lookaround', '(?=abc)', 'Positive lookahead', r'\d(?=px) matches "5" in "5px"'),
    _CheatItem('Lookaround', '(?!abc)', 'Negative lookahead', r'\d(?!px) matches "5" not in "5px"'),
    _CheatItem('Lookaround', '(?<=abc)', 'Positive lookbehind', r'(?<=\$)\d+ matches "5" in "$5"'),
    _CheatItem('Lookaround', '(?<!abc)', 'Negative lookbehind', r'(?<!\$)\d+ matches "5" not in "$5"'),
    
    _CheatItem('Alternation', '|', 'OR operator', 'cat|dog matches "cat" or "dog"'),
    
    _CheatItem('Special', '\\', 'Escape special character', '\\. matches literal "."'),
    _CheatItem('Special', '\\n', 'Newline', 'line1\\nline2'),
    _CheatItem('Special', '\\r', 'Carriage return', 'Windows line ending'),
    _CheatItem('Special', '\\t', 'Tab', 'Tab\\tcharacter'),
    
    _CheatItem('Flags', 'i', 'Case insensitive', '/hello/i matches "Hello"'),
    _CheatItem('Flags', 'g', 'Global (all matches)', '/a/g finds all "a"'),
    _CheatItem('Flags', 'm', 'Multiline (^ and \$ match line breaks)', '^line/m matches each line'),
    _CheatItem('Flags', 's', 'Dot matches newline', '/.*/s matches across lines'),
  ];

  List<_CheatItem> get _filteredItems {
    return _items.where((item) {
      final matchesSearch = _searchQuery.isEmpty ||
          item.pattern.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.example.toLowerCase().contains(_searchQuery.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'all' || item.category == _selectedCategory;
      
      return matchesSearch && matchesCategory;
    }).toList();
  }

  List<String> get _categories {
    return ['all', ..._items.map((i) => i.category).toSet().toList()..sort()];
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
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
            _buildHeader(colors),
            const SizedBox(height: 16),
            _buildFilters(colors),
            const SizedBox(height: 16),
            Expanded(child: _buildCheatList(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search patterns, descriptions, examples...',
              prefixIcon: const Icon(Icons.search, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              isDense: true,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(cat == 'all' ? 'All' : cat),
              selected: isSelected,
              onSelected: (v) {
                if (v) setState(() => _selectedCategory = cat);
              },
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCheatList(ColorScheme colors) {
    final items = _filteredItems;

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
            const SizedBox(height: 16),
            Text(
              'No matches found',
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ],
        ),
      );
    }

    String? currentCategory;

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final showCategory = currentCategory != item.category;
        currentCategory = item.category;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showCategory) ...[
              if (index > 0) const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  item.category.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: colors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: item.pattern));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Copied: ${item.pattern}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.pattern,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.description,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.example,
                              style: TextStyle(
                                fontSize: 12,
                                color: colors.onSurfaceVariant,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.content_copy, size: 16, color: colors.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CheatItem {
  final String category;
  final String pattern;
  final String description;
  final String example;

  _CheatItem(this.category, this.pattern, this.description, this.example);
}
