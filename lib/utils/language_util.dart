import 'dart:ui' as ui;

class LanguageUtil {
  static String get isoLanguageCode {
    final locale = ui.PlatformDispatcher.instance.locale;
    return locale.languageCode;
  }
}