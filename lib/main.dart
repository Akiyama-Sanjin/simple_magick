import 'dart:ui' as ui;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Magick',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'NotoSansSC',
      ),
      home: const MyHomePage(title: 'Simple Magick'),
    );
  }
}

class ImageItem {
  final String name;
  final String path;
  final int sizeBytes;
  final int width;
  final int height;
  final String status;

  ImageItem({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.width,
    required this.height,
    this.status = '',
  });

  String get resolution => '${width}x$height';

  String get sizeString {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) {
      return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get aspectRatio {
    int gcd(int a, int b) => b == 0 ? a : gcd(b, a % b);
    int divisor = gcd(width, height);
    if (divisor == 0) return 'Unknown';
    return '${width ~/ divisor}:${height ~/ divisor}';
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<ImageItem> _images = [];
  bool _isLoading = false;
  double _scaleFactor = 0.5; // Default 50%

  Future<void> _scaleImages() async {
    debugPrint('Scaling images by $_scaleFactor');
  }

  Future<void> _pickImages() async {
    setState(() {
      _isLoading = true;
    });

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
      );

      if (result != null) {
        List<ImageItem> newImages = [];
        for (var file in result.files) {
          if (file.path != null) {
            // 使用 ImageDescriptor 只读取图片元数据，不解码整个图片
            final buffer = await ui.ImmutableBuffer.fromFilePath(file.path!);
            final descriptor = await ui.ImageDescriptor.encoded(buffer);

            newImages.add(
              ImageItem(
                name: file.name,
                path: file.path!,
                sizeBytes: file.size,
                width: descriptor.width,
                height: descriptor.height,
              ),
            );

            // 释放资源
            descriptor.dispose();
            buffer.dispose();
          }
        }
        setState(() {
          _images.addAll(newImages);
        });
      }
    } catch (e) {
      debugPrint('Error picking images: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _pickImages,
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('选择图片'),
                ),
                const SizedBox(width: 20),
                const Text('缩放比例: '),
                const SizedBox(width: 10),
                SegmentedButton<double>(
                  segments: const [
                    ButtonSegment<double>(value: 0.25, label: Text('25%')),
                    ButtonSegment<double>(value: 0.50, label: Text('50%')),
                  ],
                  selected: {_scaleFactor},
                  onSelectionChanged: (Set<double> newSelection) {
                    setState(() {
                      _scaleFactor = newSelection.first;
                    });
                  },
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _images.isEmpty || _isLoading
                      ? null
                      : _scaleImages,
                  icon: const Icon(Icons.transform),
                  label: const Text('缩放图片'),
                ),
              ],
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
            color: Colors.grey.shade200,
            child: const Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    '文件名称',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '分辨率',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '比例',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '大小',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    '处理进度',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '操作',
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _images.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _images[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(flex: 2, child: Text(item.resolution)),
                      Expanded(flex: 1, child: Text(item.aspectRatio)),
                      Expanded(flex: 1, child: Text(item.sizeString)),
                      Expanded(
                        flex: 2,
                        child: Text(
                          item.status,
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                      SizedBox(
                        width: 40,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _images.removeAt(index);
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
