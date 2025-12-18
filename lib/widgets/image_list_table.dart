import 'package:flutter/material.dart';
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
}
