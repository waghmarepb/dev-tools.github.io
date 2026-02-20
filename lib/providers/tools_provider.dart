import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class ToolsProvider extends ChangeNotifier {
  StorageService? _storage;
  List<String> _favorites = [];
  List<String> _recentTools = [];
  Map<String, int> _toolUsage = {};

  List<String> get favorites => _favorites;
  List<String> get recentTools => _recentTools;
  Map<String, int> get toolUsage => _toolUsage;

  Future<void> initialize() async {
    _storage = await StorageService.getInstance();
    _favorites = _storage?.getFavorites() ?? [];
    _recentTools = _storage?.getRecentTools() ?? [];
    _toolUsage = _storage?.getToolUsage() ?? {};
    notifyListeners();
  }

  bool isFavorite(String toolId) {
    return _favorites.contains(toolId);
  }

  Future<void> toggleFavorite(String toolId) async {
    if (isFavorite(toolId)) {
      _favorites.remove(toolId);
      await _storage?.removeFavorite(toolId);
    } else {
      _favorites.add(toolId);
      await _storage?.addFavorite(toolId);
    }
    notifyListeners();
  }

  Future<void> addRecentTool(String toolId) async {
    _recentTools.remove(toolId);
    _recentTools.insert(0, toolId);
    if (_recentTools.length > 10) {
      _recentTools.removeLast();
    }
    await _storage?.addRecentTool(toolId);
    notifyListeners();
  }

  Future<void> incrementToolUsage(String toolId) async {
    _toolUsage[toolId] = (_toolUsage[toolId] ?? 0) + 1;
    await _storage?.incrementToolUsage(toolId);
    notifyListeners();
  }

  List<String> getMostUsedTools({int limit = 5}) {
    final sorted = _toolUsage.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map((e) => e.key).toList();
  }

  Future<Map<String, dynamic>> exportData() async {
    return _storage?.exportAllData() ?? {};
  }

  Future<void> importData(Map<String, dynamic> data) async {
    await _storage?.importData(data);
    await initialize();
  }

  Future<void> clearAllData() async {
    await _storage?.clearAll();
    _favorites = [];
    _recentTools = [];
    _toolUsage = {};
    notifyListeners();
  }
}
