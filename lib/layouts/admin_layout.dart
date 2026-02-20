import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../config/tools_config.dart';
import '../models/tool_item.dart';
import '../providers/theme_provider.dart';
import '../widgets/command_palette.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;
  final String? currentRoute;

  const AdminLayout({
    super.key,
    required this.child,
    this.currentRoute,
  });

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _sidebarExpanded = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  List<ToolItem> get _filteredTools {
    if (_searchQuery.isEmpty) return [];
    return ToolsConfig.allTools.where((tool) {
      return tool.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tool.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
    }).toList();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK):
            const _ShowCommandPaletteIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.slash):
            const _ToggleSidebarIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.shift, LogicalKeyboardKey.keyT):
            const _ToggleThemeIntent(),
      },
      child: Actions(
        actions: {
          _ShowCommandPaletteIntent: CallbackAction<_ShowCommandPaletteIntent>(
            onInvoke: (_) {
              CommandPalette.show(context);
              return null;
            },
          ),
          _ToggleSidebarIntent: CallbackAction<_ToggleSidebarIntent>(
            onInvoke: (_) {
              setState(() => _sidebarExpanded = !_sidebarExpanded);
              return null;
            },
          ),
          _ToggleThemeIntent: CallbackAction<_ToggleThemeIntent>(
            onInvoke: (_) {
              context.read<ThemeProvider>().toggleTheme();
              return null;
            },
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                if (isWide)
                  _buildSidebar(colors)
                else if (_sidebarExpanded)
                  _buildSidebar(colors),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(colors, isWide),
                      Expanded(child: widget.child),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar(ColorScheme colors) {
    return Container(
      width: _sidebarExpanded ? 280 : 72,
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        children: [
          _buildSidebarHeader(colors),
          if (_sidebarExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Search tools...',
                  prefixIcon: const Icon(Icons.search, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close, size: 16),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
            ),
          ],
          Expanded(
            child: _searchQuery.isNotEmpty
                ? _buildSearchResults(colors)
                : _buildNavigationItems(colors),
          ),
          _buildSidebarFooter(colors),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(ColorScheme colors) {
    return Container(
      height: 64,
      padding: EdgeInsets.symmetric(horizontal: _sidebarExpanded ? 16 : 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.developer_mode_rounded,
              color: colors.onPrimary,
              size: 24,
            ),
          ),
          if (_sidebarExpanded) ...[
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DevTools',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Pro Suite',
                    style: TextStyle(
                      fontSize: 11,
                      color: colors.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchResults(ColorScheme colors) {
    final results = _filteredTools;
    
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search_off_rounded, size: 32, color: colors.onSurfaceVariant),
              const SizedBox(height: 8),
              Text(
                'No tools found',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      itemCount: results.length,
      itemBuilder: (_, i) {
        final tool = results[i];
        return _buildToolTile(tool, colors, isSearchResult: true);
      },
    );
  }

  Widget _buildNavigationItems(ColorScheme colors) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      children: [
        _buildNavItem(
          icon: Icons.dashboard_rounded,
          label: 'Dashboard',
          route: '/',
          colors: colors,
        ),
        const SizedBox(height: 16),
        ...ToolsConfig.categories.map((category) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_sidebarExpanded)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                  child: Text(
                    category.name.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: colors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ...category.tools.map((tool) => _buildToolTile(tool, colors)),
              const SizedBox(height: 8),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildToolTile(ToolItem tool, ColorScheme colors, {bool isSearchResult = false}) {
    final isActive = widget.currentRoute == tool.route;
    
    return Tooltip(
      message: _sidebarExpanded ? '' : tool.name,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _sidebarExpanded ? 12 : 8,
            vertical: 2,
          ),
          leading: Icon(
            tool.icon,
            size: 20,
            color: isActive
                ? colors.onPrimaryContainer
                : tool.iconColor ?? colors.onSurfaceVariant,
          ),
          title: _sidebarExpanded
              ? Text(
                  tool.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colors.onPrimaryContainer : colors.onSurface,
                  ),
                )
              : null,
          subtitle: _sidebarExpanded && isSearchResult
              ? Text(
                  tool.description,
                  style: TextStyle(
                    fontSize: 11,
                    color: colors.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          onTap: () => _navigateTo(tool.route),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required String route,
    required ColorScheme colors,
  }) {
    final isActive = widget.currentRoute == route;
    
    return Tooltip(
      message: _sidebarExpanded ? '' : label,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: isActive ? colors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          dense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: _sidebarExpanded ? 12 : 8,
            vertical: 2,
          ),
          leading: Icon(
            icon,
            size: 20,
            color: isActive ? colors.onPrimaryContainer : colors.onSurfaceVariant,
          ),
          title: _sidebarExpanded
              ? Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive ? colors.onPrimaryContainer : colors.onSurface,
                  ),
                )
              : null,
          onTap: () => _navigateTo(route),
        ),
      ),
    );
  }

  Widget _buildSidebarFooter(ColorScheme colors) {
    return Container(
      padding: EdgeInsets.all(_sidebarExpanded ? 12 : 8),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: _sidebarExpanded
          ? Row(
              children: [
                Consumer<ThemeProvider>(
                  builder: (_, provider, __) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                      ),
                      tooltip: 'Toggle theme',
                      onPressed: provider.toggleTheme,
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.menu_open_rounded, size: 20),
                  tooltip: 'Collapse sidebar',
                  onPressed: () => setState(() => _sidebarExpanded = false),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Consumer<ThemeProvider>(
                  builder: (_, provider, __) {
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    return IconButton(
                      icon: Icon(
                        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                        size: 20,
                      ),
                      tooltip: 'Toggle theme',
                      onPressed: provider.toggleTheme,
                      visualDensity: VisualDensity.compact,
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.menu_rounded, size: 20),
                  tooltip: 'Expand sidebar',
                  onPressed: () => setState(() => _sidebarExpanded = true),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
    );
  }

  Widget _buildTopBar(ColorScheme colors, bool isWide) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          bottom: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Row(
        children: [
          if (!isWide)
            IconButton(
              icon: const Icon(Icons.menu_rounded),
              onPressed: () => setState(() => _sidebarExpanded = !_sidebarExpanded),
            ),
          Expanded(
            child: Text(
              _getPageTitle(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, size: 20),
            tooltip: 'About',
            onPressed: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  String _getPageTitle() {
    if (widget.currentRoute == '/') return 'Dashboard';
    final tool = ToolsConfig.getToolByRoute(widget.currentRoute ?? '');
    return tool?.name ?? 'DevTools';
  }

  void _navigateTo(String route) {
    if (route == widget.currentRoute) return;
    Navigator.of(context).pushReplacementNamed(route);
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('DevTools Pro Suite'),
        content: const Text(
          'A comprehensive collection of developer utilities for '
          'regex building, encoding, formatting, and more.\n\n'
          'Version 2.0.0\n\n'
          'Keyboard Shortcuts:\n'
          'Ctrl+K - Command Palette\n'
          'Ctrl+/ - Toggle Sidebar\n'
          'Ctrl+Shift+T - Toggle Theme',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

// Intent classes for keyboard shortcuts
class _ShowCommandPaletteIntent extends Intent {
  const _ShowCommandPaletteIntent();
}

class _ToggleSidebarIntent extends Intent {
  const _ToggleSidebarIntent();
}

class _ToggleThemeIntent extends Intent {
  const _ToggleThemeIntent();
}
