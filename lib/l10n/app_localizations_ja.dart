// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'Simple Magick';

  @override
  String get windowTitle => 'Simple Magick：画像一括縮小ツール';

  @override
  String get btnSelectImages => '画像を選択';

  @override
  String get btnScaleImages => '縮小開始';

  @override
  String get btnClear => 'クリア';

  @override
  String get btnOpenDir => 'フォルダを開く';

  @override
  String get labelScaleRatio => '縮小率:';

  @override
  String get dialogTitleTip => 'ヒント';

  @override
  String get dialogContentOverwrite => 'これらの画像は既に処理されています。上書きして再処理しますか？';

  @override
  String get btnYes => 'はい';

  @override
  String get btnNo => 'いいえ';

  @override
  String get colIndex => 'No.';

  @override
  String get colFileName => 'ファイル名';

  @override
  String get colResolution => '解像度';

  @override
  String get colAspectRatio => '比率';

  @override
  String get colSize => 'サイズ';

  @override
  String get colNewResolution => '新解像度';

  @override
  String get colNewSize => '新サイズ';

  @override
  String get colStatus => 'ステータス';

  @override
  String get colAction => '操作';

  @override
  String get statusProcessing => '処理中...';

  @override
  String get statusDone => '完了';

  @override
  String get statusFailed => '失敗';

  @override
  String get statusError => 'エラー';

  @override
  String msgErrorPicking(Object error) {
    return '画像選択エラー: $error';
  }

  @override
  String get tooltipLanguage => '言語';
}
