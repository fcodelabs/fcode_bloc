import 'package:intl/intl.dart';

/// {@template log}
/// Used to print logs in the console according to the severity level
/// of the logging text.
///
/// [Log] instance can be created by providing a [tag], which is used to
/// separate log instances. You can't create two instances with the same tag.
///
/// ```dart
/// class UserRepository {
///   // Create a instance of the log with a tag
///   static final log = Log("UserRepository");
///
///   Future<void> add(Item item) async {
///     log.d("Adding the item with name: ${item.name});
///     // ...
///   }
/// }
/// ```
///
/// By changing the [level] of the [Log] instance, you can decide the
/// severity level that is printed. Default value is [debug].
/// That means every log that has severity level of [debug] or higher
/// will be printed.
///
/// Severity level from higher to lower can be ordered as follows
/// * [critical]
/// * [error]
/// * [warn]
/// * [info]
/// * [debug]
/// {@endtemplate}
class Log {
  static final _dateFormat = DateFormat("Hms", "en_US");
  static final Map<String, Log> _logs = {};

  /// Severity level of [debug].
  static const int debug = 4;

  /// Severity level of [info].
  static const int info = 3;

  /// Severity level of [warn].
  static const int warn = 2;

  /// Severity level of [error].
  static const int error = 1;

  /// Severity level of [critical]
  static const int critical = 0;

  /// Turn off logging
  static const int off = -1;

  /// Used to store the current severity [level] of the [Log] instances.
  /// Default [level] is [debug].
  ///
  /// If [level] is set to [off], no log will print from any instance.
  /// Otherwise logs will be printed which has the provided severity level
  /// or higher.
  ///
  /// Severity level from higher to lower can be ordered as follows
  /// * [critical]
  /// * [error]
  /// * [warn]
  /// * [info]
  /// * [debug]
  static int level = debug;

  /// [tag] is given while creating a instance of the [Log].
  /// If a instance has previously created with the same tag, the same
  /// instance will be return. Else new instance will be created.
  ///
  /// [tag] is also printed in the log, so it will be easier to differentiate
  /// between two log prints from different [Log] instances.
  final String tag;

  Log._(tag) : tag = tag.padRight(25);

  /// {@macro log}
  factory Log(String tag) {
    if (!_logs.containsKey(tag)) {
      _logs[tag] = Log._(tag);
    }
    return _logs[tag];
  }

  /// Used to log a [message] with [debug] severity level.
  ///
  /// ```dart
  /// // Create log instance with a tag
  /// static final log = Log("UserRepository");
  ///
  /// // ...
  ///
  /// // log a message
  /// log.d("Adding the item");
  ///
  /// // output:
  /// // [10:45:32] - UserRepository  - [DEBUG]: Adding the item
  /// ```
  void d(String message) {
    if (level >= debug) _print('DEBUG', message);
  }

  /// Used to log a [message] with [error] severity level.
  ///
  /// ```dart
  /// // Create log instance with a tag
  /// static final log = Log("UserRepository");
  ///
  /// // ...
  ///
  /// // log a message
  /// log.e("Item type is incorrect");
  ///
  /// // output:
  /// // [10:45:32] - UserRepository  - [ERROR]: Item type is incorrect
  /// ```
  void e(String message) {
    if (level >= error) _print('ERROR', message);
  }

  /// Used to log a [message] with [info] severity level.
  ///
  /// ```dart
  /// // Create log instance with a tag
  /// static final log = Log("UserRepository");
  ///
  /// // ...
  ///
  /// // log a message
  /// log.i("User added successfully");
  ///
  /// // output:
  /// // [10:45:32] - UserRepository  - [INFO ]: User added successfully
  /// ```
  void i(String message) {
    if (level >= info) _print('INFO ', message);
  }

  /// Used to log a [message] with [warn] severity level.
  ///
  /// ```dart
  /// // Create log instance with a tag
  /// static final log = Log("UserRepository");
  ///
  /// // ...
  ///
  /// // log a message
  /// log.w("User name is empty");
  ///
  /// // output:
  /// // [10:45:32] - UserRepository  - [WARN ]: User name is empty
  /// ```
  void w(String message) {
    if (level >= warn) _print('WARN ', message);
  }

  void _print(String level, String message) {
    final time = _dateFormat.format(DateTime.now());
    print('[$time] - $tag\t- [$level]: $message');
  }
}
