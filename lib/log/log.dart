import 'package:intl/intl.dart';

class Log {
  static final _dateFormat = DateFormat("Hms", "en_US");
  static final Map<String, Log> _logs = {};

  static const int DEBUG = 4;
  static const int INFO = 3;
  static const int WARN = 2;
  static const int ERROR = 1;
  static const int CRITICAL = 0;
  static const int OFF = -1;
  static int level = DEBUG;

  final String tag;

  Log._(this.tag);

  factory Log(String tag) {
    if (!_logs.containsKey(tag)) {
      _logs[tag] = Log._(tag);
    }
    return _logs[tag];
  }

  void d(String message) {
    if (level >= DEBUG) _print('DEBUG', message);
  }

  void e(String message) {
    if (level >= ERROR) _print('ERROR', message);
  }

  void i(String message) {
    if (level >= INFO) _print('INFO ', message);
  }

  void w(String message) {
    if (level >= WARN) _print('WARN ', message);
  }

  void _print(String level, String message) {
    final time = _dateFormat.format(DateTime.now());
    print('[$time] - $tag\t- [$level]: $message');
  }
}
