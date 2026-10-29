import 'package:flutter/foundation.dart';

enum DebugType { error, info, url, response, alert, warning }

void console(Object? value, {String tag = '', DebugType type = DebugType.info}) {
  if (kReleaseMode) return;
  switch (type) {
    case DebugType.alert:
      debugPrint('\x1B[95m${"ALERT $tag: $value"}\x1B[0m');
    case DebugType.info:
      debugPrint('\x1B[32m${"INFO $tag: $value"}\x1B[0m');
    case DebugType.error:
      debugPrint('\x1B[31m${"ERROR $tag: $value"}\x1B[0m');
    case DebugType.response:
      debugPrint('\x1B[36m${"RESPONSE $tag: $value"}\x1B[0m', wrapWidth: 4096);
    case DebugType.url:
      debugPrint('\x1B[34m${"URL $tag: $value"}\x1B[0m');
    case DebugType.warning:
      debugPrint('\x1B[33m${"WARNING $tag: $value"}\x1B[0m');
  }
}
