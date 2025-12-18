enum ImageStatus { pending, processing, done, failed, error }

class ImageItem {
  final String name;
  final String path;
  final int sizeBytes;
  final int width;
  final int height;
  ImageStatus status;
  int? newWidth;
  int? newHeight;
  int? newSizeBytes;
  String? outputPath;

  ImageItem({
    required this.name,
    required this.path,
    required this.sizeBytes,
    required this.width,
    required this.height,
    this.status = ImageStatus.pending,
    this.newWidth,
    this.newHeight,
    this.newSizeBytes,
    this.outputPath,
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
