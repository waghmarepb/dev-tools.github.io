import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class MarkdownPreviewScreen extends StatefulWidget {
  const MarkdownPreviewScreen({super.key});

  @override
  State<MarkdownPreviewScreen> createState() => _MarkdownPreviewScreenState();
}

class _MarkdownPreviewScreenState extends State<MarkdownPreviewScreen> {
  final _inputCtrl = TextEditingController(text: _sampleMarkdown);
  String _markdown = _sampleMarkdown;

  static const _sampleMarkdown = '''# Welcome to Markdown Preview

## Features

This is a **live** markdown editor with *instant* preview.

### Text Formatting

- **Bold text**
- *Italic text*
- ~~Strikethrough~~
- `Inline code`

### Lists

1. First item
2. Second item
3. Third item

### Code Block

```dart
void main() {
  print('Hello, Flutter!');
}
```

### Links and Images

[Visit Flutter](https://flutter.dev)

### Blockquote

> This is a blockquote.
> It can span multiple lines.

### Table

| Feature | Status |
|---------|--------|
| Headers | ✅ |
| Lists | ✅ |
| Code | ✅ |

---

**Start editing** to see your changes!
''';

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
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionHeader(
                    title: 'MARKDOWN INPUT',
                    trailing: CopyButton(text: _markdown),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _inputCtrl,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.5,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Enter markdown here...',
                      ),
                      onChanged: (v) => setState(() => _markdown = v),
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
                  const SectionHeader(title: 'PREVIEW'),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: colors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colors.outlineVariant.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Markdown(
                        data: _markdown,
                        selectable: true,
                        styleSheet: MarkdownStyleSheet(
                          h1: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          h2: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                          h3: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                          p: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                          ),
                          code: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            backgroundColor: colors.surfaceContainerHighest,
                          ),
                          codeblockDecoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          blockquoteDecoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(4),
                            border: Border(
                              left: BorderSide(
                                color: colors.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          tableBorder: TableBorder.all(
                            color: colors.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
