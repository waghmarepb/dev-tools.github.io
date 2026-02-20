import 'package:flutter/foundation.dart';

class RegexProvider extends ChangeNotifier {
  String _pattern = '';
  String _testString = '';
  String _replaceWith = '';
  bool _caseSensitive = true;
  bool _multiLine = false;
  bool _dotAll = false;
  bool _unicode = false;
  List<RegExpMatch> _matches = [];
  String? _error;

  String get pattern => _pattern;
  String get testString => _testString;
  String get replaceWith => _replaceWith;
  bool get caseSensitive => _caseSensitive;
  bool get multiLine => _multiLine;
  bool get dotAll => _dotAll;
  bool get unicode => _unicode;
  List<RegExpMatch> get matches => _matches;
  String? get error => _error;
  int get matchCount => _matches.length;

  String get replacedString {
    if (_pattern.isEmpty || _testString.isEmpty) return '';
    try {
      final regex = RegExp(
        _pattern,
        caseSensitive: _caseSensitive,
        multiLine: _multiLine,
        dotAll: _dotAll,
        unicode: _unicode,
      );
      return _testString.replaceAll(regex, _replaceWith);
    } catch (_) {
      return '';
    }
  }

  void setPattern(String value) {
    _pattern = value;
    _evaluate();
    notifyListeners();
  }

  void setTestString(String value) {
    _testString = value;
    _evaluate();
    notifyListeners();
  }

  void setReplaceWith(String value) {
    _replaceWith = value;
    notifyListeners();
  }

  void toggleCaseSensitive() {
    _caseSensitive = !_caseSensitive;
    _evaluate();
    notifyListeners();
  }

  void toggleMultiLine() {
    _multiLine = !_multiLine;
    _evaluate();
    notifyListeners();
  }

  void toggleDotAll() {
    _dotAll = !_dotAll;
    _evaluate();
    notifyListeners();
  }

  void toggleUnicode() {
    _unicode = !_unicode;
    _evaluate();
    notifyListeners();
  }

  void loadPattern(String pattern) {
    _pattern = pattern;
    _evaluate();
    notifyListeners();
  }

  void loadSample({required String pattern, required String testString}) {
    _pattern = pattern;
    _testString = testString;
    _replaceWith = '';
    _evaluate();
    notifyListeners();
  }

  void clear() {
    _pattern = '';
    _testString = '';
    _replaceWith = '';
    _matches = [];
    _error = null;
    notifyListeners();
  }

  void _evaluate() {
    if (_pattern.isEmpty) {
      _matches = [];
      _error = null;
      return;
    }

    try {
      final regex = RegExp(
        _pattern,
        caseSensitive: _caseSensitive,
        multiLine: _multiLine,
        dotAll: _dotAll,
        unicode: _unicode,
      );
      _matches = regex.allMatches(_testString).toList();
      _error = null;
    } on FormatException catch (e) {
      _matches = [];
      _error = e.message;
    }
  }
}
