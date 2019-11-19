import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:device_info/device_info.dart';
import 'package:fcode_bloc/src/log/log.dart';
import 'package:flutter/services.dart';

abstract class Algo {
  static final _log = Log("Algorithms");

  static String _deviceID = "";

  Algo._();

  static String toTitleCase(final String text) {
    if (text == null) {
      return "";
    }
    List<String> words = text.toLowerCase().split(" ");
    words = words.map((word) {
      if (word.isEmpty) {
        return "";
      }
      return word[0].toUpperCase() + word.substring(1);
    }).toList();
    return words.join(" ");
  }

  static Future<String> getUdID() async {
    if (_deviceID == null || _deviceID.isEmpty) {
      String deviceName = "";
      String deviceVersion = "";
      String identifier = "";
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          var build = await deviceInfoPlugin.androidInfo;
          deviceName = build.model;
          deviceVersion = build.version.toString();
          identifier = build.androidId;
        } else if (Platform.isIOS) {
          var data = await deviceInfoPlugin.iosInfo;
          deviceName = data.name;
          deviceVersion = data.systemVersion;
          identifier = data.identifierForVendor;
        }
      } on PlatformException {
        _log.e('Failed to get platform version');
      }
      _log.i('Device Name: $deviceName, deviceVersion: $deviceVersion, identifier: $identifier');

      final String key = identifier;
      _deviceID = sha512.convert(utf8.encode(key)).toString();
    }
    return _deviceID;
  }
}
