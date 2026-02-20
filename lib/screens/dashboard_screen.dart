import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/tools_config.dart';
import '../providers/tools_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final toolsProvider = context.watch<ToolsProvider>();

    return ListView(
      padding: const EdgeInsets.all(32),
      children: [
        _buildWelcomeHeader(theme, colors),
        const SizedBox(height: 32),
        _buildQuickAccessCards(theme, colors, context, toolsProvider),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildUsageStatsSection(theme, colors, toolsProvider),
                  const SizedBox(height: 24),
                  _buildRecentActivitySection(theme, colors, toolsProvider, context),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                children: [
                  _buildToolCategoriesCard(theme, colors, context),
                  const SizedBox(height: 24),
                  _buildTipsCard(theme, colors),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWelcomeHeader(ThemeData theme, ColorScheme colors) {
    final hour = DateTime.now().hour;
    String greeting = 'Good morning';
    if (hour >= 12 && hour < 17) greeting = 'Good afternoon';
    if (hour >= 17) greeting = 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '$greeting, Developer!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '👋',
                    style: TextStyle(fontSize: 28),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'What tools do you need today?',
                style: TextStyle(
                  fontSize: 16,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.apps_rounded, size: 18, color: colors.onPrimaryContainer),
              const SizedBox(width: 8),
              Text(
                '${ToolsConfig.allTools.length} Tools Available',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAccessCards(
    ThemeData theme,
    ColorScheme colors,
    BuildContext context,
    ToolsProvider toolsProvider,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildQuickCard(
            'Stay organized',
            'Access your favorite tools instantly',
            Icons.star_rounded,
            Colors.amber,
            colors,
            () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickCard(
            'Recent tools',
            'Pick up where you left off',
            Icons.history_rounded,
            Colors.blue,
            colors,
            () {},
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildQuickCard(
            'Quick search',
            'Press Ctrl+K to find any tool',
            Icons.search_rounded,
            Colors.purple,
            colors,
            () {},
          ),
        ),
      ],
    );
  }

  Widget _buildQuickCard(
    String title,
    String subtitle,
    IconData icon,
    Color accentColor,
    ColorScheme colors,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: accentColor),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsageStatsSection(
    ThemeData theme,
    ColorScheme colors,
    ToolsProvider toolsProvider,
  ) {
    final mostUsed = toolsProvider.getMostUsedTools(limit: 5);
    final totalUsage = toolsProvider.toolUsage.values.fold<int>(0, (sum, count) => sum + count);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up_rounded, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Your Usage Stats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$totalUsage total uses',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (mostUsed.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.bar_chart_rounded,
                        size: 48,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Start using tools to see statistics',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...mostUsed.map((toolId) {
                final tool = ToolsConfig.getToolById(toolId);
                if (tool == null) return const SizedBox();
                
                final usage = toolsProvider.toolUsage[toolId] ?? 0;
                final maxUsage = toolsProvider.toolUsage.values.fold<int>(0, (max, val) => val > max ? val : max);
                final percentage = maxUsage > 0 ? (usage / maxUsage * 100).round() : 0;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(tool.icon, size: 16, color: tool.iconColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tool.name,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            '$usage uses',
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: colors.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation(tool.iconColor ?? colors.primary),
                        ),
                      ),
                    ],
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivitySection(
    ThemeData theme,
    ColorScheme colors,
    ToolsProvider toolsProvider,
    BuildContext context,
  ) {
    final recentTools = toolsProvider.recentTools.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history_rounded, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Recent Activity',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: recentTools.isEmpty ? null : () {},
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (recentTools.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        size: 48,
                        color: colors.onSurfaceVariant.withValues(alpha: 0.3),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No recent activity yet',
                        style: TextStyle(
                          fontSize: 13,
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Start using tools to see your history',
                        style: TextStyle(
                          fontSize: 11,
                          color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...recentTools.map((toolId) {
                final tool = ToolsConfig.getToolById(toolId);
                if (tool == null) return const SizedBox();

                return InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed(tool.route),
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: (tool.iconColor ?? colors.primary).withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            tool.icon,
                            size: 20,
                            color: tool.iconColor ?? colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tool.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                tool.description,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: colors.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: colors.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCategoriesCard(ThemeData theme, ColorScheme colors, BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.category_rounded, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Tool Categories',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...ToolsConfig.categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: colors.primaryContainer.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            category.icon,
                            size: 18,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: colors.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${category.tools.length}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: colors.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTipsCard(ThemeData theme, ColorScheme colors) {
    return Card(
      color: colors.primaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_rounded, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text(
                  'Pro Tips',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              '⌨️',
              'Press Ctrl+K',
              'Quick search any tool',
              colors,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '🎨',
              'Press Ctrl+Shift+T',
              'Toggle dark/light theme',
              colors,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '⭐',
              'Star your favorites',
              'Quick access to frequent tools',
              colors,
            ),
            const SizedBox(height: 12),
            _buildTipItem(
              '📋',
              'Copy buttons everywhere',
              'One-click copy on all outputs',
              colors,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(String emoji, String title, String desc, ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                desc,
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
