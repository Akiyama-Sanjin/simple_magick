import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/image_item.dart';

class ImageService {
  static Future<void> processWithConcurrency<T>(
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

  static Future<ImageItem?> getImageInfo(String path, String name) async {
    try {
      final result = await Process.run('magick', [
        'identify',
        '-ping',
        '-format',
        '%w|%h|%B|%[orientation]',
        path,
      ]);

      if (result.exitCode == 0) {
        final String output = result.stdout.toString().trim();
        final String firstLine = output.split('\n').first;
        final List<String> parts = firstLine.split('|');

        if (parts.length >= 3) {
          int width = int.tryParse(parts[0]) ?? 0;
          int height = int.tryParse(parts[1]) ?? 0;
          final int sizeBytes = int.tryParse(parts[2]) ?? 0;

          if (parts.length >= 4) {
            final String orientation = parts[3];
            if ([
              'LeftTop',
              'RightTop',
              'RightBottom',
              'LeftBottom',
            ].contains(orientation)) {
              final temp = width;
              width = height;
              height = temp;
            }
          }

          return ImageItem(
            name: name,
            path: path,
            sizeBytes: sizeBytes,
            width: width,
            height: height,
          );
        }
      } else {
        debugPrint('Magick identify failed: ${result.stderr}');
      }
    } catch (e) {
      debugPrint('Error running magick: $e');
    }
    return null;
  }

  static Future<void> scaleImage(ImageItem item, double scaleFactor) async {
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

      final int percentage = (scaleFactor * 100).toInt();

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

      if (result.exitCode == 0) {
        // 获取新图片信息
        final newItem = await getImageInfo(newPath, name);
        if (newItem != null) {
          item.status = ImageStatus.done;
          item.newWidth = newItem.width;
          item.newHeight = newItem.height;
          item.newSizeBytes = newItem.sizeBytes;
        } else {
          item.status = ImageStatus.done;
        }
      } else {
        item.status = ImageStatus.failed;
        debugPrint('Scale error: ${result.stderr}');
      }
    } catch (e) {
      item.status = ImageStatus.error;
      debugPrint('Scale exception: $e');
    }
  }

  static Future<bool> checkFileExists(ImageItem item) async {
    final File file = File(item.path);
    final String dir = file.parent.path;
    final String name = item.name;
    final int dotIndex = name.lastIndexOf('.');
    final String nameWithoutExt = dotIndex != -1
        ? name.substring(0, dotIndex)
        : name;
    final String resizedDirPath = '$dir\\resized';
    final String newPath = '$resizedDirPath\\$nameWithoutExt.jpg';

    return await File(newPath).exists();
  }
}
