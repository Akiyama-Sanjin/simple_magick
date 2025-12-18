import 'dart:io';
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
  String status;
  int? newWidth;
  int? newHeight;
  int? newSizeBytes;

  ImageItem({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.width,
    required this.height,
    this.status = '',
    this.newWidth,
    this.newHeight,
    this.newSizeBytes,
  });

  String get resolution => '${width}x$height';
  String get newResolution =>
      (newWidth != null && newHeight != null) ? '${newWidth}x$newHeight' : '';

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get sizeString => _formatBytes(sizeBytes);
  String get newSizeString =>
      newSizeBytes != null ? _formatBytes(newSizeBytes!) : '';

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

  Future<void> _processWithConcurrency<T>(
    List<T> items,
    Future<void> Function(T) processor,
    int concurrency,
  ) async {
    final iterator = items.iterator;
    final List<Future> workers = [];

    Future<void> worker() async {
      while (iterator.moveNext()) {
        final item = iterator.current;
        await processor(item);
      }
    }

    for (int i = 0; i < concurrency; i++) {
      workers.add(worker());
    }

    await Future.wait(workers);
  }

  Future<bool> _checkAllFilesExist() async {
    if (_images.isEmpty) return false;
    for (final item in _images) {
      final File file = File(item.path);
      final String dir = file.parent.path;
      final String name = item.name;
      final int dotIndex = name.lastIndexOf('.');
      final String nameWithoutExt = dotIndex != -1
          ? name.substring(0, dotIndex)
          : name;
      final String resizedDirPath = '$dir\\resized';
      final String newPath = '$resizedDirPath\\$nameWithoutExt.jpg';

      if (!await File(newPath).exists()) {
        return false;
      }
    }
    return true;
  }

  Future<void> _scaleImages() async {
    if (await _checkAllFilesExist()) {
      if (!mounted) return;
      final bool? shouldOverwrite = await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('提示'),
            content: const Text('您已经缩放过本批图片，是否重新缩放并覆盖？'),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
                child: const Text('否'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: const Text('是'),
              ),
            ],
          );
        },
      );

      if (shouldOverwrite != true) {
        return;
      }
    }

    await _processWithConcurrency(_images, (item) async {
      if (!mounted) return;
      setState(() {
        item.status = '处理中...';
      });

      try {
        // 构造输出路径
        final File file = File(item.path);
        final String dir = file.parent.path;
        final String name = item.name;
        final int dotIndex = name.lastIndexOf('.');
        final String nameWithoutExt = dotIndex != -1
            ? name.substring(0, dotIndex)
            : name;

        // 创建 resized 子目录
        final String resizedDirPath = '$dir\\resized';
        final Directory resizedDir = Directory(resizedDirPath);
        if (!await resizedDir.exists()) {
          try {
            await resizedDir.create();
          } catch (_) {
            // 忽略并发创建时的错误
          }
        }

        // 输出为 jpg
        final String newPath = '$resizedDirPath\\$nameWithoutExt.jpg';

        final int percentage = (_scaleFactor * 100).toInt();

        // 调用 magick 进行缩放
        final result = await Process.run('magick', [
          item.path,
          '-scale',
          '$percentage%',
          '-quality',
          '95',
          '-sampling-factor',
          '4:4:4',
          newPath,
        ]);

        if (!mounted) return;
        if (result.exitCode == 0) {
          // 获取新图片信息
          try {
            final infoResult = await Process.run('magick', [
              'identify',
              '-ping',
              '-format',
              '%w|%h|%B',
              newPath,
            ]);

            if (infoResult.exitCode == 0) {
              final String output = infoResult.stdout.toString().trim();
              final String firstLine = output.split('\n').first;
              final List<String> parts = firstLine.split('|');

              if (parts.length == 3) {
                final int width = int.tryParse(parts[0]) ?? 0;
                final int height = int.tryParse(parts[1]) ?? 0;
                final int sizeBytes = int.tryParse(parts[2]) ?? 0;

                setState(() {
                  item.status = '完成';
                  item.newWidth = width;
                  item.newHeight = height;
                  item.newSizeBytes = sizeBytes;
                });
              } else {
                setState(() {
                  item.status = '完成';
                });
              }
            } else {
              setState(() {
                item.status = '完成';
              });
            }
          } catch (e) {
            setState(() {
              item.status = '完成';
            });
            debugPrint('Get new info error: $e');
          }
        } else {
          setState(() {
            item.status = '失败';
          });
          debugPrint('Scale error: ${result.stderr}');
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            item.status = '错误';
          });
        }
        debugPrint('Scale exception: $e');
      }
    }, 4);
  }

  void _clearList() {
    setState(() {
      _images.clear();
    });
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
        // 清空现有列表
        setState(() {
          _images.clear();
        });

        final List<ImageItem> newImages = [];
        await _processWithConcurrency(result.files, (file) async {
          if (file.path == null) return;
          try {
            // 调用 magick identify 获取图片信息
            // 格式: 宽|高|大小(字节)
            final result = await Process.run('magick', [
              'identify',
              '-ping',
              '-format',
              '%w|%h|%B',
              file.path!,
            ]);

            if (result.exitCode == 0) {
              // 处理可能的多帧图片（如GIF），只取第一行
              final String output = result.stdout.toString().trim();
              final String firstLine = output.split('\n').first;
              final List<String> parts = firstLine.split('|');

              if (parts.length == 3) {
                final int width = int.tryParse(parts[0]) ?? 0;
                final int height = int.tryParse(parts[1]) ?? 0;
                final int sizeBytes = int.tryParse(parts[2]) ?? 0;

                newImages.add(
                  ImageItem(
                    name: file.name,
                    path: file.path!,
                    sizeBytes: sizeBytes,
                    width: width,
                    height: height,
                  ),
                );
              }
            } else {
              debugPrint('Magick identify failed: ${result.stderr}');
            }
          } catch (e) {
            debugPrint('Error running magick: $e');
          }
        }, 4);

        if (mounted) {
          setState(() {
            _images.addAll(newImages);
          });
        }
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
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _images.isEmpty || _isLoading ? null : _clearList,
                  icon: const Icon(Icons.delete_sweep),
                  label: const Text('清空'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade100,
                    foregroundColor: Colors.red,
                  ),
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
                  flex: 1,
                  child: Text(
                    '序号',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
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
                    '画面比例',
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
                    '新分辨率',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    '新大小',
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
                      Expanded(flex: 1, child: Text('${index + 1}')),
                      Expanded(
                        flex: 3,
                        child: Text(item.name, overflow: TextOverflow.ellipsis),
                      ),
                      Expanded(flex: 2, child: Text(item.resolution)),
                      Expanded(flex: 1, child: Text(item.aspectRatio)),
                      Expanded(flex: 1, child: Text(item.sizeString)),
                      Expanded(flex: 2, child: Text(item.newResolution)),
                      Expanded(flex: 1, child: Text(item.newSizeString)),
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
