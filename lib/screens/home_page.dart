import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';
import '../models/image_item.dart';
import '../services/image_service.dart';
import '../widgets/image_list_table.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
            title: Text(AppLocalizations.of(context)!.dialogTitleTip),
            content: Text(AppLocalizations.of(context)!.dialogContentOverwrite),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade300,
                  foregroundColor: Colors.black87,
                ),
                child: Text(AppLocalizations.of(context)!.btnNo),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                ),
                child: Text(AppLocalizations.of(context)!.btnYes),
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
        item.status = ImageStatus.processing;
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
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'heic'],
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.msgErrorPicking('$e')),
          ),
        );
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
        title: Text(AppLocalizations.of(context)!.windowTitle),
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language),
            tooltip: AppLocalizations.of(context)!.tooltipLanguage,
            onSelected: (Locale locale) {
              MyApp.setLocale(context, locale);
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<Locale>>[
              const PopupMenuItem<Locale>(
                value: Locale('zh'),
                child: Text('简体中文'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('en'),
                child: Text('English'),
              ),
              const PopupMenuItem<Locale>(
                value: Locale('ja'),
                child: Text('日本語'),
              ),
            ],
          ),
        ],
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
                  label: Text(AppLocalizations.of(context)!.btnSelectImages),
                ),
                const SizedBox(width: 20),
                Text(AppLocalizations.of(context)!.labelScaleRatio),
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
                  label: Text(AppLocalizations.of(context)!.btnScaleImages),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _outputDir == null
                      ? null
                      : () {
                          Process.run('explorer', [_outputDir!]);
                        },
                  icon: const Icon(Icons.folder_open),
                  label: Text(AppLocalizations.of(context)!.btnOpenDir),
                ),
                const SizedBox(width: 20),
                ElevatedButton.icon(
                  onPressed: _images.isEmpty || _isLoading ? null : _clearList,
                  icon: const Icon(Icons.delete_sweep),
                  label: Text(AppLocalizations.of(context)!.btnClear),
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
