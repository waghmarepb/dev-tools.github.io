import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class EnvManagerScreen extends StatefulWidget {
  const EnvManagerScreen({super.key});

  @override
  State<EnvManagerScreen> createState() => _EnvManagerScreenState();
}

class _EnvManagerScreenState extends State<EnvManagerScreen> {
  String _activeTab = 'editor';
  final List<_EnvVar> _variables = [];
  String _format = 'dotenv';
  bool _includeComments = true;
  bool _sortAlphabetically = false;
  String _output = '';

  final List<_EnvTemplate> _templates = [
    _EnvTemplate(
      'Node.js App',
      [
        _EnvVar('NODE_ENV', 'development', 'Environment mode'),
        _EnvVar('PORT', '3000', 'Server port'),
        _EnvVar('DATABASE_URL', 'postgresql://localhost:5432/mydb', 'Database connection'),
        _EnvVar('JWT_SECRET', 'your-secret-key', 'JWT signing key'),
        _EnvVar('API_KEY', '', 'External API key'),
      ],
    ),
    _EnvTemplate(
      'React App',
      [
        _EnvVar('REACT_APP_API_URL', 'http://localhost:3000/api', 'Backend API URL'),
        _EnvVar('REACT_APP_ENV', 'development', 'Environment'),
        _EnvVar('REACT_APP_GOOGLE_ANALYTICS', '', 'GA tracking ID'),
        _EnvVar('REACT_APP_SENTRY_DSN', '', 'Sentry error tracking'),
      ],
    ),
    _EnvTemplate(
      'Python/Django',
      [
        _EnvVar('DEBUG', 'True', 'Debug mode'),
        _EnvVar('SECRET_KEY', 'django-insecure-key', 'Django secret key'),
        _EnvVar('DATABASE_URL', 'postgres://localhost/mydb', 'Database URL'),
        _EnvVar('ALLOWED_HOSTS', 'localhost,127.0.0.1', 'Allowed hosts'),
        _EnvVar('REDIS_URL', 'redis://localhost:6379', 'Redis cache URL'),
      ],
    ),
    _EnvTemplate(
      'Docker Compose',
      [
        _EnvVar('COMPOSE_PROJECT_NAME', 'myproject', 'Project name'),
        _EnvVar('POSTGRES_USER', 'postgres', 'Database user'),
        _EnvVar('POSTGRES_PASSWORD', 'password', 'Database password'),
        _EnvVar('POSTGRES_DB', 'mydb', 'Database name'),
        _EnvVar('REDIS_PORT', '6379', 'Redis port'),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _addVariable();
  }

  void _addVariable() {
    setState(() {
      _variables.add(_EnvVar('', '', ''));
    });
  }

  void _removeVariable(int index) {
    setState(() {
      _variables.removeAt(index);
    });
  }

  void _loadTemplate(_EnvTemplate template) {
    setState(() {
      _variables.clear();
      _variables.addAll(template.vars.map((v) => _EnvVar(v.key, v.value, v.comment)));
      _generateOutput();
    });
  }

  void _generateOutput() {
    final vars = List<_EnvVar>.from(_variables.where((v) => v.key.isNotEmpty));
    
    if (_sortAlphabetically) {
      vars.sort((a, b) => a.key.compareTo(b.key));
    }

    final buffer = StringBuffer();

    switch (_format) {
      case 'dotenv':
        for (final v in vars) {
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('# ${v.comment}');
          }
          buffer.writeln('${v.key}=${v.value}');
          if (_includeComments) buffer.writeln();
        }
        break;

      case 'json':
        buffer.writeln('{');
        for (var i = 0; i < vars.length; i++) {
          final v = vars[i];
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('  // ${v.comment}');
          }
          buffer.write('  "${v.key}": "${v.value}"');
          if (i < vars.length - 1) buffer.write(',');
          buffer.writeln();
        }
        buffer.writeln('}');
        break;

      case 'yaml':
        for (final v in vars) {
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('# ${v.comment}');
          }
          buffer.writeln('${v.key}: ${v.value}');
        }
        break;

      case 'docker':
        for (final v in vars) {
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('# ${v.comment}');
          }
          buffer.writeln('ENV ${v.key}=${v.value}');
        }
        break;

      case 'shell':
        for (final v in vars) {
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('# ${v.comment}');
          }
          buffer.writeln('export ${v.key}="${v.value}"');
        }
        break;

      case 'powershell':
        for (final v in vars) {
          if (_includeComments && v.comment.isNotEmpty) {
            buffer.writeln('# ${v.comment}');
          }
          buffer.writeln('\$env:${v.key} = "${v.value}"');
        }
        break;
    }

    setState(() {
      _output = buffer.toString().trim();
    });
  }


  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildTabs(colors),
            const SizedBox(height: 24),
            Expanded(
              child: _activeTab == 'editor'
                  ? _buildEditorTab(colors)
                  : _buildTemplatesTab(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ColorScheme colors) {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(
          value: 'editor',
          label: Text('Editor'),
          icon: Icon(Icons.edit, size: 18),
        ),
        ButtonSegment(
          value: 'templates',
          label: Text('Templates'),
          icon: Icon(Icons.library_books, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildEditorTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionHeader(
                title: 'ENVIRONMENT VARIABLES (${_variables.where((v) => v.key.isNotEmpty).length})',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: _addVariable,
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Variable'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _generateOutput,
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text('Generate'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Card(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _variables.length,
                    itemBuilder: (_, i) => _buildVariableRow(i, colors),
                  ),
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
              SectionHeader(
                title: 'OUTPUT',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: _format,
                      isDense: true,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: 'dotenv', child: Text('.env')),
                        DropdownMenuItem(value: 'json', child: Text('JSON')),
                        DropdownMenuItem(value: 'yaml', child: Text('YAML')),
                        DropdownMenuItem(value: 'docker', child: Text('Dockerfile')),
                        DropdownMenuItem(value: 'shell', child: Text('Shell')),
                        DropdownMenuItem(value: 'powershell', child: Text('PowerShell')),
                      ],
                      onChanged: (v) {
                        setState(() => _format = v!);
                        _generateOutput();
                      },
                    ),
                    const SizedBox(width: 8),
                    CopyButton(text: _output),
                  ],
                ),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _includeComments,
                            onChanged: (v) {
                              setState(() => _includeComments = v!);
                              _generateOutput();
                            },
                          ),
                          const Text('Include comments', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 16),
                          Checkbox(
                            value: _sortAlphabetically,
                            onChanged: (v) {
                              setState(() => _sortAlphabetically = v!);
                              _generateOutput();
                            },
                          ),
                          const Text('Sort alphabetically', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output.isEmpty ? 'Click "Generate" to create output' : _output,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _output.isEmpty ? colors.onSurfaceVariant : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVariableRow(int index, ColorScheme colors) {
    final v = _variables[index];
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Key',
                      hintText: 'VARIABLE_NAME',
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    controller: TextEditingController(text: v.key)
                      ..selection = TextSelection.collapsed(offset: v.key.length),
                    onChanged: (val) => v.key = val.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9_]'), '_'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: TextField(
                    decoration: const InputDecoration(
                      labelText: 'Value',
                      hintText: 'value',
                      isDense: true,
                    ),
                    style: const TextStyle(fontSize: 12),
                    controller: TextEditingController(text: v.value)
                      ..selection = TextSelection.collapsed(offset: v.value.length),
                    onChanged: (val) => v.value = val,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  onPressed: () => _removeVariable(index),
                  tooltip: 'Remove',
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Comment (optional)',
                hintText: 'Description of this variable',
                isDense: true,
              ),
              style: const TextStyle(fontSize: 11),
              controller: TextEditingController(text: v.comment)
                ..selection = TextSelection.collapsed(offset: v.comment.length),
              onChanged: (val) => v.comment = val,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplatesTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'ENVIRONMENT TEMPLATES'),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 300,
              childAspectRatio: 1.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _templates.length,
            itemBuilder: (_, i) {
              final template = _templates[i];
              return Card(
                child: InkWell(
                  onTap: () {
                    _loadTemplate(template);
                    setState(() => _activeTab = 'editor');
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.description, size: 20, color: colors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                template.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${template.vars.length} variables',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: template.vars.take(3).map((v) {
                            return Chip(
                              label: Text(
                                v.key,
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontFamily: 'monospace',
                                ),
                              ),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnvVar {
  String key;
  String value;
  String comment;

  _EnvVar(this.key, this.value, this.comment);
}

class _EnvTemplate {
  final String name;
  final List<_EnvVar> vars;

  _EnvTemplate(this.name, this.vars);
}
