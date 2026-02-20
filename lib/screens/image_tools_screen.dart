import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import '../widgets/copy_button.dart';
import '../widgets/section_header.dart';

class ImageToolsScreen extends StatefulWidget {
  const ImageToolsScreen({super.key});

  @override
  State<ImageToolsScreen> createState() => _ImageToolsScreenState();
}

class _ImageToolsScreenState extends State<ImageToolsScreen> {
  String _activeTab = 'base64';
  Uint8List? _imageBytes;
  Uint8List? _processedBytes;
  String? _imageName;
  String _base64Output = '';
  Map<String, dynamic>? _metadata;
  
  // Resize options
  int _resizeWidth = 800;
  int _resizeHeight = 600;
  bool _maintainAspectRatio = true;
  double _originalAspectRatio = 1.0;
  
  // Compress options
  double _quality = 85;
  
  // Format options
  String _outputFormat = 'PNG';
  
  // Placeholder options
  int _placeholderWidth = 400;
  int _placeholderHeight = 300;
  Color _placeholderBg = Colors.grey.shade300;
  Color _placeholderText = Colors.grey.shade700;
  String _placeholderLabel = 'Placeholder';
  final _labelCtrl = TextEditingController(text: 'Placeholder');

  @override
  void initState() {
    super.initState();
    _labelCtrl.addListener(() {
      setState(() => _placeholderLabel = _labelCtrl.text);
    });
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );

      if (result != null && result.files.first.bytes != null) {
        final bytes = result.files.first.bytes!;
        final image = img.decodeImage(bytes);
        
        if (image != null) {
          _originalAspectRatio = image.width / image.height;
          _resizeWidth = image.width;
          _resizeHeight = image.height;
        }
        
        setState(() {
          _imageBytes = bytes;
          _processedBytes = null;
          _imageName = result.files.first.name;
          _base64Output = base64Encode(bytes);
          _extractMetadata();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  void _extractMetadata() {
    if (_imageBytes == null) return;

    try {
      final image = img.decodeImage(_imageBytes!);
      if (image != null) {
        _metadata = {
          'Width': '${image.width}px',
          'Height': '${image.height}px',
          'Aspect Ratio': (image.width / image.height).toStringAsFixed(2),
          'Original Size': '${(_imageBytes!.length / 1024).toStringAsFixed(2)} KB',
          'Format': _imageName?.split('.').last.toUpperCase() ?? 'Unknown',
          'Channels': image.numChannels.toString(),
          'Has Alpha': image.hasPalette.toString(),
        };
        
        if (_processedBytes != null) {
          final processedImage = img.decodeImage(_processedBytes!);
          if (processedImage != null) {
            final reduction = ((_imageBytes!.length - _processedBytes!.length) / _imageBytes!.length * 100);
            _metadata!['Processed Size'] = '${(_processedBytes!.length / 1024).toStringAsFixed(2)} KB';
            _metadata!['Size Reduction'] = '${reduction.toStringAsFixed(1)}%';
          }
        }
      }
    } catch (e) {
      _metadata = {'Error': e.toString()};
    }
  }

  void _resizeImage() {
    if (_imageBytes == null) return;

    try {
      final image = img.decodeImage(_imageBytes!);
      if (image == null) return;

      final resized = img.copyResize(
        image,
        width: _resizeWidth,
        height: _resizeHeight,
        interpolation: img.Interpolation.linear,
      );

      setState(() {
        _processedBytes = _encodeImage(resized, _outputFormat);
        _extractMetadata();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image resized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resizing: $e')),
      );
    }
  }

  void _compressImage() {
    if (_imageBytes == null) return;

    try {
      final image = img.decodeImage(_imageBytes!);
      if (image == null) return;

      setState(() {
        _processedBytes = _encodeImage(image, _outputFormat, quality: _quality.toInt());
        _extractMetadata();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image compressed successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error compressing: $e')),
      );
    }
  }

  void _convertFormat() {
    if (_imageBytes == null) return;

    try {
      final image = img.decodeImage(_imageBytes!);
      if (image == null) return;

      setState(() {
        _processedBytes = _encodeImage(image, _outputFormat);
        _extractMetadata();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image converted to $_outputFormat successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error converting: $e')),
      );
    }
  }

  void _optimizeImage() {
    if (_imageBytes == null) return;

    try {
      final image = img.decodeImage(_imageBytes!);
      if (image == null) return;

      // Auto-optimize: resize if too large, compress with quality 85
      var optimized = image;
      if (image.width > 1920 || image.height > 1920) {
        final scale = 1920 / (image.width > image.height ? image.width : image.height);
        optimized = img.copyResize(
          image,
          width: (image.width * scale).toInt(),
          height: (image.height * scale).toInt(),
          interpolation: img.Interpolation.linear,
        );
      }

      setState(() {
        _processedBytes = _encodeImage(optimized, 'JPG', quality: 85);
        _extractMetadata();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image optimized successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error optimizing: $e')),
      );
    }
  }

  Uint8List _encodeImage(img.Image image, String format, {int quality = 100}) {
    switch (format) {
      case 'PNG':
        return Uint8List.fromList(img.encodePng(image));
      case 'JPG':
        return Uint8List.fromList(img.encodeJpg(image, quality: quality));
      case 'WebP':
        return Uint8List.fromList(img.encodeJpg(image, quality: quality)); // WebP not directly supported, use JPG
      default:
        return Uint8List.fromList(img.encodePng(image));
    }
  }

  Uint8List _generatePlaceholder() {
    final image = img.Image(width: _placeholderWidth, height: _placeholderHeight);
    
    final bgColor = img.ColorRgb8(
      (_placeholderBg.r * 255).round() & 0xff,
      (_placeholderBg.g * 255).round() & 0xff,
      (_placeholderBg.b * 255).round() & 0xff,
    );
    
    img.fill(image, color: bgColor);
    
    // Note: Text rendering would require additional package
    // For now, just return solid color
    
    return Uint8List.fromList(img.encodePng(image));
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
              child: _buildTabContent(colors),
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
            value: 'base64',
            label: Text('Base64'),
            icon: Icon(Icons.code, size: 18),
          ),
          ButtonSegment(
            value: 'resize',
            label: Text('Resize'),
            icon: Icon(Icons.photo_size_select_large, size: 18),
          ),
          ButtonSegment(
            value: 'compress',
            label: Text('Compress'),
            icon: Icon(Icons.compress, size: 18),
          ),
          ButtonSegment(
            value: 'convert',
            label: Text('Convert'),
            icon: Icon(Icons.transform, size: 18),
          ),
          ButtonSegment(
            value: 'metadata',
            label: Text('Metadata'),
            icon: Icon(Icons.info_outline, size: 18),
          ),
          ButtonSegment(
            value: 'placeholder',
            label: Text('Placeholder'),
            icon: Icon(Icons.crop_square, size: 18),
          ),
        ],
        selected: {_activeTab},
        onSelectionChanged: (v) => setState(() => _activeTab = v.first),
      ),
    );
  }

  Widget _buildTabContent(ColorScheme colors) {
    switch (_activeTab) {
      case 'base64':
        return _buildBase64Tab(colors);
      case 'resize':
        return _buildResizeTab(colors);
      case 'compress':
        return _buildCompressTab(colors);
      case 'convert':
        return _buildConvertTab(colors);
      case 'metadata':
        return _buildMetadataTab(colors);
      case 'placeholder':
        return _buildPlaceholderTab(colors);
      default:
        return _buildBase64Tab(colors);
    }
  }

  Widget _buildBase64Tab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'IMAGE TO BASE64'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_imageBytes != null) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _imageName ?? 'Unknown',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(_imageBytes == null ? 'Select Image' : 'Change Image'),
                ),
              ],
            ),
          ),
        ),
        if (_base64Output.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionHeader(
            title: 'BASE64 OUTPUT',
            trailing: CopyButton(text: _base64Output),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _base64Output,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildResizeTab(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'RESIZE IMAGE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_imageBytes != null) ...[
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: Text(_imageBytes == null ? 'Select Image' : 'Change Image'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Checkbox(
                              value: _maintainAspectRatio,
                              onChanged: (v) => setState(() => _maintainAspectRatio = v!),
                            ),
                            const Text('Maintain aspect ratio', style: TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Width: $_resizeWidth px', style: const TextStyle(fontSize: 12)),
                        Slider(
                          value: _resizeWidth.toDouble(),
                          min: 50,
                          max: 4000,
                          divisions: 79,
                          onChanged: (v) {
                            setState(() {
                              _resizeWidth = v.toInt();
                              if (_maintainAspectRatio) {
                                _resizeHeight = (_resizeWidth / _originalAspectRatio).toInt();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 8),
                        Text('Height: $_resizeHeight px', style: const TextStyle(fontSize: 12)),
                        Slider(
                          value: _resizeHeight.toDouble(),
                          min: 50,
                          max: 4000,
                          divisions: 79,
                          onChanged: (v) {
                            setState(() {
                              _resizeHeight = v.toInt();
                              if (_maintainAspectRatio) {
                                _resizeWidth = (_resizeHeight * _originalAspectRatio).toInt();
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(onPressed: () => setState(() { _resizeWidth = 1920; _resizeHeight = 1080; }), child: const Text('1080p')),
                            TextButton(onPressed: () => setState(() { _resizeWidth = 1280; _resizeHeight = 720; }), child: const Text('720p')),
                            TextButton(onPressed: () => setState(() { _resizeWidth = 800; _resizeHeight = 600; }), child: const Text('800x600')),
                            TextButton(onPressed: () => setState(() { _resizeWidth = 400; _resizeHeight = 400; }), child: const Text('Square')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _resizeImage,
                            icon: const Icon(Icons.photo_size_select_large, size: 18),
                            label: const Text('Resize Image'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_processedBytes != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'RESULT'),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.outlineVariant),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_processedBytes!, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_metadata != null && _metadata!.containsKey('Size Reduction'))
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colors.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.check_circle, color: colors.onPrimaryContainer, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Size reduced by ${_metadata!['Size Reduction']}',
                                    style: TextStyle(
                                      color: colors.onPrimaryContainer,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCompressTab(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'COMPRESS IMAGE'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_imageBytes != null) ...[
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: Text(_imageBytes == null ? 'Select Image' : 'Change Image'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Quality: ${_quality.toInt()}%', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        Slider(
                          value: _quality,
                          min: 1,
                          max: 100,
                          divisions: 99,
                          label: '${_quality.toInt()}%',
                          onChanged: (v) => setState(() => _quality = v),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: [
                            TextButton(onPressed: () => setState(() => _quality = 100), child: const Text('Max (100%)')),
                            TextButton(onPressed: () => setState(() => _quality = 85), child: const Text('High (85%)')),
                            TextButton(onPressed: () => setState(() => _quality = 70), child: const Text('Medium (70%)')),
                            TextButton(onPressed: () => setState(() => _quality = 50), child: const Text('Low (50%)')),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _compressImage,
                            icon: const Icon(Icons.compress, size: 18),
                            label: const Text('Compress Image'),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _optimizeImage,
                            icon: const Icon(Icons.auto_fix_high, size: 18),
                            label: const Text('Auto Optimize'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_processedBytes != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'RESULT'),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.outlineVariant),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_processedBytes!, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_metadata != null) ...[
                            _buildSizeComparison(colors),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConvertTab(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'CONVERT FORMAT'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      if (_imageBytes != null) ...[
                        Container(
                          constraints: const BoxConstraints(maxHeight: 150),
                          decoration: BoxDecoration(
                            border: Border.all(color: colors.outlineVariant),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      FilledButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.upload_file, size: 18),
                        label: Text(_imageBytes == null ? 'Select Image' : 'Change Image'),
                      ),
                    ],
                  ),
                ),
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Output Format:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          segments: const [
                            ButtonSegment(value: 'PNG', label: Text('PNG')),
                            ButtonSegment(value: 'JPG', label: Text('JPG')),
                            ButtonSegment(value: 'WebP', label: Text('WebP')),
                          ],
                          selected: {_outputFormat},
                          onSelectionChanged: (v) => setState(() => _outputFormat = v.first),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: _convertFormat,
                            icon: const Icon(Icons.transform, size: 18),
                            label: Text('Convert to $_outputFormat'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_processedBytes != null) ...[
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeader(title: 'RESULT'),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: colors.outlineVariant),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(_processedBytes!, fit: BoxFit.contain),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle, color: colors.onPrimaryContainer, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Converted to $_outputFormat',
                                  style: TextStyle(
                                    color: colors.onPrimaryContainer,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSizeComparison(ColorScheme colors) {
    if (_metadata == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Original', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  Text(
                    _metadata!['Original Size'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward, color: colors.primary),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Processed', style: TextStyle(fontSize: 11, color: colors.onSurfaceVariant)),
                  Text(
                    _metadata!['Processed Size'] ?? '',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
          if (_metadata!.containsKey('Size Reduction')) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Reduced by ${_metadata!['Size Reduction']}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: colors.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetadataTab(ColorScheme colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'IMAGE METADATA VIEWER'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_imageBytes != null) ...[
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    decoration: BoxDecoration(
                      border: Border.all(color: colors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(_imageBytes!, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                FilledButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.upload_file, size: 18),
                  label: Text(_imageBytes == null ? 'Select Image' : 'Change Image'),
                ),
              ],
            ),
          ),
        ),
        if (_metadata != null) ...[
          const SizedBox(height: 16),
          const SectionHeader(title: 'METADATA'),
          Expanded(
            child: ListView(
              children: _metadata!.entries.map((entry) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.label_outline, size: 18, color: colors.primary),
                    title: Text(
                      entry.key,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    trailing: Text(
                      entry.value.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
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

  Widget _buildPlaceholderTab(ColorScheme colors) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'PLACEHOLDER GENERATOR'),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Width: $_placeholderWidth px', style: const TextStyle(fontSize: 12)),
                      Slider(
                        value: _placeholderWidth.toDouble(),
                        min: 100,
                        max: 2000,
                        divisions: 38,
                        onChanged: (v) => setState(() => _placeholderWidth = v.toInt()),
                      ),
                      const SizedBox(height: 8),
                      Text('Height: $_placeholderHeight px', style: const TextStyle(fontSize: 12)),
                      Slider(
                        value: _placeholderHeight.toDouble(),
                        min: 100,
                        max: 2000,
                        divisions: 38,
                        onChanged: (v) => setState(() => _placeholderHeight = v.toInt()),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _labelCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Placeholder Text',
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Background:', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final color = await showDialog<Color>(
                                context: context,
                                builder: (_) => _ColorPickerDialog(initialColor: _placeholderBg),
                              );
                              if (color != null) setState(() => _placeholderBg = color);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _placeholderBg,
                                border: Border.all(color: colors.outline),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                          const SizedBox(width: 24),
                          const Text('Text:', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () async {
                              final color = await showDialog<Color>(
                                context: context,
                                builder: (_) => _ColorPickerDialog(initialColor: _placeholderText),
                              );
                              if (color != null) setState(() => _placeholderText = color);
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _placeholderText,
                                border: Border.all(color: colors.outline),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          TextButton(onPressed: () => setState(() { _placeholderWidth = 400; _placeholderHeight = 300; }), child: const Text('4:3')),
                          TextButton(onPressed: () => setState(() { _placeholderWidth = 1920; _placeholderHeight = 1080; }), child: const Text('16:9')),
                          TextButton(onPressed: () => setState(() { _placeholderWidth = 800; _placeholderHeight = 800; }), child: const Text('Square')),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            final bytes = _generatePlaceholder();
                            setState(() {
                              _imageBytes = bytes;
                              _imageName = 'placeholder_${_placeholderWidth}x$_placeholderHeight.png';
                              _base64Output = base64Encode(bytes);
                              _extractMetadata();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Placeholder generated! Switch to Base64 tab to view.')),
                            );
                          },
                          icon: const Icon(Icons.add_photo_alternate, size: 18),
                          label: const Text('Generate Placeholder'),
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
              const SectionHeader(title: 'PREVIEW'),
              Expanded(
                child: Card(
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: _placeholderWidth.toDouble().clamp(100, 600),
                        maxHeight: _placeholderHeight.toDouble().clamp(100, 400),
                      ),
                      decoration: BoxDecoration(
                        color: _placeholderBg,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: colors.outlineVariant),
                      ),
                      child: Center(
                        child: Text(
                          '$_placeholderLabel\n$_placeholderWidth × $_placeholderHeight',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _placeholderText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
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
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;

  const _ColorPickerDialog({required this.initialColor});

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Pick Color'),
      content: SizedBox(
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.outline),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Colors.white,
                Colors.grey.shade300,
                Colors.grey.shade700,
                Colors.black,
                Colors.red,
                Colors.pink,
                Colors.purple,
                Colors.deepPurple,
                Colors.indigo,
                Colors.blue,
                Colors.lightBlue,
                Colors.cyan,
                Colors.teal,
                Colors.green,
                Colors.lightGreen,
                Colors.lime,
                Colors.yellow,
                Colors.amber,
                Colors.orange,
                Colors.deepOrange,
                Colors.brown,
                Colors.blueGrey,
              ].map((color) {
                return InkWell(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      border: Border.all(
                        color: _selectedColor == color ? colors.primary : colors.outline,
                        width: _selectedColor == color ? 3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selectedColor),
          child: const Text('Select'),
        ),
      ],
    );
  }
}
