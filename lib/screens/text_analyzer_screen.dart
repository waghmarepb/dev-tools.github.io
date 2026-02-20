import 'package:flutter/material.dart';
import '../widgets/section_header.dart';

class TextAnalyzerScreen extends StatefulWidget {
  const TextAnalyzerScreen({super.key});

  @override
  State<TextAnalyzerScreen> createState() => _TextAnalyzerScreenState();
}

class _TextAnalyzerScreenState extends State<TextAnalyzerScreen> {
  final _inputCtrl = TextEditingController();
  Map<String, dynamic> _stats = {};

  void _analyze() {
    final text = _inputCtrl.text;
    
    if (text.isEmpty) {
      setState(() => _stats = {});
      return;
    }

    final characters = text.length;
    final charactersNoSpaces = text.replaceAll(RegExp(r'\s'), '').length;
    final words = text.trim().isEmpty ? 0 : text.trim().split(RegExp(r'\s+')).length;
    final lines = text.split('\n').length;
    final paragraphs = text.split(RegExp(r'\n\s*\n')).where((p) => p.trim().isNotEmpty).length;
    final sentences = text.split(RegExp(r'[.!?]+\s+')).where((s) => s.trim().isNotEmpty).length;
    
    final readingTime = (words / 200).ceil();
    final speakingTime = (words / 150).ceil();
    
    final wordList = text.toLowerCase().split(RegExp(r'\W+')).where((w) => w.isNotEmpty).toList();
    final wordFreq = <String, int>{};
    for (final word in wordList) {
      wordFreq[word] = (wordFreq[word] ?? 0) + 1;
    }
    final topWords = wordFreq.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final avgWordLength = words > 0 ? (charactersNoSpaces / words).toStringAsFixed(1) : '0';
    final avgSentenceLength = sentences > 0 ? (words / sentences).toStringAsFixed(1) : '0';
    
    final fleschScore = _calculateFlesch(words, sentences, text.split(RegExp(r'[aeiouAEIOU]')).length - 1);
    
    setState(() {
      _stats = {
        'characters': characters,
        'charactersNoSpaces': charactersNoSpaces,
        'words': words,
        'lines': lines,
        'paragraphs': paragraphs,
        'sentences': sentences,
        'readingTime': readingTime,
        'speakingTime': speakingTime,
        'avgWordLength': avgWordLength,
        'avgSentenceLength': avgSentenceLength,
        'fleschScore': fleschScore,
        'topWords': topWords.take(10).toList(),
      };
    });
  }

  double _calculateFlesch(int words, int sentences, int syllables) {
    if (words == 0 || sentences == 0) return 0;
    
    final syllablesPer = syllables / words;
    final wordsPer = words / sentences;
    
    return (206.835 - (1.015 * wordsPer) - (84.6 * syllablesPer)).clamp(0, 100);
  }

  String _getReadabilityLevel(double score) {
    if (score >= 90) return 'Very Easy';
    if (score >= 80) return 'Easy';
    if (score >= 70) return 'Fairly Easy';
    if (score >= 60) return 'Standard';
    if (score >= 50) return 'Fairly Difficult';
    if (score >= 30) return 'Difficult';
    return 'Very Difficult';
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: _buildInputPanel(colors),
          ),
          Container(width: 1, color: colors.outlineVariant),
          Expanded(
            flex: 1,
            child: _buildStatsPanel(colors),
          ),
        ],
      ),
    );
  }

  Widget _buildInputPanel(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(title: 'TEXT INPUT'),
          Expanded(
            child: TextField(
              controller: _inputCtrl,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 14, height: 1.6),
              decoration: const InputDecoration(
                hintText: 'Paste or type your text here to analyze...',
              ),
              onChanged: (_) => _analyze(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsPanel(ColorScheme colors) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SectionHeader(title: 'STATISTICS'),
        if (_stats.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Column(
                children: [
                  Icon(Icons.analytics_outlined, size: 64, color: colors.onSurfaceVariant.withValues(alpha: 0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'Enter text to see statistics',
                    style: TextStyle(color: colors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _buildStatCard('Basic Counts', [
            _StatItem('Characters', _stats['characters'].toString(), Icons.text_fields),
            _StatItem('Characters (no spaces)', _stats['charactersNoSpaces'].toString(), Icons.space_bar),
            _StatItem('Words', _stats['words'].toString(), Icons.article_outlined),
            _StatItem('Lines', _stats['lines'].toString(), Icons.format_list_numbered),
            _StatItem('Paragraphs', _stats['paragraphs'].toString(), Icons.view_agenda_outlined),
            _StatItem('Sentences', _stats['sentences'].toString(), Icons.notes),
          ], colors),
          const SizedBox(height: 16),
          _buildStatCard('Reading Time', [
            _StatItem('Reading', '${_stats['readingTime']} min', Icons.menu_book),
            _StatItem('Speaking', '${_stats['speakingTime']} min', Icons.record_voice_over),
          ], colors),
          const SizedBox(height: 16),
          _buildStatCard('Averages', [
            _StatItem('Avg Word Length', '${_stats['avgWordLength']} chars', Icons.straighten),
            _StatItem('Avg Sentence Length', '${_stats['avgSentenceLength']} words', Icons.format_size),
          ], colors),
          const SizedBox(height: 16),
          _buildReadabilityCard(colors),
          const SizedBox(height: 16),
          _buildTopWordsCard(colors),
        ],
      ],
    );
  }

  Widget _buildStatCard(String title, List<_StatItem> items, ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(item.icon, size: 16, color: colors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.label, style: const TextStyle(fontSize: 13)),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReadabilityCard(ColorScheme colors) {
    final score = _stats['fleschScore'] as double;
    final level = _getReadabilityLevel(score);
    
    Color scoreColor;
    if (score >= 70) {
      scoreColor = Colors.green;
    } else if (score >= 50) {
      scoreColor = Colors.orange;
    } else {
      scoreColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Readability',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        level,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scoreColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Flesch Score: ${score.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    level,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: scoreColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: score / 100,
                minHeight: 6,
                backgroundColor: colors.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(scoreColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopWordsCard(ColorScheme colors) {
    final topWords = _stats['topWords'] as List<MapEntry<String, int>>;
    
    if (topWords.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Words',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.5),
            ),
            const SizedBox(height: 12),
            ...topWords.map((entry) {
              final maxCount = topWords.first.value;
              final progress = entry.value / maxCount;
              
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.key,
                            style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                        Text(
                          '${entry.value}×',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 4,
                        backgroundColor: colors.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation(colors.primary),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;

  _StatItem(this.label, this.value, this.icon);
}
