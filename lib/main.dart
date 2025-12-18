import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1080, 720),
    minimumSize: Size(1080, 720),
    center: true,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
    title: 'Simple Magick',
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

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
      home: const MyHomePage(title: 'Simple Magick：magick图片批量缩放工具'),
    );
  }
}
