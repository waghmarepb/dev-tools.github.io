import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class CaseConverterScreen extends StatefulWidget {
  const CaseConverterScreen({super.key});

  @override
  State<CaseConverterScreen> createState() => _CaseConverterScreenState();
}

class _CaseConverterScreenState extends State<CaseConverterScreen> {
  final _inputCtrl = TextEditingController();
  String _input = '';

  String get _camelCase => _toCamelCase(_input);
  String get _pascalCase => _toPascalCase(_input);
  String get _snakeCase => _toSnakeCase(_input);
  String get _kebabCase => _toKebabCase(_input);
  String get _constantCase => _toConstantCase(_input);
  String get _dotCase => _toDotCase(_input);
  String get _pathCase => _toPathCase(_input);
  String get _titleCase => _toTitleCase(_input);
  String get _sentenceCase => _toSentenceCase(_input);
  String get _lowerCase => _input.toLowerCase();
  String get _upperCase => _input.toUpperCase();
  int get _charCount => _input.length;
  int get _wordCount => _input.trim().isEmpty ? 0 : _input.trim().split(RegExp(r'\s+')).length;

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader(title: 'INPUT TEXT')),
                if (_input.isNotEmpty) ...[
                  _buildStatChip('$_charCount chars', colors),
                  const SizedBox(width: 8),
                  _buildStatChip('$_wordCount words', colors),
                ],
              ],
            ),
            TextField(
              controller: _inputCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Enter text to convert...',
              ),
              onChanged: (v) => setState(() => _input = v),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'CONVERSIONS'),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  _buildCaseCard('camelCase', _camelCase, 'getUserName', colors),
                  _buildCaseCard('PascalCase', _pascalCase, 'GetUserName', colors),
                  _buildCaseCard('snake_case', _snakeCase, 'get_user_name', colors),
                  _buildCaseCard('kebab-case', _kebabCase, 'get-user-name', colors),
                  _buildCaseCard('CONSTANT_CASE', _constantCase, 'GET_USER_NAME', colors),
                  _buildCaseCard('dot.case', _dotCase, 'get.user.name', colors),
                  _buildCaseCard('path/case', _pathCase, 'get/user/name', colors),
                  _buildCaseCard('Title Case', _titleCase, 'Get User Name', colors),
                  _buildCaseCard('Sentence case', _sentenceCase, 'Get user name', colors),
                  _buildCaseCard('lowercase', _lowerCase, 'get user name', colors),
                  _buildCaseCard('UPPERCASE', _upperCase, 'GET USER NAME', colors),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: colors.onPrimaryContainer,
        ),
      ),
    );
  }

  Widget _buildCaseCard(String name, String value, String example, ColorScheme colors) {
    final isEmpty = _input.trim().isEmpty;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                    ),
                  ),
                ),
                CopyButton(text: isEmpty ? '' : value, iconSize: 16),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  isEmpty ? example : value,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13,
                    color: isEmpty ? colors.onSurfaceVariant.withValues(alpha: 0.5) : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _toCamelCase(String input) {
    if (input.isEmpty) return '';
    final words = _splitIntoWords(input);
    if (words.isEmpty) return '';
    return words[0].toLowerCase() +
        words.skip(1).map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
  }

  String _toPascalCase(String input) {
    if (input.isEmpty) return '';
    final words = _splitIntoWords(input);
    return words.map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase()).join();
  }

  String _toSnakeCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input).map((w) => w.toLowerCase()).join('_');
  }

  String _toKebabCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input).map((w) => w.toLowerCase()).join('-');
  }

  String _toConstantCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input).map((w) => w.toUpperCase()).join('_');
  }

  String _toDotCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input).map((w) => w.toLowerCase()).join('.');
  }

  String _toPathCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input).map((w) => w.toLowerCase()).join('/');
  }

  String _toTitleCase(String input) {
    if (input.isEmpty) return '';
    return _splitIntoWords(input)
        .map((w) => w[0].toUpperCase() + w.substring(1).toLowerCase())
        .join(' ');
  }

  String _toSentenceCase(String input) {
    if (input.isEmpty) return '';
    final words = _splitIntoWords(input);
    if (words.isEmpty) return '';
    return words[0][0].toUpperCase() +
        words[0].substring(1).toLowerCase() +
        (words.length > 1
            ? ' ${words.skip(1).map((w) => w.toLowerCase()).join(' ')}'
            : '');
  }

  List<String> _splitIntoWords(String input) {
    if (input.isEmpty) return [];
    
    return input
        .replaceAllMapped(RegExp(r'([a-z])([A-Z])'), (m) => '${m[1]} ${m[2]}')
        .replaceAllMapped(RegExp(r'([A-Z]+)([A-Z][a-z])'), (m) => '${m[1]} ${m[2]}')
        .split(RegExp(r'[\s_\-./\\]+'))
        .where((w) => w.isNotEmpty)
        .toList();
  }
}
