import 'package:intl/intl.dart';

class Log {
  static final _dateFormat = DateFormat("Hms", "en_US");
  static final Map<String, Log> _logs = {};

  static const int debug = 4;
  static const int info = 3;
  static const int warn = 2;
  static const int error = 1;
  static const int critical = 0;
  static const int off = -1;
  static int level = debug;

  final String tag;

  Log._(tag) : tag = tag.padRight(25);

  factory Log(String tag) {
    if (!_logs.containsKey(tag)) {
      _logs[tag] = Log._(tag);
    }
    return _logs[tag];
  }

  void d(String message) {
    if (level >= debug) _print('DEBUG', message);
  }

  void e(String message) {
    if (level >= error) _print('ERROR', message);
  }

  void i(String message) {
    if (level >= info) _print('INFO ', message);
  }

  void w(String message) {
    if (level >= warn) _print('WARN ', message);
  }

  void _print(String level, String message) {
    final time = _dateFormat.format(DateTime.now());
    print('[$time] - $tag\t- [$level]: $message');
  }
}
