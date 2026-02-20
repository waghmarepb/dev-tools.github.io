import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class TimestampConverterScreen extends StatefulWidget {
  const TimestampConverterScreen({super.key});

  @override
  State<TimestampConverterScreen> createState() =>
      _TimestampConverterScreenState();
}

class _TimestampConverterScreenState extends State<TimestampConverterScreen> {
  final _timestampCtrl = TextEditingController();
  DateTime _currentTime = DateTime.now();
  DateTime? _convertedTime;
  String? _error;
  bool _isSeconds = true;

  @override
  void initState() {
    super.initState();
    _startClock();
  }

  void _startClock() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() => _currentTime = DateTime.now());
      return true;
    });
  }

  void _convertTimestamp() {
    if (_timestampCtrl.text.trim().isEmpty) {
      setState(() {
        _convertedTime = null;
        _error = null;
      });
      return;
    }

    try {
      final value = int.parse(_timestampCtrl.text.trim());
      setState(() {
        _convertedTime = _isSeconds
            ? DateTime.fromMillisecondsSinceEpoch(value * 1000)
            : DateTime.fromMillisecondsSinceEpoch(value);
        _error = null;
      });
    } catch (_) {
      setState(() {
        _error = 'Invalid timestamp';
        _convertedTime = null;
      });
    }
  }

  void _setNow() {
    final now = DateTime.now();
    final value = _isSeconds
        ? now.millisecondsSinceEpoch ~/ 1000
        : now.millisecondsSinceEpoch;
    _timestampCtrl.text = value.toString();
    _convertTimestamp();
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.toUtc().toIso8601String()}\n'
        '${dt.toLocal()}\n'
        '${_dayOfWeek(dt.weekday)}, ${_monthName(dt.month)} ${dt.day}, ${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  String _dayOfWeek(int day) {
    const days = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    return days[day - 1];
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return months[month - 1];
  }

  @override
  void dispose() {
    _timestampCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final nowSeconds = _currentTime.millisecondsSinceEpoch ~/ 1000;
    final nowMillis = _currentTime.millisecondsSinceEpoch;

    return Scaffold(
      appBar: AppBar(title: const Text('Timestamp Converter')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Time',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _infoRow(
                    'Unix (seconds)',
                    nowSeconds.toString(),
                    colors,
                  ),
                  _infoRow(
                    'Unix (milliseconds)',
                    nowMillis.toString(),
                    colors,
                  ),
                  _infoRow(
                    'UTC',
                    _currentTime.toUtc().toIso8601String(),
                    colors,
                  ),
                  _infoRow(
                    'Local',
                    _currentTime.toLocal().toString(),
                    colors,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SectionHeader(title: 'CONVERT TIMESTAMP'),
          Row(
            children: [
              SegmentedButton<bool>(
                segments: const [
                  ButtonSegment(value: true, label: Text('Seconds')),
                  ButtonSegment(value: false, label: Text('Milliseconds')),
                ],
                selected: {_isSeconds},
                onSelectionChanged: (v) {
                  setState(() => _isSeconds = v.first);
                  _convertTimestamp();
                },
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _setNow,
                icon: const Icon(Icons.access_time, size: 16),
                label: const Text('Now'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _timestampCtrl,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Enter Unix timestamp...',
              errorText: _error,
              suffixIcon: CopyButton(text: _timestampCtrl.text),
            ),
            onChanged: (_) => _convertTimestamp(),
          ),
          if (_convertedTime != null) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Converted Result',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colors.primary,
                          ),
                        ),
                        const Spacer(),
                        CopyButton(text: _formatDateTime(_convertedTime!)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _formatDateTime(_convertedTime!),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        height: 1.8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          const SectionHeader(title: 'CONVERT DATE TO TIMESTAMP'),
          _DateToTimestamp(colors: colors),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
              ),
            ),
          ),
          CopyButton(text: value, iconSize: 14),
        ],
      ),
    );
  }
}

class _DateToTimestamp extends StatefulWidget {
  final ColorScheme colors;
  const _DateToTimestamp({required this.colors});

  @override
  State<_DateToTimestamp> createState() => _DateToTimestampState();
}

class _DateToTimestampState extends State<_DateToTimestamp> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  DateTime get _combined => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  @override
  Widget build(BuildContext context) {
    final ts = _combined.millisecondsSinceEpoch ~/ 1000;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(1970),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) setState(() => _selectedDate = date);
                  },
                  icon: const Icon(Icons.calendar_today, size: 16),
                  label: Text(
                    '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) setState(() => _selectedTime = time);
                  },
                  icon: const Icon(Icons.access_time, size: 16),
                  label: Text(
                    '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Unix: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.colors.onSurfaceVariant,
                  ),
                ),
                SelectableText(
                  ts.toString(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.colors.primary,
                  ),
                ),
                CopyButton(text: ts.toString(), iconSize: 16),
                const SizedBox(width: 12),
                Text(
                  'ms: ',
                  style: TextStyle(
                    fontSize: 13,
                    color: widget.colors.onSurfaceVariant,
                  ),
                ),
                SelectableText(
                  (_combined.millisecondsSinceEpoch).toString(),
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: widget.colors.primary,
                  ),
                ),
                CopyButton(
                  text: _combined.millisecondsSinceEpoch.toString(),
                  iconSize: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
