# DevTools - Regex Builder & Developer Utilities

A Flutter app for building and testing regular expressions, plus essential developer utilities to reduce workflow friction.

## Features

### Regex Builder (Core)
- Real-time regex pattern testing with live match highlighting
- Capture group visualization with index tracking
- Find & replace with group reference support (`$1`, `$2`)
- Regex flag toggles: case insensitive, multiline, dotAll, unicode
- Common patterns library (email, URL, phone, IP, dates, etc.)
- Quick reference panel with clickable token insertion
- Copy any result to clipboard

### Developer Utilities
- **JSON Formatter** - Format, validate, and minify JSON with configurable indentation
- **Base64 Encoder/Decoder** - Encode and decode Base64 with swap functionality
- **URL Encoder/Decoder** - Component and full URL encoding/decoding
- **Hash Generator** - Generate MD5, SHA-1, SHA-256, SHA-512 hashes
- **UUID Generator** - Generate v1 (time-based) and v4 (random) UUIDs with bulk generation
- **Timestamp Converter** - Convert between Unix timestamps and human-readable dates
- **Lorem Ipsum Generator** - Generate placeholder text (paragraphs, sentences, or words)

## Getting Started

```bash
flutter pub get
flutter run
```

## Tech Stack

- **Flutter** with Material 3 design
- **Provider** for state management
- **Google Fonts** (Inter) for typography
- **crypto** for hash generation
- **uuid** for UUID generation

## Supported Platforms

- Windows
- macOS
- Linux
- Android
- iOS
- Web
