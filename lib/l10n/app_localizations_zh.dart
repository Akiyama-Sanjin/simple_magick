// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Simple Magick';

  @override
  String get windowTitle => 'Simple Magick：图片批量缩放工具';

  @override
  String get btnSelectImages => '选择图片';

  @override
  String get btnScaleImages => '缩放图片';

  @override
  String get btnClear => '清空';

  @override
  String get btnOpenDir => '打开目录';

  @override
  String get labelScaleRatio => '缩放比例:';

  @override
  String get dialogTitleTip => '提示';

  @override
  String get dialogContentOverwrite => '您已经缩放过本批图片，是否重新缩放并覆盖？';

  @override
  String get btnYes => '是';

  @override
  String get btnNo => '否';

  @override
  String get colIndex => '序号';

  @override
  String get colFileName => '文件名称';

  @override
  String get colResolution => '分辨率';

  @override
  String get colAspectRatio => '画面比例';

  @override
  String get colSize => '大小';

  @override
  String get colNewResolution => '新分辨率';

  @override
  String get colNewSize => '新大小';

  @override
  String get colStatus => '处理进度';

  @override
  String get colAction => '操作';

  @override
  String get statusProcessing => '处理中...';

  @override
  String get statusDone => '完成';

  @override
  String get statusFailed => '失败';

  @override
  String get statusError => '错误';

  @override
  String msgErrorPicking(Object error) {
    return '选择图片出错: $error';
  }

  @override
  String get tooltipLanguage => '语言';
}
