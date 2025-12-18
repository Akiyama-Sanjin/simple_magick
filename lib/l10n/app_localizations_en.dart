// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Simple Magick';

  @override
  String get windowTitle => 'Simple Magick: Batch Image Scaling Tool';

  @override
  String get btnSelectImages => 'Select Images';

  @override
  String get btnScaleImages => 'Scale Images';

  @override
  String get btnClear => 'Clear';

  @override
  String get btnOpenDir => 'Open Dir';

  @override
  String get labelScaleRatio => 'Scale Ratio:';

  @override
  String get dialogTitleTip => 'Tip';

  @override
  String get dialogContentOverwrite =>
      'You have already scaled these images. Do you want to rescale and overwrite them?';

  @override
  String get btnYes => 'Yes';

  @override
  String get btnNo => 'No';

  @override
  String get colIndex => 'Index';

  @override
  String get colFileName => 'File Name';

  @override
  String get colResolution => 'Resolution';

  @override
  String get colAspectRatio => 'Aspect Ratio';

  @override
  String get colSize => 'Size';

  @override
  String get colNewResolution => 'New Res';

  @override
  String get colNewSize => 'New Size';

  @override
  String get colStatus => 'Status';

  @override
  String get colAction => 'Action';

  @override
  String get statusProcessing => 'Processing...';

  @override
  String get statusDone => 'Done';

  @override
  String get statusFailed => 'Failed';

  @override
  String get statusError => 'Error';

  @override
  String msgErrorPicking(Object error) {
    return 'Error picking images: $error';
  }
}
