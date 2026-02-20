import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class LoremIpsumScreen extends StatefulWidget {
  const LoremIpsumScreen({super.key});

  @override
  State<LoremIpsumScreen> createState() => _LoremIpsumScreenState();
}

class _LoremIpsumScreenState extends State<LoremIpsumScreen> {
  int _count = 3;
  String _unit = 'paragraphs';
  bool _startWithLorem = true;
  String _output = '';

  static const _words = [
    'lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur',
    'adipiscing', 'elit', 'sed', 'do', 'eiusmod', 'tempor',
    'incididunt', 'ut', 'labore', 'et', 'dolore', 'magna', 'aliqua',
    'enim', 'ad', 'minim', 'veniam', 'quis', 'nostrud',
    'exercitation', 'ullamco', 'laboris', 'nisi', 'aliquip', 'ex',
    'ea', 'commodo', 'consequat', 'duis', 'aute', 'irure', 'in',
    'reprehenderit', 'voluptate', 'velit', 'esse', 'cillum', 'fugiat',
    'nulla', 'pariatur', 'excepteur', 'sint', 'occaecat', 'cupidatat',
    'non', 'proident', 'sunt', 'culpa', 'qui', 'officia', 'deserunt',
    'mollit', 'anim', 'id', 'est', 'laborum', 'perspiciatis', 'unde',
    'omnis', 'iste', 'natus', 'error', 'voluptatem', 'accusantium',
    'doloremque', 'laudantium', 'totam', 'rem', 'aperiam', 'eaque',
    'ipsa', 'quae', 'ab', 'illo', 'inventore', 'veritatis', 'quasi',
    'architecto', 'beatae', 'vitae', 'dicta', 'explicabo', 'nemo',
    'ipsam', 'quia', 'voluptas', 'aspernatur', 'aut', 'odit',
    'fugit', 'consequuntur', 'magni', 'dolores', 'eos', 'ratione',
  ];

  final _random = Random();

  @override
  void initState() {
    super.initState();
    _generate();
  }

  String _generateWord() => _words[_random.nextInt(_words.length)];

  String _generateSentence() {
    final wordCount = 8 + _random.nextInt(12);
    final sentence = List.generate(wordCount, (_) => _generateWord()).join(' ');
    return '${sentence[0].toUpperCase()}${sentence.substring(1)}.';
  }

  String _generateParagraph() {
    final sentenceCount = 3 + _random.nextInt(5);
    return List.generate(sentenceCount, (_) => _generateSentence()).join(' ');
  }

  void _generate() {
    String result;
    switch (_unit) {
      case 'words':
        final words = List.generate(_count, (_) => _generateWord());
        result = words.join(' ');
        break;
      case 'sentences':
        result = List.generate(_count, (_) => _generateSentence()).join(' ');
        break;
      case 'paragraphs':
      default:
        result = List.generate(_count, (_) => _generateParagraph())
            .join('\n\n');
    }

    if (_startWithLorem && result.isNotEmpty) {
      result = 'Lorem ipsum dolor sit amet, ${result.substring(result.indexOf(' ') + 1)}';
    }

    setState(() => _output = result);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Lorem Ipsum Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 80,
                      child: DropdownButtonFormField<int>(
                        initialValue: _count,
                        isDense: true,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        items: [1, 2, 3, 5, 10, 20]
                            .map((c) => DropdownMenuItem(
                                value: c, child: Text('$c')))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setState(() => _count = v);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(
                            value: 'paragraphs', label: Text('Paragraphs')),
                        ButtonSegment(
                            value: 'sentences', label: Text('Sentences')),
                        ButtonSegment(value: 'words', label: Text('Words')),
                      ],
                      selected: {_unit},
                      onSelectionChanged: (v) =>
                          setState(() => _unit = v.first),
                    ),
                    const SizedBox(width: 12),
                    FilterChip(
                      label: const Text('Start with "Lorem ipsum..."'),
                      selected: _startWithLorem,
                      onSelected: (v) => setState(() => _startWithLorem = v),
                      visualDensity: VisualDensity.compact,
                    ),
                    const Spacer(),
                    FilledButton.icon(
                      onPressed: _generate,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Generate'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'OUTPUT',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_output.split(' ').length} words',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  CopyButton(text: _output),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.5),
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _output,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
