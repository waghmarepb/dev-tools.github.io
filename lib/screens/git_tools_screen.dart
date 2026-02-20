import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class GitToolsScreen extends StatefulWidget {
  const GitToolsScreen({super.key});

  @override
  State<GitToolsScreen> createState() => _GitToolsScreenState();
}

class _GitToolsScreenState extends State<GitToolsScreen> {
  String _activeTab = 'gitignore';
  String _selectedLanguage = 'Node';
  String _gitignoreOutput = '';
  
  final _commitTypeCtrl = TextEditingController(text: 'feat');
  final _commitScopeCtrl = TextEditingController();
  final _commitDescCtrl = TextEditingController();
  final _commitBodyCtrl = TextEditingController();
  String _commitOutput = '';
  
  String _branchType = 'feature';
  final _branchNameCtrl = TextEditingController();
  String _branchOutput = '';
  
  final _currentVersionCtrl = TextEditingController(text: '1.0.0');
  String _versionBump = 'patch';
  String _versionOutput = '';

  final Map<String, List<String>> _gitignoreTemplates = {
    'Node': [
      '# Dependencies',
      'node_modules/',
      'package-lock.json',
      'yarn.lock',
      '',
      '# Environment',
      '.env',
      '.env.local',
      '.env.*.local',
      '',
      '# Build',
      'dist/',
      'build/',
      '.next/',
      'out/',
      '',
      '# Logs',
      'logs/',
      '*.log',
      'npm-debug.log*',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '*.swp',
      '*.swo',
      '*~',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'Python': [
      '# Byte-compiled',
      '__pycache__/',
      '*.py[cod]',
      '*\$py.class',
      '*.so',
      '',
      '# Virtual Environment',
      'venv/',
      'env/',
      'ENV/',
      '.venv',
      '',
      '# Distribution',
      'dist/',
      'build/',
      '*.egg-info/',
      '',
      '# Testing',
      '.pytest_cache/',
      '.coverage',
      'htmlcov/',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '*.swp',
      '',
      '# Environment',
      '.env',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'Java': [
      '# Compiled',
      '*.class',
      '*.jar',
      '*.war',
      '*.ear',
      '',
      '# Build',
      'target/',
      'build/',
      'out/',
      '',
      '# IDE',
      '.idea/',
      '*.iml',
      '.vscode/',
      '.eclipse/',
      '',
      '# Maven',
      '.mvn/',
      'mvnw',
      'mvnw.cmd',
      '',
      '# Gradle',
      '.gradle/',
      'gradle/',
      'gradlew',
      'gradlew.bat',
      '',
      '# Logs',
      '*.log',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'Flutter': [
      '# Build',
      'build/',
      '',
      '# Flutter/Dart',
      '.dart_tool/',
      '.flutter-plugins',
      '.flutter-plugins-dependencies',
      '.packages',
      '.pub-cache/',
      '.pub/',
      '',
      '# Android',
      '**/android/**/gradle-wrapper.jar',
      '**/android/.gradle',
      '**/android/captures/',
      '**/android/local.properties',
      '**/android/**/GeneratedPluginRegistrant.java',
      '',
      '# iOS',
      '**/ios/**/*.mode1v3',
      '**/ios/**/*.mode2v3',
      '**/ios/**/*.moved-aside',
      '**/ios/**/*.pbxuser',
      '**/ios/**/*.perspectivev3',
      '**/ios/Pods/',
      '**/ios/.symlinks/',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '*.swp',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'React': [
      '# Dependencies',
      'node_modules/',
      '',
      '# Build',
      'build/',
      'dist/',
      '.next/',
      'out/',
      '',
      '# Environment',
      '.env',
      '.env.local',
      '.env.*.local',
      '',
      '# Testing',
      'coverage/',
      '',
      '# Production',
      '*.tgz',
      '',
      '# Logs',
      '*.log',
      'npm-debug.log*',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'Go': [
      '# Binaries',
      '*.exe',
      '*.exe~',
      '*.dll',
      '*.so',
      '*.dylib',
      '',
      '# Test binary',
      '*.test',
      '',
      '# Output',
      '*.out',
      '',
      '# Dependency directories',
      'vendor/',
      '',
      '# Go workspace file',
      'go.work',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'Rust': [
      '# Build',
      'target/',
      'Cargo.lock',
      '',
      '# Backup files',
      '**/*.rs.bk',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '*.swp',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
    'C++': [
      '# Compiled',
      '*.o',
      '*.obj',
      '*.exe',
      '*.out',
      '*.app',
      '',
      '# Libraries',
      '*.lib',
      '*.a',
      '*.so',
      '*.dll',
      '*.dylib',
      '',
      '# Build',
      'build/',
      'cmake-build-*/',
      '',
      '# IDE',
      '.vscode/',
      '.idea/',
      '*.swp',
      '',
      '# OS',
      '.DS_Store',
      'Thumbs.db',
    ],
  };

  @override
  void initState() {
    super.initState();
    _generateGitignore();
  }

  void _generateGitignore() {
    setState(() {
      _gitignoreOutput = _gitignoreTemplates[_selectedLanguage]?.join('\n') ?? '';
    });
  }

  void _generateCommit() {
    final type = _commitTypeCtrl.text.trim();
    final scope = _commitScopeCtrl.text.trim();
    final desc = _commitDescCtrl.text.trim();
    final body = _commitBodyCtrl.text.trim();

    if (type.isEmpty || desc.isEmpty) {
      setState(() => _commitOutput = '');
      return;
    }

    final buffer = StringBuffer();
    buffer.write(type);
    if (scope.isNotEmpty) buffer.write('($scope)');
    buffer.write(': $desc');
    
    if (body.isNotEmpty) {
      buffer.write('\n\n$body');
    }

    setState(() => _commitOutput = buffer.toString());
  }

  void _generateBranch() {
    final name = _branchNameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _branchOutput = '');
      return;
    }

    final sanitized = name
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\-_]'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    setState(() => _branchOutput = '$_branchType/$sanitized');
  }

  void _generateVersion() {
    final current = _currentVersionCtrl.text.trim();
    final parts = current.split('.');
    
    if (parts.length != 3) {
      setState(() => _versionOutput = 'Invalid version format');
      return;
    }

    try {
      int major = int.parse(parts[0]);
      int minor = int.parse(parts[1]);
      int patch = int.parse(parts[2]);

      switch (_versionBump) {
        case 'major':
          major++;
          minor = 0;
          patch = 0;
          break;
        case 'minor':
          minor++;
          patch = 0;
          break;
        case 'patch':
          patch++;
          break;
      }

      setState(() => _versionOutput = '$major.$minor.$patch');
    } catch (e) {
      setState(() => _versionOutput = 'Invalid version');
    }
  }

  @override
  void dispose() {
    _commitTypeCtrl.dispose();
    _commitScopeCtrl.dispose();
    _commitDescCtrl.dispose();
    _commitBodyCtrl.dispose();
    _branchNameCtrl.dispose();
    _currentVersionCtrl.dispose();
    super.dispose();
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
              child: _activeTab == 'gitignore'
                  ? _buildGitignoreTab(colors)
                  : _activeTab == 'commit'
                      ? _buildCommitTab(colors)
                      : _activeTab == 'branch'
                          ? _buildBranchTab(colors)
                          : _buildVersionTab(colors),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabs(ColorScheme colors) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SegmentedButton<String>(
        segments: const [
          ButtonSegment(
            value: 'gitignore',
            label: Text('.gitignore'),
            icon: Icon(Icons.block, size: 18),
          ),
          ButtonSegment(
            value: 'commit',
            label: Text('Commit Message'),
            icon: Icon(Icons.commit, size: 18),
          ),
          ButtonSegment(
            value: 'branch',
            label: Text('Branch Name'),
            icon: Icon(Icons.account_tree, size: 18),
          ),
          ButtonSegment(
            value: 'version',
            label: Text('Version Bump'),
            icon: Icon(Icons.tag, size: 18),
          ),
        ],
        selected: {_activeTab},
        onSelectionChanged: (v) => setState(() => _activeTab = v.first),
      ),
    );
  }

  Widget _buildGitignoreTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'GITIGNORE GENERATOR'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Language/Framework:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _gitignoreTemplates.keys.map((lang) {
                    return ChoiceChip(
                      label: Text(lang),
                      selected: _selectedLanguage == lang,
                      onSelected: (v) {
                        if (v) {
                          setState(() => _selectedLanguage = lang);
                          _generateGitignore();
                        }
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(
          title: 'OUTPUT',
          trailing: CopyButton(text: _gitignoreOutput),
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.5)),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                _gitignoreOutput,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommitTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'CONVENTIONAL COMMIT GENERATOR'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ['feat', 'fix', 'docs', 'style', 'refactor', 'test', 'chore', 'perf'].map((type) {
                    return ChoiceChip(
                      label: Text(type),
                      selected: _commitTypeCtrl.text == type,
                      onSelected: (v) {
                        if (v) {
                          _commitTypeCtrl.text = type;
                          _generateCommit();
                        }
                      },
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _commitScopeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Scope (optional)',
                    hintText: 'e.g., api, auth, ui',
                    isDense: true,
                  ),
                  onChanged: (_) => _generateCommit(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commitDescCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'Brief description of changes',
                    isDense: true,
                  ),
                  onChanged: (_) => _generateCommit(),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commitBodyCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Body (optional)',
                    hintText: 'Detailed explanation',
                    isDense: true,
                  ),
                  onChanged: (_) => _generateCommit(),
                ),
              ],
            ),
          ),
        ),
        if (_commitOutput.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeader(
            title: 'COMMIT MESSAGE',
            trailing: CopyButton(text: _commitOutput),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _commitOutput,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                height: 1.5,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBranchTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'BRANCH NAME GENERATOR'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Type:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'feature', label: Text('feature')),
                    ButtonSegment(value: 'bugfix', label: Text('bugfix')),
                    ButtonSegment(value: 'hotfix', label: Text('hotfix')),
                    ButtonSegment(value: 'release', label: Text('release')),
                  ],
                  selected: {_branchType},
                  onSelectionChanged: (v) {
                    setState(() => _branchType = v.first);
                    _generateBranch();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _branchNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Branch Description',
                    hintText: 'e.g., add user authentication',
                    isDense: true,
                  ),
                  onChanged: (_) => _generateBranch(),
                ),
              ],
            ),
          ),
        ),
        if (_branchOutput.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeader(
            title: 'BRANCH NAME',
            trailing: CopyButton(text: _branchOutput),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              _branchOutput,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colors.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVersionTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'SEMANTIC VERSION BUMPER'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _currentVersionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Current Version',
                    hintText: '1.0.0',
                    isDense: true,
                  ),
                  onChanged: (_) => _generateVersion(),
                ),
                const SizedBox(height: 16),
                Text('Bump Type:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'major', label: Text('Major (X.0.0)')),
                    ButtonSegment(value: 'minor', label: Text('Minor (0.X.0)')),
                    ButtonSegment(value: 'patch', label: Text('Patch (0.0.X)')),
                  ],
                  selected: {_versionBump},
                  onSelectionChanged: (v) {
                    setState(() => _versionBump = v.first);
                    _generateVersion();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colors.tertiaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Semantic Versioning:', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Text('• Major: Breaking changes', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                      Text('• Minor: New features (backward compatible)', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                      Text('• Patch: Bug fixes', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_versionOutput.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeader(
            title: 'NEW VERSION',
            trailing: CopyButton(text: _versionOutput),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colors.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentVersionCtrl.text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 20,
                    color: colors.onPrimaryContainer.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.arrow_forward, color: colors.onPrimaryContainer),
                const SizedBox(width: 16),
                Text(
                  _versionOutput,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: colors.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
