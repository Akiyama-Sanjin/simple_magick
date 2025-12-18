import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/image_item.dart';

class ImageListTable extends StatelessWidget {
  final List<ImageItem> images;
  final Function(int index) onDelete;

  const ImageListTable({
    super.key,
    required this.images,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Table Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          color: Colors.grey.shade200,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.colIndex,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 3,
                child: Text(
                  AppLocalizations.of(context)!.colFileName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.colResolution,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.colAspectRatio,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.colSize,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.colNewResolution,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  AppLocalizations.of(context)!.colNewSize,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  AppLocalizations.of(context)!.colStatus,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  AppLocalizations.of(context)!.colAction,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: images.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = images[index];
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
                        _getStatusText(context, item.status),
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
                        onPressed: () => onDelete(index),
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
    );
  }

  String _getStatusText(BuildContext context, ImageStatus status) {
    switch (status) {
      case ImageStatus.pending:
        return '';
      case ImageStatus.processing:
        return AppLocalizations.of(context)!.statusProcessing;
      case ImageStatus.done:
        return AppLocalizations.of(context)!.statusDone;
      case ImageStatus.failed:
        return AppLocalizations.of(context)!.statusFailed;
      case ImageStatus.error:
        return AppLocalizations.of(context)!.statusError;
    }
  }
}
