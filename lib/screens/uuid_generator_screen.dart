import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class UuidGeneratorScreen extends StatefulWidget {
  const UuidGeneratorScreen({super.key});

  @override
  State<UuidGeneratorScreen> createState() => _UuidGeneratorScreenState();
}

class _UuidGeneratorScreenState extends State<UuidGeneratorScreen> {
  final _uuid = const Uuid();
  List<_GeneratedUuid> _uuids = [];
  int _version = 4;
  int _count = 1;
  bool _uppercase = false;
  bool _noDashes = false;

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _uuids = List.generate(_count, (_) {
        String value;
        switch (_version) {
          case 1:
            value = _uuid.v1();
            break;
          case 4:
          default:
            value = _uuid.v4();
            break;
        }
        if (_uppercase) value = value.toUpperCase();
        if (_noDashes) value = value.replaceAll('-', '');
        return _GeneratedUuid(value: value);
      });
    });
  }

  String get _allUuids => _uuids.map((u) => u.value).join('\n');

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('UUID Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Version',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 6),
                              SegmentedButton<int>(
                                segments: const [
                                  ButtonSegment(
                                      value: 1, label: Text('v1 (Time)')),
                                  ButtonSegment(
                                      value: 4, label: Text('v4 (Random)')),
                                ],
                                selected: {_version},
                                onSelectionChanged: (v) =>
                                    setState(() => _version = v.first),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Count',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: 80,
                              child: DropdownButtonFormField<int>(
                                initialValue: _count,
                                isDense: true,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                ),
                                items: [1, 5, 10, 25, 50]
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text('$c'),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) setState(() => _count = v);
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        FilterChip(
                          label: const Text('Uppercase'),
                          selected: _uppercase,
                          onSelected: (v) =>
                              setState(() => _uppercase = v),
                          visualDensity: VisualDensity.compact,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('No dashes'),
                          selected: _noDashes,
                          onSelected: (v) =>
                              setState(() => _noDashes = v),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            SectionHeader(
              title: 'GENERATED UUIDs',
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CopyButton(text: _allUuids, tooltip: 'Copy all'),
                  Text(
                    '${_uuids.length} UUID${_uuids.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _uuids.length,
                itemBuilder: (context, index) {
                  final uuid = _uuids[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '${index + 1}.',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SelectableText(
                            uuid.value,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                        CopyButton(text: uuid.value, iconSize: 16),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GeneratedUuid {
  final String value;
  const _GeneratedUuid({required this.value});
}
