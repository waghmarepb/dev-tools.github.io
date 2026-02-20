import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class DockerToolsScreen extends StatefulWidget {
  const DockerToolsScreen({super.key});

  @override
  State<DockerToolsScreen> createState() => _DockerToolsScreenState();
}

class _DockerToolsScreenState extends State<DockerToolsScreen> {
  String _activeTab = 'dockerfile';
  String _language = 'node';
  String _k8sResource = 'deployment';
  final _appNameCtrl = TextEditingController();
  final _portCtrl = TextEditingController(text: '3000');
  final _imageCtrl = TextEditingController();
  final _replicasCtrl = TextEditingController(text: '3');
  final _cpuCtrl = TextEditingController(text: '100m');
  final _memoryCtrl = TextEditingController(text: '128Mi');
  String _output = '';

  final Map<String, List<String>> _dockerTemplates = {
    'node': [
      'FROM node:18-alpine',
      'WORKDIR /app',
      'COPY package*.json ./',
      'RUN npm ci --only=production',
      'COPY . .',
      'EXPOSE 3000',
      'CMD ["node", "index.js"]',
    ],
    'python': [
      'FROM python:3.11-slim',
      'WORKDIR /app',
      'COPY requirements.txt .',
      'RUN pip install --no-cache-dir -r requirements.txt',
      'COPY . .',
      'EXPOSE 8000',
      'CMD ["python", "app.py"]',
    ],
    'go': [
      'FROM golang:1.21-alpine AS builder',
      'WORKDIR /app',
      'COPY go.* ./',
      'RUN go mod download',
      'COPY . .',
      'RUN go build -o main .',
      '',
      'FROM alpine:latest',
      'WORKDIR /root/',
      'COPY --from=builder /app/main .',
      'EXPOSE 8080',
      'CMD ["./main"]',
    ],
    'java': [
      'FROM maven:3.9-eclipse-temurin-17 AS builder',
      'WORKDIR /app',
      'COPY pom.xml .',
      'RUN mvn dependency:go-offline',
      'COPY src ./src',
      'RUN mvn package -DskipTests',
      '',
      'FROM eclipse-temurin:17-jre',
      'WORKDIR /app',
      'COPY --from=builder /app/target/*.jar app.jar',
      'EXPOSE 8080',
      'CMD ["java", "-jar", "app.jar"]',
    ],
    'rust': [
      'FROM rust:1.75 AS builder',
      'WORKDIR /app',
      'COPY Cargo.* ./',
      'COPY src ./src',
      'RUN cargo build --release',
      '',
      'FROM debian:bookworm-slim',
      'WORKDIR /app',
      'COPY --from=builder /app/target/release/app .',
      'EXPOSE 8080',
      'CMD ["./app"]',
    ],
  };

  @override
  void initState() {
    super.initState();
    _appNameCtrl.text = 'myapp';
    _imageCtrl.text = 'myapp:latest';
    _generateDockerfile();
  }

  void _generateDockerfile() {
    final template = _dockerTemplates[_language] ?? _dockerTemplates['node']!;
    setState(() {
      _output = template.join('\n');
    });
  }

  void _generateDockerCompose() {
    final appName = _appNameCtrl.text.isEmpty ? 'myapp' : _appNameCtrl.text;
    final port = _portCtrl.text.isEmpty ? '3000' : _portCtrl.text;

    setState(() {
      _output = '''version: '3.8'

services:
  $appName:
    build: .
    ports:
      - "$port:$port"
    environment:
      - NODE_ENV=production
      - PORT=$port
    restart: unless-stopped
    networks:
      - app-network

  postgres:
    image: postgres:16-alpine
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=$appName
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    networks:
      - app-network
    restart: unless-stopped

networks:
  app-network:
    driver: bridge

volumes:
  postgres-data:''';
    });
  }

  void _generateK8sYaml() {
    final appName = _appNameCtrl.text.isEmpty ? 'myapp' : _appNameCtrl.text;
    final image = _imageCtrl.text.isEmpty ? 'myapp:latest' : _imageCtrl.text;
    final port = _portCtrl.text.isEmpty ? '3000' : _portCtrl.text;
    final replicas = _replicasCtrl.text.isEmpty ? '3' : _replicasCtrl.text;
    final cpu = _cpuCtrl.text.isEmpty ? '100m' : _cpuCtrl.text;
    final memory = _memoryCtrl.text.isEmpty ? '128Mi' : _memoryCtrl.text;

    String yaml = '';

    switch (_k8sResource) {
      case 'deployment':
        yaml = '''apiVersion: apps/v1
kind: Deployment
metadata:
  name: $appName
  labels:
    app: $appName
spec:
  replicas: $replicas
  selector:
    matchLabels:
      app: $appName
  template:
    metadata:
      labels:
        app: $appName
    spec:
      containers:
      - name: $appName
        image: $image
        ports:
        - containerPort: $port
        resources:
          requests:
            cpu: $cpu
            memory: $memory
          limits:
            cpu: ${cpu.replaceAll('m', '')}0m
            memory: ${memory.replaceAll('Mi', '')}00Mi
        env:
        - name: PORT
          value: "$port"
        livenessProbe:
          httpGet:
            path: /health
            port: $port
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: $port
          initialDelaySeconds: 5
          periodSeconds: 5''';
        break;

      case 'service':
        yaml = '''apiVersion: v1
kind: Service
metadata:
  name: $appName-service
  labels:
    app: $appName
spec:
  type: LoadBalancer
  selector:
    app: $appName
  ports:
  - protocol: TCP
    port: 80
    targetPort: $port
    name: http''';
        break;

      case 'configmap':
        yaml = '''apiVersion: v1
kind: ConfigMap
metadata:
  name: $appName-config
data:
  app.env: |
    NODE_ENV=production
    PORT=$port
    LOG_LEVEL=info
  database.url: "postgresql://postgres:5432/$appName"
  redis.url: "redis://redis:6379"''';
        break;

      case 'secret':
        yaml = '''apiVersion: v1
kind: Secret
metadata:
  name: $appName-secret
type: Opaque
stringData:
  database-password: "changeme"
  api-key: "your-api-key-here"
  jwt-secret: "your-jwt-secret-here"''';
        break;

      case 'ingress':
        yaml = '''apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: $appName-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    cert-manager.io/cluster-issuer: letsencrypt-prod
spec:
  tls:
  - hosts:
    - $appName.example.com
    secretName: $appName-tls
  rules:
  - host: $appName.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: $appName-service
            port:
              number: 80''';
        break;
    }

    setState(() {
      _output = yaml;
    });
  }

  @override
  void dispose() {
    _appNameCtrl.dispose();
    _portCtrl.dispose();
    _imageCtrl.dispose();
    _replicasCtrl.dispose();
    _cpuCtrl.dispose();
    _memoryCtrl.dispose();
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
              child: _buildContent(colors),
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
          value: 'dockerfile',
          label: Text('Dockerfile'),
          icon: Icon(Icons.description, size: 18),
        ),
        ButtonSegment(
          value: 'compose',
          label: Text('Docker Compose'),
          icon: Icon(Icons.layers, size: 18),
        ),
        ButtonSegment(
          value: 'k8s',
          label: Text('Kubernetes'),
          icon: Icon(Icons.cloud_circle, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) {
        setState(() => _activeTab = v.first);
        if (_activeTab == 'dockerfile') {
          _generateDockerfile();
        } else if (_activeTab == 'compose') {
          _generateDockerCompose();
        } else {
          _generateK8sYaml();
        }
      },
    );
  }

  Widget _buildContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'dockerfile':
        return _buildDockerfileTab(colors);
      case 'compose':
        return _buildComposeTab(colors);
      case 'k8s':
        return _buildK8sTab(colors);
      default:
        return const SizedBox();
    }
  }

  Widget _buildDockerfileTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'LANGUAGE TEMPLATE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Language:',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildLanguageChip('node', 'Node.js', Icons.javascript),
                          _buildLanguageChip('python', 'Python', Icons.code),
                          _buildLanguageChip('go', 'Go', Icons.speed),
                          _buildLanguageChip('java', 'Java', Icons.coffee),
                          _buildLanguageChip('rust', 'Rust', Icons.security),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _generateDockerfile,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Generate Dockerfile'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Multi-stage builds are used for compiled languages (Go, Java, Rust) to reduce image size.',
                          style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer),
                        ),
                      ),
                    ],
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
                title: 'DOCKERFILE OUTPUT',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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

  Widget _buildComposeTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'CONFIGURATION'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _appNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'App Name',
                          hintText: 'myapp',
                          isDense: true,
                        ),
                        onChanged: (_) => _generateDockerCompose(),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _portCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Port',
                          hintText: '3000',
                          isDense: true,
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _generateDockerCompose(),
                      ),
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _generateDockerCompose,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Generate docker-compose.yml'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: colors.primaryContainer.withValues(alpha: 0.3),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Includes app, PostgreSQL, and Redis services with networking and volumes.',
                          style: TextStyle(fontSize: 11, color: colors.onPrimaryContainer),
                        ),
                      ),
                    ],
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
                title: 'DOCKER COMPOSE OUTPUT',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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

  Widget _buildK8sTab(ColorScheme colors) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'KUBERNETES RESOURCE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        initialValue: _k8sResource,
                        decoration: const InputDecoration(
                          labelText: 'Resource Type',
                          isDense: true,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'deployment', child: Text('Deployment')),
                          DropdownMenuItem(value: 'service', child: Text('Service')),
                          DropdownMenuItem(value: 'configmap', child: Text('ConfigMap')),
                          DropdownMenuItem(value: 'secret', child: Text('Secret')),
                          DropdownMenuItem(value: 'ingress', child: Text('Ingress')),
                        ],
                        onChanged: (v) {
                          setState(() => _k8sResource = v!);
                          _generateK8sYaml();
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _appNameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'App Name',
                          isDense: true,
                        ),
                        onChanged: (_) => _generateK8sYaml(),
                      ),
                      if (_k8sResource == 'deployment') ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _imageCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Image',
                            isDense: true,
                          ),
                          onChanged: (_) => _generateK8sYaml(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replicasCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Replicas',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _generateK8sYaml(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _portCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Port',
                                  isDense: true,
                                ),
                                keyboardType: TextInputType.number,
                                onChanged: (_) => _generateK8sYaml(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _cpuCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'CPU Request',
                                  isDense: true,
                                ),
                                onChanged: (_) => _generateK8sYaml(),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _memoryCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Memory Request',
                                  isDense: true,
                                ),
                                onChanged: (_) => _generateK8sYaml(),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      FilledButton.icon(
                        onPressed: _generateK8sYaml,
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text('Generate YAML'),
                      ),
                    ],
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
                title: 'KUBERNETES YAML OUTPUT',
                trailing: CopyButton(text: _output),
              ),
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(
                      _output,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
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

  Widget _buildLanguageChip(String value, String label, IconData icon) {
    final isSelected = _language == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        setState(() => _language = value);
        _generateDockerfile();
      },
    );
  }
}
