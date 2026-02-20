import 'package:flutter/material.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class NetworkToolsScreen extends StatefulWidget {
  const NetworkToolsScreen({super.key});

  @override
  State<NetworkToolsScreen> createState() => _NetworkToolsScreenState();
}

class _NetworkToolsScreenState extends State<NetworkToolsScreen> {
  String _activeTab = 'subnet';
  final _ipCtrl = TextEditingController(text: '192.168.1.100');
  final _cidrCtrl = TextEditingController(text: '24');
  Map<String, String>? _subnetInfo;
  
  final _macCtrl = TextEditingController();
  String _macOutput = '';

  void _calculateSubnet() {
    try {
      final ip = _ipCtrl.text.trim();
      final cidr = int.parse(_cidrCtrl.text.trim());
      
      if (cidr < 0 || cidr > 32) {
        setState(() => _subnetInfo = {'Error': 'CIDR must be 0-32'});
        return;
      }

      final ipParts = ip.split('.').map(int.parse).toList();
      if (ipParts.length != 4 || ipParts.any((p) => p < 0 || p > 255)) {
        setState(() => _subnetInfo = {'Error': 'Invalid IP address'});
        return;
      }

      final ipInt = (ipParts[0] << 24) | (ipParts[1] << 16) | (ipParts[2] << 8) | ipParts[3];
      final maskInt = (0xFFFFFFFF << (32 - cidr)) & 0xFFFFFFFF;
      final networkInt = ipInt & maskInt;
      final broadcastInt = networkInt | (~maskInt & 0xFFFFFFFF);
      final firstHostInt = networkInt + 1;
      final lastHostInt = broadcastInt - 1;
      final totalHosts = (1 << (32 - cidr)) - 2;

      setState(() {
        _subnetInfo = {
          'IP Address': ip,
          'CIDR Notation': '$ip/$cidr',
          'Subnet Mask': _intToIp(maskInt),
          'Wildcard Mask': _intToIp(~maskInt & 0xFFFFFFFF),
          'Network Address': _intToIp(networkInt),
          'Broadcast Address': _intToIp(broadcastInt),
          'First Host': _intToIp(firstHostInt),
          'Last Host': _intToIp(lastHostInt),
          'Total Hosts': totalHosts > 0 ? totalHosts.toString() : '0',
          'IP Class': _getIpClass(ipParts[0]),
          'Binary IP': ipParts.map((p) => p.toRadixString(2).padLeft(8, '0')).join('.'),
        };
      });
    } catch (e) {
      setState(() => _subnetInfo = {'Error': e.toString()});
    }
  }

  String _intToIp(int value) {
    return '${(value >> 24) & 0xFF}.${(value >> 16) & 0xFF}.${(value >> 8) & 0xFF}.${value & 0xFF}';
  }

  String _getIpClass(int firstOctet) {
    if (firstOctet < 128) return 'A';
    if (firstOctet < 192) return 'B';
    if (firstOctet < 224) return 'C';
    if (firstOctet < 240) return 'D (Multicast)';
    return 'E (Reserved)';
  }

  void _generateMac() {
    final random = List.generate(6, (_) => (DateTime.now().microsecondsSinceEpoch % 256).toRadixString(16).padLeft(2, '0'));
    setState(() => _macOutput = random.join(':').toUpperCase());
  }

  @override
  void initState() {
    super.initState();
    _calculateSubnet();
    _generateMac();
  }

  @override
  void dispose() {
    _ipCtrl.dispose();
    _cidrCtrl.dispose();
    _macCtrl.dispose();
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
              child: _activeTab == 'subnet'
                  ? _buildSubnetTab(colors)
                  : _activeTab == 'mac'
                      ? _buildMacTab(colors)
                      : _buildPortsTab(colors),
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
          value: 'subnet',
          label: Text('Subnet Calculator'),
          icon: Icon(Icons.calculate, size: 18),
        ),
        ButtonSegment(
          value: 'mac',
          label: Text('MAC Generator'),
          icon: Icon(Icons.settings_ethernet, size: 18),
        ),
        ButtonSegment(
          value: 'ports',
          label: Text('Common Ports'),
          icon: Icon(Icons.router, size: 18),
        ),
      ],
      selected: {_activeTab},
      onSelectionChanged: (v) => setState(() => _activeTab = v.first),
    );
  }

  Widget _buildSubnetTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'IP SUBNET CALCULATOR'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _ipCtrl,
                    decoration: const InputDecoration(
                      labelText: 'IP Address',
                      hintText: '192.168.1.1',
                      isDense: true,
                    ),
                    onChanged: (_) => _calculateSubnet(),
                  ),
                ),
                const SizedBox(width: 12),
                Text('/', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _cidrCtrl,
                    decoration: const InputDecoration(
                      labelText: 'CIDR',
                      hintText: '24',
                      isDense: true,
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (_) => _calculateSubnet(),
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _calculateSubnet,
                  icon: const Icon(Icons.calculate, size: 18),
                  label: const Text('Calculate'),
                ),
              ],
            ),
          ),
        ),
        if (_subnetInfo != null) ...[
          const SizedBox(height: 16),
          const SectionHeader(title: 'RESULTS'),
          Expanded(
            child: ListView(
              children: _subnetInfo!.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SelectableText(
                          entry.value,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CopyButton(text: entry.value, iconSize: 14),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMacTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'MAC ADDRESS GENERATOR'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_macOutput.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          _macOutput,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colors.onPrimaryContainer,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(width: 16),
                        CopyButton(text: _macOutput),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _generateMac,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Generate New MAC'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPortsTab(ColorScheme colors) {
    final commonPorts = {
      '20/21': 'FTP',
      '22': 'SSH',
      '23': 'Telnet',
      '25': 'SMTP',
      '53': 'DNS',
      '80': 'HTTP',
      '110': 'POP3',
      '143': 'IMAP',
      '443': 'HTTPS',
      '465': 'SMTPS',
      '587': 'SMTP (TLS)',
      '993': 'IMAPS',
      '995': 'POP3S',
      '3306': 'MySQL',
      '5432': 'PostgreSQL',
      '6379': 'Redis',
      '27017': 'MongoDB',
      '3000': 'Node.js (dev)',
      '3001': 'React (dev)',
      '4200': 'Angular (dev)',
      '5000': 'Flask (dev)',
      '5173': 'Vite (dev)',
      '8000': 'Django (dev)',
      '8080': 'HTTP Alt',
      '8443': 'HTTPS Alt',
      '9000': 'PHP-FPM',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'COMMON PORTS REFERENCE'),
        Expanded(
          child: ListView(
            children: commonPorts.entries.map((entry) {
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  dense: true,
                  leading: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      entry.key,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: colors.onPrimaryContainer,
                      ),
                    ),
                  ),
                  title: Text(
                    entry.value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  trailing: CopyButton(text: entry.key, iconSize: 14),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
