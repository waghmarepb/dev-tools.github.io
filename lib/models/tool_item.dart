import 'package:flutter/material.dart';

class ToolCategory {
  final String id;
  final String name;
  final IconData icon;
  final List<ToolItem> tools;

  const ToolCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.tools,
  });
}

class ToolItem {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color? iconColor;
  final String route;
  final List<String> tags;

  const ToolItem({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.iconColor,
    required this.route,
    this.tags = const [],
  });
}
