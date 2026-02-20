import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/monokai-sublime.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';
import '../providers/theme_provider.dart';
import 'package:provider/provider.dart';

class SnippetManagerScreen extends StatefulWidget {
  const SnippetManagerScreen({super.key});

  @override
  State<SnippetManagerScreen> createState() => _SnippetManagerScreenState();
}

class _SnippetManagerScreenState extends State<SnippetManagerScreen> {
  final List<_Snippet> _snippets = [];
  _Snippet? _selectedSnippet;
  final _titleCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _language = 'javascript';
  String _searchQuery = '';
  String _filterTag = 'all';

  final List<String> _languages = [
    'javascript',
    'typescript',
    'python',
    'dart',
    'java',
    'go',
    'rust',
    'c',
    'cpp',
    'csharp',
    'php',
    'ruby',
    'swift',
    'kotlin',
    'sql',
    'html',
    'css',
    'json',
    'yaml',
    'bash',
  ];

  @override
  void initState() {
    super.initState();
    _loadSampleSnippets();
  }

  void _loadSampleSnippets() {
    _snippets.addAll([
      _Snippet(
        'Async/Await Example',
        'javascript',
        '''async function fetchData(url) {
  try {
    const response = await fetch(url);
    const data = await response.json();
    return data;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
}''',
        'Fetch data using async/await with error handling',
        ['javascript', 'async', 'fetch'],
        false,
      ),
      _Snippet(
        'Flutter StatefulWidget',
        'dart',
        '''class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('\$_counter'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}''',
        'Basic StatefulWidget template with counter',
        ['flutter', 'dart', 'widget'],
        true,
      ),
      _Snippet(
        'Python List Comprehension',
        'python',
        '''# Filter and transform list
numbers = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
even_squares = [x**2 for x in numbers if x % 2 == 0]
print(even_squares)  # [4, 16, 36, 64, 100]

# Nested comprehension
matrix = [[i*j for j in range(1, 4)] for i in range(1, 4)]
print(matrix)  # [[1, 2, 3], [2, 4, 6], [3, 6, 9]]''',
        'List comprehension examples with filtering',
        ['python', 'list', 'comprehension'],
        false,
      ),
    ]);
  }

  void _saveSnippet() {
    if (_titleCtrl.text.isEmpty || _codeCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and code are required')),
      );
      return;
    }

    final tags = _tagsCtrl.text.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

    setState(() {
      if (_selectedSnippet != null) {
        _selectedSnippet!.title = _titleCtrl.text;
        _selectedSnippet!.language = _language;
        _selectedSnippet!.code = _codeCtrl.text;
        _selectedSnippet!.description = _descCtrl.text;
        _selectedSnippet!.tags = tags;
      } else {
        _snippets.add(_Snippet(
          _titleCtrl.text,
          _language,
          _codeCtrl.text,
          _descCtrl.text,
          tags,
          false,
        ));
      }
      _clearForm();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_selectedSnippet != null ? 'Snippet updated' : 'Snippet saved')),
    );
  }

  void _editSnippet(_Snippet snippet) {
    setState(() {
      _selectedSnippet = snippet;
      _titleCtrl.text = snippet.title;
      _language = snippet.language;
      _codeCtrl.text = snippet.code;
      _descCtrl.text = snippet.description;
      _tagsCtrl.text = snippet.tags.join(', ');
    });
  }

  void _deleteSnippet(_Snippet snippet) {
    setState(() {
      _snippets.remove(snippet);
      if (_selectedSnippet == snippet) {
        _clearForm();
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Snippet deleted')),
    );
  }

  void _toggleFavorite(_Snippet snippet) {
    setState(() {
      snippet.isFavorite = !snippet.isFavorite;
    });
  }

  void _clearForm() {
    setState(() {
      _selectedSnippet = null;
      _titleCtrl.clear();
      _codeCtrl.clear();
      _descCtrl.clear();
      _tagsCtrl.clear();
      _language = 'javascript';
    });
  }

  void _exportSnippets() {
    jsonEncode(_snippets.map((s) => s.toJson()).toList());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export feature coming soon')),
    );
  }

  List<_Snippet> get _filteredSnippets {
    var filtered = _snippets.where((s) {
      final matchesSearch = _searchQuery.isEmpty ||
          s.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.code.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));

      final matchesTag = _filterTag == 'all' ||
          (_filterTag == 'favorites' && s.isFavorite) ||
          s.tags.contains(_filterTag);

      return matchesSearch && matchesTag;
    }).toList();

    filtered.sort((a, b) {
      if (a.isFavorite && !b.isFavorite) return -1;
      if (!a.isFavorite && b.isFavorite) return 1;
      return 0;
    });

    return filtered;
  }

  Set<String> get _allTags {
    final tags = <String>{};
    for (final snippet in _snippets) {
      tags.addAll(snippet.tags);
    }
    return tags;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _codeCtrl.dispose();
    _tagsCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isDark = context.watch<ThemeProvider>().themeMode == ThemeMode.dark;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: _buildSnippetList(colors, isDark),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildEditor(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSnippetList(ColorScheme colors, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'SNIPPETS (${_filteredSnippets.length})',
          trailing: IconButton(
            icon: const Icon(Icons.download, size: 18),
            onPressed: _exportSnippets,
            tooltip: 'Export All',
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    hintText: 'Search snippets...',
                    isDense: true,
                    prefixIcon: Icon(Icons.search, size: 18),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'All'),
                      _buildFilterChip('favorites', 'Favorites'),
                      ..._allTags.map((tag) => _buildFilterChip(tag, tag)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: _filteredSnippets.isEmpty
              ? Card(
                  child: Center(
                    child: Text(
                      'No snippets found',
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                  ),
                )
              : ListView.builder(
                  itemCount: _filteredSnippets.length,
                  itemBuilder: (_, i) => _buildSnippetCard(_filteredSnippets[i], colors, isDark),
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label, style: const TextStyle(fontSize: 11)),
        selected: _filterTag == value,
        onSelected: (_) => setState(() => _filterTag = value),
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  Widget _buildSnippetCard(_Snippet snippet, ColorScheme colors, bool isDark) {
    final isSelected = _selectedSnippet == snippet;
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isSelected ? colors.primaryContainer.withValues(alpha: 0.3) : null,
      child: InkWell(
        onTap: () => _editSnippet(snippet),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (snippet.isFavorite)
                    Icon(Icons.star, size: 14, color: colors.primary),
                  if (snippet.isFavorite) const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      snippet.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      snippet.isFavorite ? Icons.star : Icons.star_border,
                      size: 16,
                    ),
                    onPressed: () => _toggleFavorite(snippet),
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 16),
                    onPressed: () => _deleteSnippet(snippet),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              if (snippet.description.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  snippet.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: colors.secondaryContainer,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      snippet.language,
                      style: TextStyle(
                        fontSize: 10,
                        color: colors.onSecondaryContainer,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 4,
                      children: snippet.tags.take(3).map((tag) {
                        return Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 9)),
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditor(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: _selectedSnippet == null ? 'NEW SNIPPET' : 'EDIT SNIPPET',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedSnippet != null)
                TextButton.icon(
                  onPressed: _clearForm,
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancel'),
                ),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _saveSnippet,
                icon: const Icon(Icons.save, size: 16),
                label: Text(_selectedSnippet == null ? 'Save' : 'Update'),
              ),
            ],
          ),
        ),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextField(
                          controller: _titleCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Title *',
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _language,
                          decoration: const InputDecoration(
                            labelText: 'Language',
                            isDense: true,
                          ),
                          items: _languages.map((lang) {
                            return DropdownMenuItem(
                              value: lang,
                              child: Text(lang, style: const TextStyle(fontSize: 12)),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _language = v!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _descCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _tagsCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Tags (comma-separated)',
                      hintText: 'javascript, async, api',
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _codeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Code *',
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                  if (_codeCtrl.text.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Preview:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        const Spacer(),
                        CopyButton(text: _codeCtrl.text, iconSize: 14),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      decoration: BoxDecoration(
                        border: Border.all(color: colors.outline),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SingleChildScrollView(
                        child: HighlightView(
                          _codeCtrl.text,
                          language: _language,
                          theme: context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                              ? monokaiSublimeTheme
                              : githubTheme,
                          padding: const EdgeInsets.all(12),
                          textStyle: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Snippet {
  String title;
  String language;
  String code;
  String description;
  List<String> tags;
  bool isFavorite;

  _Snippet(
    this.title,
    this.language,
    this.code,
    this.description,
    this.tags,
    this.isFavorite,
  );

  Map<String, dynamic> toJson() => {
        'title': title,
        'language': language,
        'code': code,
        'description': description,
        'tags': tags,
        'isFavorite': isFavorite,
      };
}
