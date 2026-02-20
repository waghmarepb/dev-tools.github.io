import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class EnhancedDiffScreen extends StatefulWidget {
  const EnhancedDiffScreen({super.key});

  @override
  State<EnhancedDiffScreen> createState() => _EnhancedDiffScreenState();
}

class _EnhancedDiffScreenState extends State<EnhancedDiffScreen> {
  String _activeTab = 'diff';
  final _text1Ctrl = TextEditingController();
  final _text2Ctrl = TextEditingController();
  final _text3Ctrl = TextEditingController();
  final _patchCtrl = TextEditingController();
  bool _ignoreWhitespace = false;
  bool _ignoreCase = false;
  List<_DiffLine> _diffResult = [];
  String _mergeResult = '';
  List<_Conflict> _conflicts = [];

  void _computeDiff() {
    final text1 = _text1Ctrl.text;
    final text2 = _text2Ctrl.text;

    if (text1.isEmpty && text2.isEmpty) {
      setState(() => _diffResult = []);
      return;
    }

    List<String> lines1 = text1.split('\n');
    List<String> lines2 = text2.split('\n');

    if (_ignoreWhitespace) {
      lines1 = lines1.map((l) => l.trim()).toList();
      lines2 = lines2.map((l) => l.trim()).toList();
    }

    if (_ignoreCase) {
      lines1 = lines1.map((l) => l.toLowerCase()).toList();
      lines2 = lines2.map((l) => l.toLowerCase()).toList();
    }

    final diff = _lcs(lines1, lines2);
    setState(() => _diffResult = diff);
  }

  List<_DiffLine> _lcs(List<String> a, List<String> b) {
    final m = a.length;
    final n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));

    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        if (a[i - 1] == b[j - 1]) {
          dp[i][j] = dp[i - 1][j - 1] + 1;
        } else {
          dp[i][j] = dp[i - 1][j] > dp[i][j - 1] ? dp[i - 1][j] : dp[i][j - 1];
        }
      }
    }

    final result = <_DiffLine>[];
    var i = m;
    var j = n;

    while (i > 0 || j > 0) {
      if (i > 0 && j > 0 && a[i - 1] == b[j - 1]) {
        result.insert(0, _DiffLine('unchanged', a[i - 1], i, j));
        i--;
        j--;
      } else if (j > 0 && (i == 0 || dp[i][j - 1] >= dp[i - 1][j])) {
        result.insert(0, _DiffLine('added', b[j - 1], null, j));
        j--;
      } else if (i > 0) {
        result.insert(0, _DiffLine('removed', a[i - 1], i, null));
        i--;
      }
    }

    return result;
  }

  void _compute3WayMerge() {
    final base = _text1Ctrl.text.split('\n');
    final left = _text2Ctrl.text.split('\n');
    final right = _text3Ctrl.text.split('\n');

    final conflicts = <_Conflict>[];
    final merged = <String>[];
    var i = 0;

    while (i < base.length || i < left.length || i < right.length) {
      final baseLine = i < base.length ? base[i] : '';
      final leftLine = i < left.length ? left[i] : '';
      final rightLine = i < right.length ? right[i] : '';

      if (baseLine == leftLine && baseLine == rightLine) {
        merged.add(baseLine);
      } else if (baseLine == leftLine && baseLine != rightLine) {
        merged.add(rightLine);
      } else if (baseLine == rightLine && baseLine != leftLine) {
        merged.add(leftLine);
      } else if (leftLine == rightLine) {
        merged.add(leftLine);
      } else {
        conflicts.add(_Conflict(i + 1, baseLine, leftLine, rightLine));
        merged.add('<<<<<<< LEFT');
        merged.add(leftLine);
        merged.add('=======');
        merged.add(rightLine);
        merged.add('>>>>>>> RIGHT');
      }
      i++;
    }

    setState(() {
      _mergeResult = merged.join('\n');
      _conflicts = conflicts;
    });
  }

  void _generatePatch() {
    final buffer = StringBuffer();
    buffer.writeln('--- Original');
    buffer.writeln('+++ Modified');
    buffer.writeln('@@ -1,${_text1Ctrl.text.split('\n').length} +1,${_text2Ctrl.text.split('\n').length} @@');

    for (final line in _diffResult) {
      switch (line.type) {
        case 'added':
          buffer.writeln('+${line.content}');
          break;
        case 'removed':
          buffer.writeln('-${line.content}');
          break;
        case 'unchanged':
          buffer.writeln(' ${line.content}');
          break;
      }
    }

    setState(() {
      _patchCtrl.text = buffer.toString();
    });
  }

  void _applyPatch() {
    final original = _text1Ctrl.text.split('\n');
    final patch = _patchCtrl.text.split('\n');
    final result = <String>[];
    var originalIdx = 0;

    for (final line in patch) {
      if (line.startsWith('---') || line.startsWith('+++') || line.startsWith('@@')) {
        continue;
      }

      if (line.startsWith('+')) {
        result.add(line.substring(1));
      } else if (line.startsWith('-')) {
        originalIdx++;
      } else if (line.startsWith(' ')) {
        if (originalIdx < original.length) {
          result.add(original[originalIdx]);
          originalIdx++;
        }
      }
    }

    setState(() {
      _text2Ctrl.text = result.join('\n');
    });
  }

  @override
  void dispose() {
    _text1Ctrl.dispose();
    _text2Ctrl.dispose();
    _text3Ctrl.dispose();
    _patchCtrl.dispose();
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
            _buildTabs(colors),
            const SizedBox(height: 24),
            Expanded(
              child: _buildContent(colors),
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
          value: 'diff',
          label: Text('Diff Viewer'),
          icon: Icon(Icons.compare_arrows, size: 18),
        ),
        ButtonSegment(
          value: 'merge',
          label: Text('3-Way Merge'),
          icon: Icon(Icons.merge, size: 18),
        ),
        ButtonSegment(
          value: 'patch',
          label: Text('Patch'),
          icon: Icon(Icons.note_add, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'diff':
        return _buildDiffTab(colors);
      case 'merge':
        return _buildMergeTab(colors);
      case 'patch':
        return _buildPatchTab(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDiffTab(ColorScheme colors) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Checkbox(
                  value: _ignoreWhitespace,
                  onChanged: (v) => setState(() => _ignoreWhitespace = v!),
                ),
                const Text('Ignore whitespace', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Checkbox(
                  value: _ignoreCase,
                  onChanged: (v) => setState(() => _ignoreCase = v!),
                ),
                const Text('Ignore case', style: TextStyle(fontSize: 12)),
                const Spacer(),
                FilledButton.icon(
                  onPressed: () {
                    _computeDiff();
                    _generatePatch();
                  },
                  icon: const Icon(Icons.compare, size: 16),
                  label: const Text('Compare'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'ORIGINAL'),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text1Ctrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter original text...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
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
                    const SectionHeader(title: 'MODIFIED'),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text2Ctrl,
                            decoration: const InputDecoration(
                              hintText: 'Enter modified text...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
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
                      title: 'DIFF RESULT (${_diffResult.where((d) => d.type != 'unchanged').length} changes)',
                      trailing: CopyButton(text: _diffResult.map((d) => d.content).join('\n')),
                    ),
                    Expanded(
                      child: Card(
                        child: _diffResult.isEmpty
                            ? Center(
                                child: Text(
                                  'Click "Compare" to see differences',
                                  style: TextStyle(color: colors.onSurfaceVariant),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8),
                                itemCount: _diffResult.length,
                                itemBuilder: (_, i) => _buildDiffLine(_diffResult[i], colors),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiffLine(_DiffLine line, ColorScheme colors) {
    Color? bgColor;
    IconData? icon;
    Color? iconColor;

    switch (line.type) {
      case 'added':
        bgColor = Colors.green.withValues(alpha: 0.1);
        icon = Icons.add;
        iconColor = Colors.green;
        break;
      case 'removed':
        bgColor = Colors.red.withValues(alpha: 0.1);
        icon = Icons.remove;
        iconColor = Colors.red;
        break;
      case 'unchanged':
        bgColor = null;
        icon = Icons.horizontal_rule;
        iconColor = colors.onSurfaceVariant;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              line.content,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
                color: line.type == 'unchanged' ? colors.onSurfaceVariant : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMergeTab(ColorScheme colors) {
    return Column(
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Text(
                  'Conflicts: ${_conflicts.length}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _conflicts.isEmpty ? Colors.green : Colors.orange,
                  ),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: _compute3WayMerge,
                  icon: const Icon(Icons.merge, size: 16),
                  label: const Text('Merge'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'BASE'),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text1Ctrl,
                            decoration: const InputDecoration(
                              hintText: 'Base version...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'LEFT (Your Changes)'),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text2Ctrl,
                            decoration: const InputDecoration(
                              hintText: 'Your changes...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const SectionHeader(title: 'RIGHT (Their Changes)'),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _text3Ctrl,
                            decoration: const InputDecoration(
                              hintText: 'Their changes...',
                              border: InputBorder.none,
                            ),
                            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
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
                      title: 'MERGED RESULT',
                      trailing: CopyButton(text: _mergeResult),
                    ),
                    Expanded(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            _mergeResult.isEmpty ? 'Click "Merge" to combine changes' : _mergeResult,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: _mergeResult.isEmpty ? colors.onSurfaceVariant : null,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_conflicts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Card(
                        color: colors.errorContainer.withValues(alpha: 0.3),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.warning_amber, size: 16, color: colors.error),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Conflicts detected (${_conflicts.length})',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: colors.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ..._conflicts.take(3).map((c) => Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      'Line ${c.line}: "${c.left}" vs "${c.right}"',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontFamily: 'monospace',
                                        color: colors.onErrorContainer,
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPatchTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'ORIGINAL TEXT'),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _text1Ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Enter original text...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
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
                title: 'PATCH FILE',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () {
                        _computeDiff();
                        _generatePatch();
                      },
                      icon: const Icon(Icons.create, size: 16),
                      label: const Text('Generate'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _applyPatch,
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Apply'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _patchCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Patch will appear here...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
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
                title: 'RESULT',
                trailing: CopyButton(text: _text2Ctrl.text),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _text2Ctrl.text.isEmpty ? 'Apply patch to see result' : _text2Ctrl.text,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _text2Ctrl.text.isEmpty ? colors.onSurfaceVariant : null,
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
}

class _DiffLine {
  final String type;
  final String content;
  final int? lineNum1;
  final int? lineNum2;

  _DiffLine(this.type, this.content, this.lineNum1, this.lineNum2);
}

class _Conflict {
  final int line;
  final String base;
  final String left;
  final String right;

  _Conflict(this.line, this.base, this.left, this.right);
}
