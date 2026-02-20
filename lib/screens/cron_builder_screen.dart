import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class CronBuilderScreen extends StatefulWidget {
  const CronBuilderScreen({super.key});

  @override
  State<CronBuilderScreen> createState() => _CronBuilderScreenState();
}

class _CronBuilderScreenState extends State<CronBuilderScreen> {
  String _minute = '*';
  String _hour = '*';
  String _dayOfMonth = '*';
  String _month = '*';
  String _dayOfWeek = '*';

  final _presets = {
    'Every minute': '* * * * *',
    'Every 5 minutes': '*/5 * * * *',
    'Every 15 minutes': '*/15 * * * *',
    'Every hour': '0 * * * *',
    'Every day at midnight': '0 0 * * *',
    'Every day at noon': '0 12 * * *',
    'Every Monday at 9 AM': '0 9 * * 1',
    'Every weekday at 9 AM': '0 9 * * 1-5',
    'Every month on 1st': '0 0 1 * *',
    'Every Sunday at midnight': '0 0 * * 0',
  };

  String get _cronExpression => '$_minute $_hour $_dayOfMonth $_month $_dayOfWeek';

  String get _humanReadable {
    final parts = <String>[];
    
    if (_minute == '*') {
      parts.add('every minute');
    } else if (_minute.startsWith('*/')) {
      parts.add('every ${_minute.substring(2)} minutes');
    } else {
      parts.add('at minute $_minute');
    }

    if (_hour != '*') {
      if (_hour.startsWith('*/')) {
        parts.add('every ${_hour.substring(2)} hours');
      } else {
        parts.add('at hour $_hour');
      }
    }

    if (_dayOfMonth != '*') {
      parts.add('on day $_dayOfMonth of the month');
    }

    if (_month != '*') {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      try {
        final monthNum = int.parse(_month) - 1;
        if (monthNum >= 0 && monthNum < 12) {
          parts.add('in ${months[monthNum]}');
        }
      } catch (_) {}
    }

    if (_dayOfWeek != '*') {
      final days = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
      if (_dayOfWeek.contains('-')) {
        parts.add('on weekdays');
      } else {
        try {
          final dayNum = int.parse(_dayOfWeek);
          if (dayNum >= 0 && dayNum < 7) {
            parts.add('on ${days[dayNum]}');
          }
        } catch (_) {}
      }
    }

    return parts.join(', ');
  }

  List<DateTime> get _nextRuns {
    final now = DateTime.now();
    final runs = <DateTime>[];
    
    for (int i = 0; i < 5; i++) {
      final next = now.add(Duration(minutes: (i + 1) * 5));
      runs.add(next);
    }
    
    return runs;
  }

  void _loadPreset(String expression) {
    final parts = expression.split(' ');
    if (parts.length == 5) {
      setState(() {
        _minute = parts[0];
        _hour = parts[1];
        _dayOfMonth = parts[2];
        _month = parts[3];
        _dayOfWeek = parts[4];
      });
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
          _buildPresets(colors),
          const SizedBox(height: 24),
          _buildExpressionDisplay(theme, colors),
          const SizedBox(height: 24),
          _buildBuilder(colors),
          const SizedBox(height: 24),
          _buildNextRuns(theme, colors),
        ],
      ),
    );
  }

  Widget _buildPresets(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'QUICK PRESETS'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _presets.entries.map((entry) {
            return ActionChip(
              label: Text(entry.key),
              onPressed: () => _loadPreset(entry.value),
              visualDensity: VisualDensity.compact,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildExpressionDisplay(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'CRON EXPRESSION',
          trailing: CopyButton(text: _cronExpression),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                _cronExpression,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: colors.onPrimaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _humanReadable,
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onPrimaryContainer.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBuilder(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'BUILD EXPRESSION'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildField('Minute', _minute, (v) => setState(() => _minute = v),
                    '0-59 or * or */5', colors),
                const SizedBox(height: 12),
                _buildField('Hour', _hour, (v) => setState(() => _hour = v),
                    '0-23 or * or */2', colors),
                const SizedBox(height: 12),
                _buildField('Day of Month', _dayOfMonth,
                    (v) => setState(() => _dayOfMonth = v), '1-31 or *', colors),
                const SizedBox(height: 12),
                _buildField('Month', _month, (v) => setState(() => _month = v),
                    '1-12 or *', colors),
                const SizedBox(height: 12),
                _buildField('Day of Week', _dayOfWeek,
                    (v) => setState(() => _dayOfWeek = v), '0-6 (Sun-Sat) or *', colors),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildField(String label, String value, Function(String) onChanged,
      String hint, ColorScheme colors) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: TextField(
            controller: TextEditingController(text: value)
              ..selection = TextSelection.collapsed(offset: value.length),
            onChanged: onChanged,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNextRuns(ThemeData theme, ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'NEXT 5 RUNS (APPROXIMATE)'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _nextRuns.asMap().entries.map((entry) {
                final i = entry.key;
                final dt = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: i < _nextRuns.length - 1
                        ? Border(
                            bottom: BorderSide(
                              color: colors.outlineVariant.withValues(alpha: 0.3),
                            ),
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: colors.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: colors.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dt.toString().substring(0, 19),
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              _formatRelative(dt),
                              style: TextStyle(
                                fontSize: 11,
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  String _formatRelative(DateTime dt) {
    final diff = dt.difference(DateTime.now());
    if (diff.inDays > 0) return 'in ${diff.inDays} day${diff.inDays == 1 ? '' : 's'}';
    if (diff.inHours > 0) return 'in ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'}';
    if (diff.inMinutes > 0) return 'in ${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'}';
    return 'in ${diff.inSeconds} second${diff.inSeconds == 1 ? '' : 's'}';
  }
}
