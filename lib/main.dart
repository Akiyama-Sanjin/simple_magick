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

  ImageItem({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.width,
    required this.height,
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
            File imageFile = File(file.path!);
            var decodedImage = await decodeImageFromList(
              await imageFile.readAsBytes(),
            );

            newImages.add(
              ImageItem(
                name: file.name,
                path: file.path!,
                sizeBytes: file.size,
                width: decodedImage.width,
                height: decodedImage.height,
              ),
            );
            // Dispose the image to free memory
            decodedImage.dispose();
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
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _pickImages,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('选择图片'),
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: _images.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final item = _images[index];
                return ListTile(
                  leading: Image.file(
                    File(item.path),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                  title: Text(
                    item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '分辨率: ${item.resolution} | 大小: ${item.sizeString} | 比例: ${item.aspectRatio}',
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _images.removeAt(index);
                      });
                    },
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
