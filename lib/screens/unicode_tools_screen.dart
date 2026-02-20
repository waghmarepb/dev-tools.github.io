import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class UnicodeToolsScreen extends StatefulWidget {
  const UnicodeToolsScreen({super.key});

  @override
  State<UnicodeToolsScreen> createState() => _UnicodeToolsScreenState();
}

class _UnicodeToolsScreenState extends State<UnicodeToolsScreen> {
  String _activeTab = 'ascii';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final _charCtrl = TextEditingController();
  Map<String, dynamic>? _charInfo;

  List<_AsciiChar> get _asciiTable => List.generate(128, (i) {
    String char;
    String desc;
    
    if (i < 32) {
      desc = _getControlChar(i);
      char = '^${String.fromCharCode(i + 64)}';
    } else if (i == 32) {
      char = 'SP';
      desc = 'Space';
    } else if (i == 127) {
      char = 'DEL';
      desc = 'Delete';
    } else {
      char = String.fromCharCode(i);
      desc = _getCharDesc(i);
    }
    
    return _AsciiChar(i, char, desc);
  });

  final List<_Emoji> _commonEmojis = [
    _Emoji('😀', 'Grinning Face', 'U+1F600'),
    _Emoji('😂', 'Face with Tears of Joy', 'U+1F602'),
    _Emoji('😍', 'Smiling Face with Heart-Eyes', 'U+1F60D'),
    _Emoji('🤔', 'Thinking Face', 'U+1F914'),
    _Emoji('👍', 'Thumbs Up', 'U+1F44D'),
    _Emoji('👎', 'Thumbs Down', 'U+1F44E'),
    _Emoji('❤️', 'Red Heart', 'U+2764'),
    _Emoji('✅', 'Check Mark', 'U+2705'),
    _Emoji('❌', 'Cross Mark', 'U+274C'),
    _Emoji('⚠️', 'Warning', 'U+26A0'),
    _Emoji('🔥', 'Fire', 'U+1F525'),
    _Emoji('💯', 'Hundred Points', 'U+1F4AF'),
    _Emoji('🎉', 'Party Popper', 'U+1F389'),
    _Emoji('🚀', 'Rocket', 'U+1F680'),
    _Emoji('💻', 'Laptop', 'U+1F4BB'),
    _Emoji('📱', 'Mobile Phone', 'U+1F4F1'),
    _Emoji('🔧', 'Wrench', 'U+1F527'),
    _Emoji('🔨', 'Hammer', 'U+1F528'),
    _Emoji('⚡', 'High Voltage', 'U+26A1'),
    _Emoji('🌟', 'Glowing Star', 'U+1F31F'),
  ];

  String _getControlChar(int code) {
    const names = [
      'NUL', 'SOH', 'STX', 'ETX', 'EOT', 'ENQ', 'ACK', 'BEL',
      'BS', 'TAB', 'LF', 'VT', 'FF', 'CR', 'SO', 'SI',
      'DLE', 'DC1', 'DC2', 'DC3', 'DC4', 'NAK', 'SYN', 'ETB',
      'CAN', 'EM', 'SUB', 'ESC', 'FS', 'GS', 'RS', 'US',
    ];
    return names[code];
  }

  String _getCharDesc(int code) {
    if (code >= 48 && code <= 57) return 'Digit';
    if (code >= 65 && code <= 90) return 'Uppercase Letter';
    if (code >= 97 && code <= 122) return 'Lowercase Letter';
    return 'Symbol';
  }

  void _analyzeChar() {
    final text = _charCtrl.text;
    if (text.isEmpty) {
      setState(() => _charInfo = null);
      return;
    }

    final char = text.characters.first;
    final code = char.codeUnitAt(0);
    
    setState(() {
      _charInfo = {
        'Character': char,
        'Unicode': 'U+${code.toRadixString(16).toUpperCase().padLeft(4, '0')}',
        'Decimal': code.toString(),
        'Hex': '0x${code.toRadixString(16).toUpperCase()}',
        'HTML Entity': '&#$code;',
        'HTML Hex': '&#x${code.toRadixString(16).toUpperCase()};',
        'UTF-8': _getUtf8Bytes(code),
        'Category': _getUnicodeCategory(code),
      };
    });
  }

  String _getUtf8Bytes(int code) {
    final bytes = <int>[];
    if (code < 0x80) {
      bytes.add(code);
    } else if (code < 0x800) {
      bytes.add(0xC0 | (code >> 6));
      bytes.add(0x80 | (code & 0x3F));
    } else if (code < 0x10000) {
      bytes.add(0xE0 | (code >> 12));
      bytes.add(0x80 | ((code >> 6) & 0x3F));
      bytes.add(0x80 | (code & 0x3F));
    } else {
      bytes.add(0xF0 | (code >> 18));
      bytes.add(0x80 | ((code >> 12) & 0x3F));
      bytes.add(0x80 | ((code >> 6) & 0x3F));
      bytes.add(0x80 | (code & 0x3F));
    }
    return bytes.map((b) => '0x${b.toRadixString(16).toUpperCase()}').join(' ');
  }

  String _getUnicodeCategory(int code) {
    if (code < 32) return 'Control Character';
    if (code < 127) return 'ASCII';
    if (code < 256) return 'Latin-1 Supplement';
    if (code < 0x1F600) return 'Unicode';
    return 'Emoji';
  }

  List<_AsciiChar> get _filteredAscii {
    if (_searchQuery.isEmpty) return _asciiTable;
    return _asciiTable.where((a) =>
      a.dec.toString().contains(_searchQuery) ||
      a.char.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      a.desc.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  List<_Emoji> get _filteredEmojis {
    if (_searchQuery.isEmpty) return _commonEmojis;
    return _commonEmojis.where((e) =>
      e.emoji.contains(_searchQuery) ||
      e.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      e.code.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _charCtrl.dispose();
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
              child: _activeTab == 'ascii'
                  ? _buildAsciiTab(colors)
                  : _activeTab == 'emoji'
                      ? _buildEmojiTab(colors)
                      : _buildCharInfoTab(colors),
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
          value: 'ascii',
          label: Text('ASCII Table'),
          icon: Icon(Icons.table_chart, size: 18),
        ),
        ButtonSegment(
          value: 'emoji',
          label: Text('Emoji Picker'),
          icon: Icon(Icons.emoji_emotions, size: 18),
        ),
        ButtonSegment(
          value: 'charinfo',
          label: Text('Character Info'),
          icon: Icon(Icons.info_outline, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildAsciiTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'ASCII TABLE (${_filteredAscii.length} characters)',
          trailing: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search...',
              isDense: true,
              constraints: const BoxConstraints(maxWidth: 200),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: Card(
            child: SingleChildScrollView(
              child: DataTable(
                columnSpacing: 24,
                headingRowHeight: 40,
                dataRowMinHeight: 32,
                dataRowMaxHeight: 32,
                columns: const [
                  DataColumn(label: Text('Dec', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Hex', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Char', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('Description', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                  DataColumn(label: Text('', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                ],
                rows: _filteredAscii.map((a) {
                  return DataRow(
                    cells: [
                      DataCell(Text(a.dec.toString(), style: const TextStyle(fontSize: 12))),
                      DataCell(Text(a.hex, style: const TextStyle(fontSize: 12, fontFamily: 'monospace'))),
                      DataCell(Text(a.char, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))),
                      DataCell(Text(a.desc, style: const TextStyle(fontSize: 12))),
                      DataCell(
                        IconButton(
                          icon: const Icon(Icons.content_copy, size: 14),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: a.char));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Copied: ${a.char}'), duration: const Duration(seconds: 1)),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmojiTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'EMOJI PICKER (${_filteredEmojis.length} emojis)',
          trailing: TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search...',
              isDense: true,
              constraints: const BoxConstraints(maxWidth: 200),
              prefixIcon: const Icon(Icons.search, size: 18),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 150,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: _filteredEmojis.length,
            itemBuilder: (_, i) {
              final emoji = _filteredEmojis[i];
              return Card(
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: emoji.emoji));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied: ${emoji.emoji}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          emoji.emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          emoji.name,
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          emoji.code,
                          style: TextStyle(
                            fontSize: 9,
                            fontFamily: 'monospace',
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCharInfoTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CHARACTER INFO VIEWER'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _charCtrl,
              decoration: const InputDecoration(
                labelText: 'Enter a character',
                hintText: 'Type any character...',
                isDense: true,
              ),
              style: const TextStyle(fontSize: 24),
              onChanged: (_) => _analyzeChar(),
            ),
          ),
        ),
        if (_charInfo != null) ...[
          const SizedBox(height: 16),
          const SectionHeader(title: 'CHARACTER DETAILS'),
          Expanded(
            child: ListView(
              children: _charInfo!.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectableText(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CopyButton(text: entry.value.toString(), iconSize: 14),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

class _AsciiChar {
  final int dec;
  final String char;
  final String desc;

  _AsciiChar(this.dec, this.char, this.desc);

  String get hex => '0x${dec.toRadixString(16).toUpperCase().padLeft(2, '0')}';
}

class _Emoji {
  final String emoji;
  final String name;
  final String code;

  _Emoji(this.emoji, this.name, this.code);
}
