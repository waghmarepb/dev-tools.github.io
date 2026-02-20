import 'dart:math';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  String _generatedPassword = '';
  int _length = 16;
  bool _uppercase = true;
  bool _lowercase = true;
  bool _digits = true;
  bool _symbols = true;
  bool _excludeAmbiguous = false;
  int _bulkCount = 1;
  List<String> _bulkPasswords = [];
  String _generatorType = 'password'; // password, passphrase, apikey, secret
  int _passphraseWords = 4;
  String _passphraseSeparator = '-';

  final _random = Random.secure();

  final _wordList = [
    'able', 'about', 'account', 'acid', 'across', 'action', 'activity', 'actor',
    'actual', 'add', 'address', 'admit', 'adult', 'affect', 'after', 'again',
    'against', 'agency', 'agent', 'agree', 'ahead', 'allow', 'almost', 'alone',
    'along', 'already', 'also', 'although', 'always', 'among', 'amount', 'analysis',
    'animal', 'another', 'answer', 'anyone', 'anything', 'appear', 'apply', 'approach',
    'area', 'argue', 'around', 'arrive', 'article', 'artist', 'assume', 'attack',
    'attention', 'attorney', 'audience', 'author', 'authority', 'available', 'avoid', 'away',
    'baby', 'back', 'ball', 'bank', 'base', 'beat', 'beautiful', 'because',
    'become', 'before', 'begin', 'behavior', 'behind', 'believe', 'benefit', 'best',
    'better', 'between', 'beyond', 'bill', 'billion', 'black', 'blood', 'blue',
    'board', 'body', 'book', 'born', 'both', 'break', 'bring', 'brother',
    'budget', 'build', 'building', 'business', 'call', 'camera', 'campaign', 'cancer',
    'candidate', 'capital', 'card', 'care', 'career', 'carry', 'case', 'catch',
    'cause', 'cell', 'center', 'central', 'century', 'certain', 'certainly', 'chair',
    'challenge', 'chance', 'change', 'character', 'charge', 'check', 'child', 'choice',
    'choose', 'church', 'citizen', 'city', 'civil', 'claim', 'class', 'clear',
    'clearly', 'close', 'coach', 'cold', 'collection', 'college', 'color', 'come',
    'commercial', 'common', 'community', 'company', 'compare', 'computer', 'concern', 'condition',
    'conference', 'congress', 'consider', 'consumer', 'contain', 'continue', 'control', 'cost',
    'could', 'country', 'couple', 'course', 'court', 'cover', 'create', 'crime',
    'cultural', 'culture', 'current', 'customer', 'dark', 'data', 'daughter', 'dead',
    'deal', 'death', 'debate', 'decade', 'decide', 'decision', 'deep', 'defense',
    'degree', 'democrat', 'democratic', 'describe', 'design', 'despite', 'detail', 'determine',
    'develop', 'development', 'difference', 'different', 'difficult', 'dinner', 'direction', 'director',
    'discover', 'discuss', 'discussion', 'disease', 'doctor', 'door', 'down', 'draw',
    'dream', 'drive', 'drop', 'drug', 'during', 'each', 'early', 'east',
    'easy', 'economic', 'economy', 'edge', 'education', 'effect', 'effort', 'eight',
    'either', 'election', 'else', 'employee', 'energy', 'enjoy', 'enough', 'enter',
    'entire', 'environment', 'environmental', 'especially', 'establish', 'even', 'evening', 'event',
    'ever', 'every', 'everybody', 'everyone', 'everything', 'evidence', 'exactly', 'example',
    'executive', 'exist', 'expect', 'experience', 'expert', 'explain', 'face', 'fact',
    'factor', 'fail', 'fall', 'family', 'fast', 'father', 'fear', 'federal',
    'feel', 'feeling', 'field', 'fight', 'figure', 'fill', 'film', 'final',
    'finally', 'financial', 'find', 'fine', 'finger', 'finish', 'fire', 'firm',
    'first', 'fish', 'five', 'floor', 'focus', 'follow', 'food', 'foot',
    'force', 'foreign', 'forget', 'form', 'former', 'forward', 'four', 'free',
    'friend', 'from', 'front', 'full', 'fund', 'future', 'game', 'garden',
    'general', 'generation', 'girl', 'give', 'glass', 'goal', 'good', 'government',
    'great', 'green', 'ground', 'group', 'grow', 'growth', 'guess', 'gun',
    'hair', 'half', 'hand', 'hang', 'happen', 'happy', 'hard', 'have',
    'head', 'health', 'hear', 'heart', 'heat', 'heavy', 'help', 'here',
    'herself', 'high', 'himself', 'history', 'hold', 'home', 'hope', 'hospital',
    'hotel', 'hour', 'house', 'however', 'huge', 'human', 'hundred', 'husband',
    'idea', 'identify', 'image', 'imagine', 'impact', 'important', 'improve', 'include',
    'including', 'increase', 'indeed', 'indicate', 'individual', 'industry', 'information', 'inside',
    'instead', 'institution', 'interest', 'interesting', 'international', 'interview', 'into', 'investment',
    'involve', 'issue', 'item', 'itself', 'join', 'just', 'keep', 'kill',
    'kind', 'kitchen', 'know', 'knowledge', 'land', 'language', 'large', 'last',
    'late', 'later', 'laugh', 'lawyer', 'lead', 'leader', 'learn', 'least',
    'leave', 'left', 'legal', 'less', 'letter', 'level', 'life', 'light',
    'like', 'likely', 'line', 'list', 'listen', 'little', 'live', 'local',
    'long', 'look', 'lose', 'loss', 'love', 'machine', 'magazine', 'main',
    'maintain', 'major', 'majority', 'make', 'manage', 'management', 'manager', 'many',
    'market', 'marriage', 'material', 'matter', 'maybe', 'mean', 'measure', 'media',
    'medical', 'meet', 'meeting', 'member', 'memory', 'mention', 'message', 'method',
    'middle', 'might', 'military', 'million', 'mind', 'minute', 'miss', 'mission',
    'model', 'modern', 'moment', 'money', 'month', 'more', 'morning', 'most',
    'mother', 'mouth', 'move', 'movement', 'movie', 'much', 'music', 'must',
    'myself', 'name', 'nation', 'national', 'natural', 'nature', 'near', 'nearly',
    'necessary', 'need', 'network', 'never', 'news', 'newspaper', 'next', 'nice',
    'night', 'none', 'north', 'note', 'nothing', 'notice', 'number', 'occur',
    'offer', 'office', 'officer', 'official', 'often', 'once', 'only', 'onto',
    'open', 'operation', 'opportunity', 'option', 'order', 'organization', 'other', 'others',
    'outside', 'over', 'owner', 'page', 'pain', 'painting', 'paper', 'parent',
    'part', 'participant', 'particular', 'particularly', 'partner', 'party', 'pass', 'past',
    'patient', 'pattern', 'peace', 'people', 'perform', 'performance', 'perhaps', 'period',
    'person', 'personal', 'phone', 'physical', 'pick', 'picture', 'piece', 'place',
    'plan', 'plant', 'play', 'player', 'point', 'police', 'policy', 'political',
    'politics', 'poor', 'popular', 'population', 'position', 'positive', 'possible', 'power',
    'practice', 'prepare', 'present', 'president', 'pressure', 'pretty', 'prevent', 'price',
    'private', 'probably', 'problem', 'process', 'produce', 'product', 'production', 'professional',
    'professor', 'program', 'project', 'property', 'protect', 'prove', 'provide', 'public',
    'pull', 'purpose', 'push', 'quality', 'question', 'quickly', 'quite', 'race',
    'radio', 'raise', 'range', 'rate', 'rather', 'reach', 'read', 'ready',
    'real', 'reality', 'realize', 'really', 'reason', 'receive', 'recent', 'recently',
    'recognize', 'record', 'reduce', 'reflect', 'region', 'relate', 'relationship', 'religious',
    'remain', 'remember', 'remove', 'report', 'represent', 'republican', 'require', 'research',
    'resource', 'respond', 'response', 'responsibility', 'rest', 'result', 'return', 'reveal',
    'rich', 'right', 'rise', 'risk', 'road', 'rock', 'role', 'room',
    'rule', 'safe', 'same', 'save', 'scene', 'school', 'science', 'scientist',
    'score', 'season', 'seat', 'second', 'section', 'security', 'seek', 'seem',
    'sell', 'send', 'senior', 'sense', 'series', 'serious', 'serve', 'service',
    'seven', 'several', 'sexual', 'shake', 'share', 'shoot', 'short', 'shot',
    'should', 'shoulder', 'show', 'side', 'sign', 'significant', 'similar', 'simple',
    'simply', 'since', 'sing', 'single', 'sister', 'site', 'situation', 'size',
    'skill', 'skin', 'small', 'smile', 'social', 'society', 'soldier', 'some',
    'somebody', 'someone', 'something', 'sometimes', 'song', 'soon', 'sort', 'sound',
    'source', 'south', 'southern', 'space', 'speak', 'special', 'specific', 'speech',
    'spend', 'sport', 'spring', 'staff', 'stage', 'stand', 'standard', 'star',
    'start', 'state', 'statement', 'station', 'stay', 'step', 'still', 'stock',
    'stop', 'store', 'story', 'strategy', 'street', 'strong', 'structure', 'student',
    'study', 'stuff', 'style', 'subject', 'success', 'successful', 'such', 'suddenly',
    'suffer', 'suggest', 'summer', 'support', 'sure', 'surface', 'system', 'table',
    'take', 'talk', 'task', 'teach', 'teacher', 'team', 'technology', 'television',
    'tell', 'tend', 'term', 'test', 'than', 'thank', 'that', 'their',
    'them', 'themselves', 'then', 'theory', 'there', 'these', 'they', 'thing',
    'think', 'third', 'this', 'those', 'though', 'thought', 'thousand', 'threat',
    'three', 'through', 'throughout', 'throw', 'thus', 'time', 'today', 'together',
    'tonight', 'total', 'tough', 'toward', 'town', 'trade', 'traditional', 'training',
    'travel', 'treat', 'treatment', 'tree', 'trial', 'trip', 'trouble', 'true',
    'truth', 'turn', 'type', 'under', 'understand', 'unit', 'until', 'upon',
    'usually', 'value', 'various', 'very', 'victim', 'view', 'violence', 'visit',
    'voice', 'vote', 'wait', 'walk', 'wall', 'want', 'watch', 'water',
    'weapon', 'wear', 'week', 'weight', 'well', 'west', 'western', 'what',
    'whatever', 'when', 'where', 'whether', 'which', 'while', 'white', 'whole',
    'whom', 'whose', 'wide', 'wife', 'will', 'wind', 'window', 'wish',
    'with', 'within', 'without', 'woman', 'wonder', 'word', 'work', 'worker',
    'world', 'worry', 'would', 'write', 'writer', 'wrong', 'yard', 'yeah',
    'year', 'young', 'your', 'yourself',
  ];

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      if (_bulkCount == 1) {
        _generatedPassword = _generateSingle();
        _bulkPasswords = [];
      } else {
        _bulkPasswords = List.generate(_bulkCount, (_) => _generateSingle());
        _generatedPassword = '';
      }
    });
  }

  String _generateSingle() {
    switch (_generatorType) {
      case 'passphrase':
        return _generatePassphrase();
      case 'apikey':
        return _generateApiKey();
      case 'secret':
        return _generateSecret();
      default:
        return _generatePassword();
    }
  }

  String _generatePassword() {
    String chars = '';
    if (_uppercase) chars += 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    if (_lowercase) chars += 'abcdefghijklmnopqrstuvwxyz';
    if (_digits) chars += '0123456789';
    if (_symbols) chars += '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    if (_excludeAmbiguous) {
      chars = chars.replaceAll(RegExp(r'[0OIl1]'), '');
    }

    if (chars.isEmpty) return '';

    return List.generate(_length, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String _generatePassphrase() {
    final words = List.generate(
      _passphraseWords,
      (_) => _wordList[_random.nextInt(_wordList.length)],
    );
    return words.join(_passphraseSeparator);
  }

  String _generateApiKey() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    return List.generate(32, (_) => chars[_random.nextInt(chars.length)]).join();
  }

  String _generateSecret() {
    final bytes = List.generate(32, (_) => _random.nextInt(256));
    return base64Url.encode(bytes).substring(0, 43);
  }

  double _calculateEntropy() {
    if (_generatorType != 'password' || _generatedPassword.isEmpty) return 0;

    int poolSize = 0;
    if (_uppercase) poolSize += 26;
    if (_lowercase) poolSize += 26;
    if (_digits) poolSize += 10;
    if (_symbols) poolSize += 28;

    if (_excludeAmbiguous) poolSize -= 5;

    return _length * (log(poolSize) / log(2));
  }

  String _getStrength() {
    final entropy = _calculateEntropy();
    if (entropy < 40) return 'Weak';
    if (entropy < 60) return 'Fair';
    if (entropy < 80) return 'Good';
    if (entropy < 100) return 'Strong';
    return 'Very Strong';
  }

  Color _getStrengthColor(ColorScheme colors) {
    final strength = _getStrength();
    switch (strength) {
      case 'Weak':
        return Colors.red;
      case 'Fair':
        return Colors.orange;
      case 'Good':
        return Colors.yellow.shade700;
      case 'Strong':
        return Colors.lightGreen;
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _buildTypeSelector(colors),
          const SizedBox(height: 24),
          _buildGeneratedDisplay(theme, colors),
          const SizedBox(height: 24),
          if (_generatorType == 'password') ...[
            _buildPasswordOptions(colors),
            const SizedBox(height: 24),
            _buildStrengthMeter(theme, colors),
          ] else if (_generatorType == 'passphrase')
            _buildPassphraseOptions(colors)
          else
            _buildApiKeyInfo(theme, colors),
          const SizedBox(height: 24),
          _buildBulkGeneration(colors),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GENERATOR TYPE'),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(
              value: 'password',
              label: Text('Password'),
              icon: Icon(Icons.lock_outline, size: 18),
            ),
            ButtonSegment(
              value: 'passphrase',
              label: Text('Passphrase'),
              icon: Icon(Icons.vpn_key_outlined, size: 18),
            ),
            ButtonSegment(
              value: 'apikey',
              label: Text('API Key'),
              icon: Icon(Icons.key_outlined, size: 18),
            ),
            ButtonSegment(
              value: 'secret',
              label: Text('Secret'),
              icon: Icon(Icons.security_outlined, size: 18),
            ),
          ],
          selected: {_generatorType},
          onSelectionChanged: (v) {
            setState(() => _generatorType = v.first);
            _generate();
          },
        ),
      ],
    );
  }

  Widget _buildGeneratedDisplay(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'GENERATED ${_generatorType.toUpperCase()}',
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_bulkCount == 1)
                CopyButton(text: _generatedPassword)
              else
                CopyButton(text: _bulkPasswords.join('\n'), tooltip: 'Copy All'),
              const SizedBox(width: 8),
              FilledButton.icon(
                onPressed: _generate,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Generate'),
              ),
            ],
          ),
        ),
        if (_bulkCount == 1)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _generatedPassword.isEmpty ? 'Click Generate' : _generatedPassword,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.onPrimaryContainer,
                letterSpacing: 1,
              ),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _bulkPasswords.length,
              itemBuilder: (_, i) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '${i + 1}.',
                        style: TextStyle(
                          fontSize: 12,
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SelectableText(
                          _bulkPasswords[i],
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                          ),
                        ),
                      ),
                      CopyButton(text: _bulkPasswords[i], iconSize: 16),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildPasswordOptions(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'OPTIONS'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Length: $_length characters', style: const TextStyle(fontSize: 13)),
                Slider(
                  value: _length.toDouble(),
                  min: 8,
                  max: 128,
                  divisions: 120,
                  onChanged: (v) {
                    setState(() => _length = v.toInt());
                    _generate();
                  },
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilterChip(
                      label: const Text('Uppercase (A-Z)'),
                      selected: _uppercase,
                      onSelected: (v) {
                        setState(() => _uppercase = v);
                        _generate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Lowercase (a-z)'),
                      selected: _lowercase,
                      onSelected: (v) {
                        setState(() => _lowercase = v);
                        _generate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Digits (0-9)'),
                      selected: _digits,
                      onSelected: (v) {
                        setState(() => _digits = v);
                        _generate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Symbols (!@#\$...)'),
                      selected: _symbols,
                      onSelected: (v) {
                        setState(() => _symbols = v);
                        _generate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                    FilterChip(
                      label: const Text('Exclude Ambiguous (0OIl1)'),
                      selected: _excludeAmbiguous,
                      onSelected: (v) {
                        setState(() => _excludeAmbiguous = v);
                        _generate();
                      },
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPassphraseOptions(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'OPTIONS'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Words: $_passphraseWords', style: const TextStyle(fontSize: 13)),
                Slider(
                  value: _passphraseWords.toDouble(),
                  min: 3,
                  max: 8,
                  divisions: 5,
                  onChanged: (v) {
                    setState(() => _passphraseWords = v.toInt());
                    _generate();
                  },
                ),
                const SizedBox(height: 12),
                Text('Separator', style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 6),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: '-', label: Text('Dash')),
                    ButtonSegment(value: '_', label: Text('Underscore')),
                    ButtonSegment(value: ' ', label: Text('Space')),
                    ButtonSegment(value: '', label: Text('None')),
                  ],
                  selected: {_passphraseSeparator},
                  onSelectionChanged: (v) {
                    setState(() => _passphraseSeparator = v.first);
                    _generate();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyInfo(ThemeData theme, ColorScheme colors) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.tertiaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 20, color: colors.tertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _generatorType == 'apikey'
                  ? 'API Key: 32 alphanumeric characters'
                  : 'Secret: 43-character base64url encoded string (256-bit)',
              style: TextStyle(
                fontSize: 13,
                color: colors.onTertiaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrengthMeter(ThemeData theme, ColorScheme colors) {
    final entropy = _calculateEntropy();
    final strength = _getStrength();
    final strengthColor = _getStrengthColor(colors);
    final progress = (entropy / 120).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'PASSWORD STRENGTH'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            strength,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: strengthColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${entropy.toStringAsFixed(1)} bits of entropy',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: strengthColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: strengthColor.withValues(alpha: 0.3)),
                      ),
                      child: Text(
                        strength,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: strengthColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: colors.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(strengthColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkGeneration(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'BULK GENERATION'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Count:', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _bulkCount.toDouble(),
                    min: 1,
                    max: 50,
                    divisions: 49,
                    label: '$_bulkCount',
                    onChanged: (v) => setState(() => _bulkCount = v.toInt()),
                  ),
                ),
                Text('$_bulkCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
