// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

void refreshWebPage() {

  final timestamp =
      DateTime.now().millisecondsSinceEpoch;

  html.window.location.href =
  '${html.window.location.pathname}?v=$timestamp';
}