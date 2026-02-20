import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardService {
  static final Map<ShortcutActivator, VoidCallback> _shortcuts = {};

  static void initialize(BuildContext context) {
    // Initialize keyboard service if needed
  }

  static void registerShortcut(
    ShortcutActivator activator,
    VoidCallback callback,
  ) {
    _shortcuts[activator] = callback;
  }

  static void unregisterShortcut(ShortcutActivator activator) {
    _shortcuts.remove(activator);
  }

  static Map<ShortcutActivator, Intent> getShortcuts() {
    return _shortcuts.map((key, _) => MapEntry(key, const _CustomIntent()));
  }

  static Map<Type, Action<Intent>> getActions() {
    return {
      _CustomIntent: CallbackAction<_CustomIntent>(
        onInvoke: (intent) {
          // Find and execute the callback
          for (final entry in _shortcuts.entries) {
            entry.value();
          }
          return null;
        },
      ),
    };
  }

  // Common shortcuts
  static const searchShortcut = SingleActivator(
    LogicalKeyboardKey.keyK,
    control: true,
  );

  static const toggleSidebarShortcut = SingleActivator(
    LogicalKeyboardKey.slash,
    control: true,
  );

  static const settingsShortcut = SingleActivator(
    LogicalKeyboardKey.comma,
    control: true,
  );

  static const toggleThemeShortcut = SingleActivator(
    LogicalKeyboardKey.keyT,
    control: true,
    shift: true,
  );

  static const historyShortcut = SingleActivator(
    LogicalKeyboardKey.keyH,
    control: true,
  );

  static const executeShortcut = SingleActivator(
    LogicalKeyboardKey.enter,
    control: true,
  );

  static const clearShortcut = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: true,
    shift: true,
  );

  static const copyShortcut = SingleActivator(
    LogicalKeyboardKey.keyC,
    control: true,
  );

  static const pasteShortcut = SingleActivator(
    LogicalKeyboardKey.keyV,
    control: true,
  );

  static const saveShortcut = SingleActivator(
    LogicalKeyboardKey.keyS,
    control: true,
  );

  static const newShortcut = SingleActivator(
    LogicalKeyboardKey.keyN,
    control: true,
  );

  static const closeShortcut = SingleActivator(
    LogicalKeyboardKey.keyW,
    control: true,
  );

  static const refreshShortcut = SingleActivator(
    LogicalKeyboardKey.keyR,
    control: true,
  );

  static const findShortcut = SingleActivator(
    LogicalKeyboardKey.keyF,
    control: true,
  );

  static const helpShortcut = SingleActivator(
    LogicalKeyboardKey.f1,
  );
}

class _CustomIntent extends Intent {
  const _CustomIntent();
}

// Keyboard shortcuts widget wrapper
class KeyboardShortcuts extends StatelessWidget {
  final Widget child;
  final Map<ShortcutActivator, VoidCallback> shortcuts;

  const KeyboardShortcuts({
    super.key,
    required this.child,
    required this.shortcuts,
  });

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: shortcuts.map((key, _) => MapEntry(key, const _CustomIntent())),
      child: Actions(
        actions: {
          _CustomIntent: CallbackAction<_CustomIntent>(
            onInvoke: (intent) {
              // Execute all matching shortcuts
              for (final callback in shortcuts.values) {
                callback();
              }
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: child,
        ),
      ),
    );
  }
}
