import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../models/image_item.dart';
import '../services/image_service.dart';
import '../widgets/image_list_table.dart';

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
  String? _outputDir;

  Future<bool> _checkAllFilesExist() async {
    if (_images.isEmpty) return false;
    for (final item in _images) {
      if (!await ImageService.checkFileExists(item)) {
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

    // 更新输出目录为第一张图片所在目录下的 resized 文件夹
    if (_images.isNotEmpty) {
      final String firstPath = _images.first.path;
      final String parentDir = File(firstPath).parent.path;
      setState(() {
        _outputDir = '$parentDir\\resized';
      });
    }

    await ImageService.processWithConcurrency(_images, (item) async {
      if (!mounted) return;
      setState(() {
        item.status = '处理中...';
      });

      await ImageService.scaleImage(item, _scaleFactor);

      if (mounted) {
        setState(() {}); // Refresh UI to show status/result
      }
    }, 4);
  }

  void _clearList() {
    setState(() {
      _images.clear();
      _outputDir = null;
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
        await ImageService.processWithConcurrency(result.files, (file) async {
          if (file.path == null) return;
          final item = await ImageService.getImageInfo(file.path!, file.name);
          if (item != null) {
            newImages.add(item);
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
                  onPressed: _outputDir == null
                      ? null
                      : () {
                          Process.run('explorer', [_outputDir!]);
                        },
                  icon: const Icon(Icons.folder_open),
                  label: const Text('打开目录'),
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
          Expanded(
            child: ImageListTable(
              images: _images,
              onDelete: (index) {
                setState(() {
                  _images.removeAt(index);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
