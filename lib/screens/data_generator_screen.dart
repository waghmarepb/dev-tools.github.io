import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:faker/faker.dart';
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class DataGeneratorScreen extends StatefulWidget {
  const DataGeneratorScreen({super.key});

  @override
  State<DataGeneratorScreen> createState() => _DataGeneratorScreenState();
}

class _DataGeneratorScreenState extends State<DataGeneratorScreen> {
  final _faker = Faker();
  String _dataType = 'person';
  int _count = 10;
  String _output = '';
  String _format = 'json';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    final data = <Map<String, dynamic>>[];

    for (int i = 0; i < _count; i++) {
      switch (_dataType) {
        case 'person':
          data.add(_generatePerson());
          break;
        case 'address':
          data.add(_generateAddress());
          break;
        case 'company':
          data.add(_generateCompany());
          break;
        case 'internet':
          data.add(_generateInternet());
          break;
        case 'commerce':
          data.add(_generateCommerce());
          break;
        case 'finance':
          data.add(_generateFinance());
          break;
      }
    }

    setState(() {
      if (_format == 'json') {
        _output = const JsonEncoder.withIndent('  ').convert(data);
      } else if (_format == 'csv') {
        _output = _toCsv(data);
      } else {
        _output = data.map((d) => d.toString()).join('\n\n');
      }
    });
  }

  Map<String, dynamic> _generatePerson() {
    return {
      'id': _faker.guid.guid(),
      'firstName': _faker.person.firstName(),
      'lastName': _faker.person.lastName(),
      'email': _faker.internet.email(),
      'phone': _faker.phoneNumber.us(),
      'dateOfBirth': _faker.date.dateTime(minYear: 1950, maxYear: 2005).toIso8601String().split('T')[0],
      'gender': _faker.randomGenerator.element(['Male', 'Female', 'Other']),
    };
  }

  Map<String, dynamic> _generateAddress() {
    return {
      'street': _faker.address.streetAddress(),
      'city': _faker.address.city(),
      'state': _faker.address.stateAbbreviation(),
      'zipCode': _faker.address.zipCode(),
      'country': _faker.address.country(),
      'latitude': _faker.geo.latitude().toString(),
      'longitude': _faker.geo.longitude().toString(),
    };
  }

  Map<String, dynamic> _generateCompany() {
    return {
      'name': _faker.company.name(),
      'suffix': _faker.company.suffix(),
      'catchPhrase': _faker.company.position(),
      'industry': _faker.randomGenerator.element(['Technology', 'Finance', 'Healthcare', 'Retail', 'Manufacturing']),
      'employees': _faker.randomGenerator.integer(1000, min: 10),
      'founded': _faker.date.dateTime(minYear: 1950, maxYear: 2020).year,
    };
  }

  Map<String, dynamic> _generateInternet() {
    return {
      'username': _faker.internet.userName(),
      'email': _faker.internet.email(),
      'password': _faker.internet.password(),
      'domain': _faker.internet.domainName(),
      'url': _faker.internet.httpsUrl(),
      'ipv4': _faker.internet.ipv4Address(),
      'ipv6': _faker.internet.ipv6Address(),
      'userAgent': _faker.internet.userAgent(),
      'mac': _faker.internet.macAddress(),
    };
  }

  Map<String, dynamic> _generateCommerce() {
    return {
      'productName': _faker.food.dish(),
      'price': _faker.randomGenerator.decimal(scale: 999.99, min: 9.99).toStringAsFixed(2),
      'currency': _faker.currency.code(),
      'sku': 'SKU-${_faker.randomGenerator.integer(99999, min: 10000)}',
      'category': _faker.randomGenerator.element(['Electronics', 'Clothing', 'Food', 'Books', 'Home']),
      'inStock': _faker.randomGenerator.boolean(),
      'rating': _faker.randomGenerator.decimal(scale: 5.0, min: 1.0).toStringAsFixed(1),
    };
  }

  Map<String, dynamic> _generateFinance() {
    final part1 = _faker.randomGenerator.integer(9999, min: 1000);
    final part2 = _faker.randomGenerator.integer(9999, min: 1000);
    final part3 = _faker.randomGenerator.integer(9999, min: 1000);
    final part4 = _faker.randomGenerator.integer(9999, min: 1000);
    
    return {
      'accountNumber': _faker.randomGenerator.integer(999999999, min: 100000000).toString(),
      'routingNumber': _faker.randomGenerator.integer(999999999, min: 100000000).toString(),
      'creditCard': '$part1$part2$part3$part4',
      'cvv': _faker.randomGenerator.integer(999, min: 100).toString(),
      'expiryDate': '${_faker.randomGenerator.integer(12, min: 1).toString().padLeft(2, '0')}/${_faker.randomGenerator.integer(30, min: 26)}',
      'iban': 'GB${_faker.randomGenerator.integer(99, min: 10)}BARC${_faker.randomGenerator.integer(99999999, min: 10000000)}',
      'bic': 'BARCGB22XXX',
    };
  }

  String _toCsv(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '';
    
    final headers = data.first.keys.toList();
    final rows = <String>[];
    
    rows.add(headers.join(','));
    
    for (final item in data) {
      final row = headers.map((h) {
        final value = item[h].toString();
        if (value.contains(',') || value.contains('"')) {
          return '"${value.replaceAll('"', '""')}"';
        }
        return value;
      }).join(',');
      rows.add(row);
    }
    
    return rows.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildControls(colors),
            const SizedBox(height: 24),
            Expanded(child: _buildOutput(colors)),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(ColorScheme colors) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Data Type:', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Person'),
                        selected: _dataType == 'person',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'person');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Address'),
                        selected: _dataType == 'address',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'address');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Company'),
                        selected: _dataType == 'company',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'company');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Internet'),
                        selected: _dataType == 'internet',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'internet');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Commerce'),
                        selected: _dataType == 'commerce',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'commerce');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                      ChoiceChip(
                        label: const Text('Finance'),
                        selected: _dataType == 'finance',
                        onSelected: (v) {
                          if (v) {
                            setState(() => _dataType = 'finance');
                            _generate();
                          }
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Count:', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 12),
                Expanded(
                  child: Slider(
                    value: _count.toDouble(),
                    min: 1,
                    max: 100,
                    divisions: 99,
                    label: '$_count',
                    onChanged: (v) => setState(() => _count = v.toInt()),
                  ),
                ),
                Text('$_count', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(width: 24),
                Text('Format:', style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'json', label: Text('JSON')),
                    ButtonSegment(value: 'csv', label: Text('CSV')),
                  ],
                  selected: {_format},
                  onSelectionChanged: (v) {
                    setState(() => _format = v.first);
                    _generate();
                  },
                  style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: _generate,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Generate'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutput(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'GENERATED DATA ($_count records)',
          trailing: CopyButton(text: _output),
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
                _output,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
