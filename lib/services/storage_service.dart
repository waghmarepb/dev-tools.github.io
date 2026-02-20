import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Theme preference
  Future<void> saveThemeMode(String mode) async {
    await _prefs?.setString('theme_mode', mode);
  }

  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  // Favorite tools
  Future<void> saveFavorites(List<String> favorites) async {
    await _prefs?.setStringList('favorite_tools', favorites);
  }

  List<String> getFavorites() {
    return _prefs?.getStringList('favorite_tools') ?? [];
  }

  Future<void> addFavorite(String toolId) async {
    final favorites = getFavorites();
    if (!favorites.contains(toolId)) {
      favorites.add(toolId);
      await saveFavorites(favorites);
    }
  }

  Future<void> removeFavorite(String toolId) async {
    final favorites = getFavorites();
    favorites.remove(toolId);
    await saveFavorites(favorites);
  }

  bool isFavorite(String toolId) {
    return getFavorites().contains(toolId);
  }

  // Recent tools
  Future<void> addRecentTool(String toolId) async {
    final recent = getRecentTools();
    recent.remove(toolId); // Remove if exists
    recent.insert(0, toolId); // Add to front
    if (recent.length > 10) {
      recent.removeLast(); // Keep only last 10
    }
    await _prefs?.setStringList('recent_tools', recent);
  }

  List<String> getRecentTools() {
    return _prefs?.getStringList('recent_tools') ?? [];
  }

  // Code snippets
  Future<void> saveSnippets(List<Map<String, dynamic>> snippets) async {
    final jsonString = jsonEncode(snippets);
    await _prefs?.setString('code_snippets', jsonString);
  }

  List<Map<String, dynamic>> getSnippets() {
    final jsonString = _prefs?.getString('code_snippets');
    if (jsonString == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(jsonString);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  // Tool history (last used inputs)
  Future<void> saveToolHistory(String toolId, Map<String, String> data) async {
    final key = 'history_$toolId';
    final jsonString = jsonEncode(data);
    await _prefs?.setString(key, jsonString);
  }

  Map<String, String> getToolHistory(String toolId) {
    final key = 'history_$toolId';
    final jsonString = _prefs?.getString(key);
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      return {};
    }
  }

  // Tool usage analytics
  Future<void> incrementToolUsage(String toolId) async {
    final usage = getToolUsage();
    usage[toolId] = (usage[toolId] ?? 0) + 1;
    await _prefs?.setString('tool_usage', jsonEncode(usage));
  }

  Map<String, int> getToolUsage() {
    final jsonString = _prefs?.getString('tool_usage');
    if (jsonString == null) return {};
    try {
      final Map<String, dynamic> decoded = jsonDecode(jsonString);
      return decoded.map((key, value) => MapEntry(key, value as int));
    } catch (e) {
      return {};
    }
  }

  // Export all data
  Map<String, dynamic> exportAllData() {
    return {
      'theme_mode': getThemeMode(),
      'favorites': getFavorites(),
      'recent_tools': getRecentTools(),
      'snippets': getSnippets(),
      'tool_usage': getToolUsage(),
      'export_date': DateTime.now().toIso8601String(),
      'version': '2.0.0',
    };
  }

  // Import data
  Future<void> importData(Map<String, dynamic> data) async {
    if (data['theme_mode'] != null) {
      await saveThemeMode(data['theme_mode']);
    }
    if (data['favorites'] != null) {
      await saveFavorites(List<String>.from(data['favorites']));
    }
    if (data['recent_tools'] != null) {
      await _prefs?.setStringList('recent_tools', List<String>.from(data['recent_tools']));
    }
    if (data['snippets'] != null) {
      await saveSnippets(List<Map<String, dynamic>>.from(data['snippets']));
    }
    if (data['tool_usage'] != null) {
      await _prefs?.setString('tool_usage', jsonEncode(data['tool_usage']));
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
