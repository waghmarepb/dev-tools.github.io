class RegexPatternTemplate {
  final String name;
  final String pattern;
  final String description;
  final String category;
  final String sampleText;
  final String? hint;

  const RegexPatternTemplate({
    required this.name,
    required this.pattern,
    required this.description,
    required this.category,
    this.sampleText = '',
    this.hint,
  });

  static const List<RegexPatternTemplate> commonPatterns = [
    // --- Validation ---
    RegexPatternTemplate(
      name: 'Email Address',
      pattern: r'[\w.-]+@[\w.-]+\.\w{2,}',
      description: 'Matches standard email addresses',
      category: 'Validation',
      sampleText: 'Contact us at hello@example.com or support@company.co.uk\n'
          'Invalid: user@, @domain.com, plaintext\n'
          'Also valid: dev.ops+tag@startup.io',
      hint: r'Use ^ and $ anchors for strict full-string validation',
    ),
    RegexPatternTemplate(
      name: 'URL',
      pattern: r'https?://[\w.-]+(?:\.[\w.-]+)+[\w.,@?^=%&:/~+#-]*',
      description: 'Matches HTTP and HTTPS URLs',
      category: 'Validation',
      sampleText: 'Visit https://www.example.com for more info.\n'
          'API endpoint: http://api.server.com/v2/users?page=1&limit=10\n'
          'Secure: https://dashboard.app.io/settings#profile\n'
          'Not a URL: ftp://files.example.com or just google.com',
    ),
    RegexPatternTemplate(
      name: 'Phone (US)',
      pattern: r'(\+1)?[\s.-]?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}',
      description: 'Matches US phone numbers in various formats',
      category: 'Validation',
      sampleText: 'Call us: (555) 123-4567\n'
          'Mobile: 555.987.6543\n'
          'International: +1 800-555-0199\n'
          'Plain: 5551234567\n'
          'Too short: 555-123',
    ),
    RegexPatternTemplate(
      name: 'Strong Password',
      pattern: r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
      description: 'At least 8 chars with uppercase, lowercase, digit, and special character',
      category: 'Validation',
      sampleText: 'MyP@ss1word\n'
          'Str0ng!Pass\n'
          'weakpass\n'
          'NoSpecial1\n'
          'short!A1\n'
          'NOLOWER1!',
      hint: 'Uses lookaheads (?=...) to assert multiple conditions simultaneously',
    ),
    RegexPatternTemplate(
      name: 'SSN (US)',
      pattern: r'\b\d{3}-\d{2}-\d{4}\b',
      description: 'Matches US Social Security Numbers (XXX-XX-XXXX)',
      category: 'Validation',
      sampleText: 'SSN: 123-45-6789\n'
          'Another: 987-65-4321\n'
          'Invalid: 12-345-6789 or 1234567890',
    ),

    // --- Network ---
    RegexPatternTemplate(
      name: 'IPv4 Address',
      pattern: r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
      description: 'Matches IPv4 addresses like 192.168.1.1',
      category: 'Network',
      sampleText: 'Server: 192.168.1.1\n'
          'Gateway: 10.0.0.1\n'
          'DNS: 8.8.8.8 and 8.8.4.4\n'
          'Broadcast: 255.255.255.0\n'
          'Not IP: 999.999.999.999 (still matches — add range check for strict validation)',
    ),
    RegexPatternTemplate(
      name: 'IPv6 Address',
      pattern: r'([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}',
      description: 'Matches full IPv6 addresses',
      category: 'Network',
      sampleText: 'Full IPv6: 2001:0db8:85a3:0000:0000:8a2e:0370:7334\n'
          'Another: fe80:0000:0000:0000:0202:b3ff:fe1e:8329\n'
          'Shortened forms like ::1 or fe80::1 are NOT matched by this pattern',
    ),
    RegexPatternTemplate(
      name: 'MAC Address',
      pattern: r'([0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}',
      description: 'Matches MAC addresses in colon or dash format',
      category: 'Network',
      sampleText: 'WiFi adapter: 00:1A:2B:3C:4D:5E\n'
          'Ethernet: 01-23-45-67-89-AB\n'
          'Invalid: 00:1A:2B:3C:4D or ZZZZZZZZZZZZ',
    ),

    // --- Code ---
    RegexPatternTemplate(
      name: 'Hex Color',
      pattern: r'#([0-9a-fA-F]{3}|[0-9a-fA-F]{6})\b',
      description: 'Matches hex color codes like #FFF or #FF5733',
      category: 'Code',
      sampleText: 'Primary: #6C63FF\n'
          'Background: #F5F5F5\n'
          'Short form: #FFF and #000\n'
          'Accent color: #FF5733\n'
          'Invalid: #GGG or #12345',
    ),
    RegexPatternTemplate(
      name: 'HTML Tag',
      pattern: r'<([a-zA-Z][a-zA-Z0-9]*)\b[^>]*>(.*?)</\1>',
      description: 'Matches paired opening and closing HTML tags with content',
      category: 'Code',
      sampleText: '<div class="container">Hello World</div>\n'
          '<p>This is a paragraph</p>\n'
          '<span>Inline text</span>\n'
          '<img src="photo.jpg" /> (self-closing — not matched)\n'
          '<a href="https://example.com">Click here</a>',
    ),
    RegexPatternTemplate(
      name: 'UUID',
      pattern: r'[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}',
      description: 'Matches UUID format (v1 through v5)',
      category: 'Code',
      sampleText: 'User ID: 550e8400-e29b-41d4-a716-446655440000\n'
          'Session: 6ba7b810-9dad-11d1-80b4-00c04fd430c8\n'
          'Token: f47ac10b-58cc-4372-a567-0e02b2c3d479\n'
          'Not valid: 550e8400-e29b-ZZZZ-a716-446655440000',
    ),
    RegexPatternTemplate(
      name: 'JSON Key-Value',
      pattern: r'"(\w+)"\s*:\s*"([^"]*)"',
      description: 'Matches simple JSON string key-value pairs',
      category: 'Code',
      sampleText: '{\n'
          '  "name": "John Doe",\n'
          '  "email": "john@example.com",\n'
          '  "role": "admin",\n'
          '  "age": 30,\n'
          '  "active": true\n'
          '}',
      hint: 'Only matches string values — numeric and boolean values are not captured',
    ),
    RegexPatternTemplate(
      name: 'CSS Property',
      pattern: r'([a-z-]+)\s*:\s*([^;]+);',
      description: 'Matches CSS property-value declarations',
      category: 'Code',
      sampleText: '.card {\n'
          '  background-color: #ffffff;\n'
          '  border-radius: 12px;\n'
          '  padding: 16px 24px;\n'
          '  box-shadow: 0 2px 8px rgba(0,0,0,0.1);\n'
          '  font-size: 14px;\n'
          '}',
    ),
    RegexPatternTemplate(
      name: 'Import Statement (JS/TS)',
      pattern: r'''import\s+(?:\{[^}]*\}|[\w*]+)\s+from\s+['"]([^'"]+)['"]''',
      description: 'Matches JavaScript/TypeScript import statements',
      category: 'Code',
      sampleText: "import React from 'react';\n"
          "import { useState, useEffect } from 'react';\n"
          "import * as utils from './utils';\n"
          "import axios from 'axios';\n"
          "const x = require('old-style'); // not matched",
    ),
    RegexPatternTemplate(
      name: 'Log Level Extractor',
      pattern: r'\[(INFO|WARN|ERROR|DEBUG|FATAL)\]\s*(.+)',
      description: 'Extracts log level and message from structured log lines',
      category: 'Code',
      sampleText: '2024-01-15 10:23:45 [INFO] Application started successfully\n'
          '2024-01-15 10:23:46 [DEBUG] Loading config from /etc/app.conf\n'
          '2024-01-15 10:24:01 [WARN] Disk usage above 80%\n'
          '2024-01-15 10:24:15 [ERROR] Failed to connect to database\n'
          '2024-01-15 10:24:16 [FATAL] Unrecoverable error, shutting down',
      hint: 'Group 1 captures the level, Group 2 captures the message',
    ),

    // --- Date & Time ---
    RegexPatternTemplate(
      name: 'Date (YYYY-MM-DD)',
      pattern: r'\d{4}-(0[1-9]|1[0-2])-(0[1-9]|[12]\d|3[01])',
      description: 'Matches dates in ISO 8601 format',
      category: 'Date & Time',
      sampleText: 'Created: 2024-01-15\n'
          'Updated: 2024-12-31\n'
          'Deadline: 2025-06-30\n'
          'Invalid: 2024-13-01 or 2024-00-15',
    ),
    RegexPatternTemplate(
      name: 'Time (HH:MM:SS)',
      pattern: r'([01]\d|2[0-3]):([0-5]\d):([0-5]\d)',
      description: 'Matches 24-hour time format',
      category: 'Date & Time',
      sampleText: 'Start: 09:30:00\n'
          'End: 17:45:30\n'
          'Midnight: 00:00:00\n'
          'Last second: 23:59:59\n'
          'Invalid: 25:00:00 or 12:60:00',
    ),
    RegexPatternTemplate(
      name: 'ISO 8601 DateTime',
      pattern: r'\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})',
      description: 'Matches full ISO 8601 datetime with timezone',
      category: 'Date & Time',
      sampleText: 'Timestamp: 2024-01-15T10:30:00Z\n'
          'With offset: 2024-06-20T14:45:30+05:30\n'
          'Milliseconds: 2024-12-31T23:59:59.999Z\n'
          'Pacific: 2024-03-10T08:00:00-08:00',
    ),
    RegexPatternTemplate(
      name: 'Relative Date (English)',
      pattern: r'(\d+)\s+(second|minute|hour|day|week|month|year)s?\s+ago',
      description: 'Matches relative time expressions like "5 minutes ago"',
      category: 'Date & Time',
      sampleText: 'Posted 5 minutes ago\n'
          'Last updated 3 hours ago\n'
          'Created 1 day ago\n'
          'Joined 2 years ago\n'
          'Edited 30 seconds ago',
    ),

    // --- Finance ---
    RegexPatternTemplate(
      name: 'Credit Card Number',
      pattern: r'\b(?:\d{4}[- ]?){3}\d{4}\b',
      description: 'Matches credit card numbers with optional separators',
      category: 'Finance',
      sampleText: 'Visa: 4111 1111 1111 1111\n'
          'MasterCard: 5500-0000-0000-0004\n'
          'Amex: 3714 4963 5398 431 (15 digits — not matched)\n'
          'Plain: 4012888888881881\n'
          'Too short: 1234-5678',
    ),
    RegexPatternTemplate(
      name: 'Currency Amount',
      pattern: r'[\$€£¥]\s?\d{1,3}(?:[,.]?\d{3})*(?:\.\d{2})?',
      description: r'Matches currency amounts like $1,234.56',
      category: 'Finance',
      sampleText: 'Price: \$99.99\n'
          'Total: \$1,234.56\n'
          'Euro: €500.00\n'
          'Pounds: £1,000\n'
          'Yen: ¥50000\n'
          'Invalid: 1234.56 (no currency symbol)',
    ),

    // --- Text Processing ---
    RegexPatternTemplate(
      name: 'Whitespace Trimmer',
      pattern: r'^\s+|\s+$',
      description: 'Matches leading and trailing whitespace',
      category: 'Text',
      sampleText: '   Hello World   \n'
          '  Indented line\n'
          'No whitespace here\n'
          '\tTabbed content\t',
      hint: 'Enable Multi-line flag to trim each line individually',
    ),
    RegexPatternTemplate(
      name: 'Duplicate Words',
      pattern: r'\b(\w+)\s+\1\b',
      description: 'Finds consecutive duplicate words',
      category: 'Text',
      sampleText: 'This is is a test sentence.\n'
          'The the quick brown fox.\n'
          'No duplicates here.\n'
          'Check for for repeated words words in text.',
      hint: r'Uses backreference \1 to match the same word captured in group 1',
    ),
    RegexPatternTemplate(
      name: 'CamelCase Splitter',
      pattern: r'[A-Z][a-z]+|[a-z]+|[A-Z]+(?=[A-Z][a-z]|\b)',
      description: 'Splits camelCase and PascalCase identifiers into words',
      category: 'Text',
      sampleText: 'getUserName\n'
          'HTTPSConnection\n'
          'parseXMLDocument\n'
          'backgroundColor\n'
          'IOStreamReader',
    ),
    RegexPatternTemplate(
      name: 'Markdown Links',
      pattern: r'\[([^\]]+)\]\(([^)]+)\)',
      description: 'Matches Markdown link syntax [text](url)',
      category: 'Text',
      sampleText: 'Check out [Flutter](https://flutter.dev) for mobile dev.\n'
          'Read the [documentation](https://docs.example.com/guide).\n'
          'See [this issue](https://github.com/org/repo/issues/42).\n'
          'Plain URL: https://example.com (not matched)',
      hint: 'Group 1 = link text, Group 2 = URL',
    ),
    RegexPatternTemplate(
      name: 'Email Addresses in Text',
      pattern: r'\b[\w.+-]+@[\w-]+\.[\w.-]+\b',
      description: 'Extracts all email addresses from a block of text',
      category: 'Text',
      sampleText: 'Contact the team:\n'
          '- Project lead: alice@company.com\n'
          '- DevOps: bob.smith+deploy@infra.company.co.uk\n'
          '- Support: help@support.io\n'
          '- Not an email: user@ or @domain.com',
    ),

    // --- Data Extraction ---
    RegexPatternTemplate(
      name: 'Version Number (SemVer)',
      pattern: r'v?(\d+)\.(\d+)\.(\d+)(?:[-+][\w.]+)?',
      description: 'Matches semantic version numbers like v2.1.0 or 1.0.0-beta.1',
      category: 'Data Extraction',
      sampleText: 'Current version: v2.1.0\n'
          'Previous: 1.9.3\n'
          'Pre-release: 3.0.0-beta.1\n'
          'Build meta: 1.0.0+build.42\n'
          'Flutter SDK: 3.19.0',
      hint: 'Groups capture major, minor, and patch numbers separately',
    ),
    RegexPatternTemplate(
      name: 'File Path (Unix)',
      pattern: r'(?:/[\w.-]+)+(?:\.\w+)?',
      description: 'Matches Unix-style file paths',
      category: 'Data Extraction',
      sampleText: 'Config: /etc/nginx/nginx.conf\n'
          'Home: /home/user/.bashrc\n'
          'App: /var/www/html/index.html\n'
          'Log: /var/log/app/error.log\n'
          'Dir: /usr/local/bin',
    ),
    RegexPatternTemplate(
      name: 'Hashtags',
      pattern: r'#\w+',
      description: 'Matches social media hashtags',
      category: 'Data Extraction',
      sampleText: 'Loving the new features! #Flutter #Dart #MobileDev\n'
          'Just shipped v2.0 #release #coding #100DaysOfCode\n'
          'Check out #regex_builder for testing patterns',
    ),
    RegexPatternTemplate(
      name: 'Quoted Strings',
      pattern: r'''(["'])(?:(?!\1|\\).|\\.)*\1''',
      description: 'Matches single or double quoted strings, handling escapes',
      category: 'Data Extraction',
      sampleText: 'message = "Hello, World!"\n'
          "name = 'John\\'s App'\n"
          'path = "/usr/local/bin"\n'
          'empty = ""\n'
          'escaped = "She said \\"hi\\""',
      hint: r'Uses backreference \1 to match the same quote type that opened the string',
    ),
    RegexPatternTemplate(
      name: 'Environment Variables',
      pattern: r'\$\{?(\w+)\}?',
      description: r'Matches shell-style environment variable references like $HOME or ${PATH}',
      category: 'Data Extraction',
      sampleText: 'export PATH=\$HOME/bin:\$PATH\n'
          'DB_URL=postgres://\${DB_HOST}:\${DB_PORT}/\${DB_NAME}\n'
          'echo "Hello \$USER, your shell is \$SHELL"',
    ),
  ];
}

class RegexToken {
  final String token;
  final String description;
  final String category;

  const RegexToken({
    required this.token,
    required this.description,
    required this.category,
  });

  static const List<RegexToken> referenceTokens = [
    RegexToken(token: '.', description: 'Any character except newline', category: 'Basics'),
    RegexToken(token: r'\d', description: 'Digit [0-9]', category: 'Basics'),
    RegexToken(token: r'\D', description: 'Non-digit', category: 'Basics'),
    RegexToken(token: r'\w', description: 'Word character [a-zA-Z0-9_]', category: 'Basics'),
    RegexToken(token: r'\W', description: 'Non-word character', category: 'Basics'),
    RegexToken(token: r'\s', description: 'Whitespace', category: 'Basics'),
    RegexToken(token: r'\S', description: 'Non-whitespace', category: 'Basics'),
    RegexToken(token: '^', description: 'Start of string', category: 'Anchors'),
    RegexToken(token: r'$', description: 'End of string', category: 'Anchors'),
    RegexToken(token: r'\b', description: 'Word boundary', category: 'Anchors'),
    RegexToken(token: '*', description: '0 or more', category: 'Quantifiers'),
    RegexToken(token: '+', description: '1 or more', category: 'Quantifiers'),
    RegexToken(token: '?', description: '0 or 1', category: 'Quantifiers'),
    RegexToken(token: '{n}', description: 'Exactly n times', category: 'Quantifiers'),
    RegexToken(token: '{n,m}', description: 'Between n and m times', category: 'Quantifiers'),
    RegexToken(token: '(abc)', description: 'Capture group', category: 'Groups'),
    RegexToken(token: '(?:abc)', description: 'Non-capturing group', category: 'Groups'),
    RegexToken(token: '(?=abc)', description: 'Positive lookahead', category: 'Groups'),
    RegexToken(token: '(?!abc)', description: 'Negative lookahead', category: 'Groups'),
    RegexToken(token: '[abc]', description: 'Character class', category: 'Sets'),
    RegexToken(token: '[^abc]', description: 'Negated character class', category: 'Sets'),
    RegexToken(token: '[a-z]', description: 'Range', category: 'Sets'),
    RegexToken(token: 'a|b', description: 'Alternation (or)', category: 'Logic'),
  ];
}
